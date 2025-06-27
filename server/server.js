const express = require('express');
const http = require('http');
const socketIo = require('socket.io');
const cors = require('cors');
const { v4: uuidv4 } = require('uuid');

const app = express();
const server = http.createServer(app);

// إعداد CORS للسماح بالاتصال من Flutter
const io = socketIo(server, {
  cors: {
    origin: "*",
    methods: ["GET", "POST"],
    allowedHeaders: ["*"],
    credentials: true
  },
  transports: ['websocket', 'polling']
});

app.use(cors());
app.use(express.json());

// تخزين بيانات اللعبة
const games = new Map(); // gameId -> gameData
const players = new Map(); // socketId -> playerData
const waitingPlayers = []; // قائمة انتظار اللاعبين

// معلومات الخادم
app.get('/', (req, res) => {
  res.json({
    message: 'Tic Tac Toe Game Server',
    status: 'running',
    connectedPlayers: players.size,
    activeGames: games.size,
    waitingPlayers: waitingPlayers.length
  });
});

// عند اتصال لاعب جديد
io.on('connection', (socket) => {
  console.log(`🎮 لاعب جديد متصل: ${socket.id}`);

  // تسجيل معلومات اللاعب
  socket.on('register_player', (playerData) => {
    console.log(`📝 تسجيل لاعب: ${playerData.username}`);
    players.set(socket.id, {
      ...playerData,
      socketId: socket.id,
      status: 'online'
    });
    
    socket.emit('player_registered', {
      success: true,
      playerId: socket.id
    });
  });

  // البحث عن مباراة
  socket.on('find_match', (playerData) => {
    console.log(`🔍 ${playerData.username} يبحث عن مباراة`);
    
    // تسجيل اللاعب
    players.set(socket.id, {
      ...playerData,
      socketId: socket.id,
      status: 'searching'
    });

    // البحث عن لاعب في الانتظار
    if (waitingPlayers.length > 0) {
      // العثور على مباراة
      const opponent = waitingPlayers.shift();
      const gameId = uuidv4();
      
      // إنشاء لعبة جديدة
      const gameData = {
        id: gameId,
        player1: players.get(opponent.socketId),
        player2: players.get(socket.id),
        board: Array(9).fill(''),
        currentPlayer: 'X',
        status: 'playing',
        createdAt: new Date()
      };
      
      games.set(gameId, gameData);
      
      // إشعار كلا اللاعبين
      socket.join(gameId);
      opponent.socket.join(gameId);
      
      io.to(gameId).emit('match_found', {
        gameId: gameId,
        player1: gameData.player1,
        player2: gameData.player2,
        yourSymbol: socket.id === gameData.player1.socketId ? 'X' : 'O',
        currentPlayer: 'X'
      });
      
      console.log(`✅ مباراة جديدة: ${gameData.player1.username} vs ${gameData.player2.username}`);
      
    } else {
      // إضافة إلى قائمة الانتظار
      waitingPlayers.push({
        socketId: socket.id,
        socket: socket,
        playerData: playerData
      });
      
      socket.emit('searching_match', {
        message: 'جاري البحث عن مباراة...'
      });
      
      console.log(`⏳ ${playerData.username} في قائمة الانتظار`);
    }
  });

  // إلغاء البحث عن مباراة
  socket.on('cancel_search', () => {
    const playerIndex = waitingPlayers.findIndex(p => p.socketId === socket.id);
    if (playerIndex !== -1) {
      waitingPlayers.splice(playerIndex, 1);
      console.log(`❌ ${socket.id} ألغى البحث عن مباراة`);
    }
  });

  // عمل حركة في اللعبة
  socket.on('make_move', (data) => {
    const { gameId, position } = data;
    const game = games.get(gameId);
    
    if (!game) {
      socket.emit('error', { message: 'اللعبة غير موجودة' });
      return;
    }
    
    if (game.status !== 'playing') {
      socket.emit('error', { message: 'اللعبة انتهت بالفعل' });
      return;
    }
    
    // التحقق من صحة الحركة
    if (game.board[position] !== '') {
      socket.emit('error', { message: 'هذه المربع محجوز بالفعل' });
      return;
    }
    
    // التحقق من دور اللاعب
    const isPlayer1 = socket.id === game.player1.socketId;
    const isPlayer2 = socket.id === game.player2.socketId;
    
    if (!isPlayer1 && !isPlayer2) {
      socket.emit('error', { message: 'أنت لست جزء من هذه اللعبة' });
      return;
    }
    
    const currentSymbol = (isPlayer1 && game.currentPlayer === 'X') || 
                         (isPlayer2 && game.currentPlayer === 'O') ? 
                         game.currentPlayer : null;
    
    if (!currentSymbol) {
      socket.emit('error', { message: 'ليس دورك الآن' });
      return;
    }
    
    // تنفيذ الحركة
    game.board[position] = currentSymbol;
    game.currentPlayer = currentSymbol === 'X' ? 'O' : 'X';
    
    // فحص انتهاء اللعبة
    const winner = checkWinner(game.board);
    const isDraw = !winner && game.board.every(cell => cell !== '');
    
    if (winner || isDraw) {
      game.status = 'finished';
      game.winner = winner;
      game.finishedAt = new Date();
      
      io.to(gameId).emit('game_ended', {
        winner: winner,
        isDraw: isDraw,
        board: game.board,
        finalBoard: game.board
      });
      
      console.log(`🏁 انتهت اللعبة ${gameId}: ${winner ? `الفائز ${winner}` : 'تعادل'}`);
      
      // حذف اللعبة بعد دقيقة
      setTimeout(() => {
        games.delete(gameId);
      }, 60000);
      
    } else {
      // إرسال الحركة للاعبين
      io.to(gameId).emit('move_made', {
        position: position,
        symbol: currentSymbol,
        board: game.board,
        currentPlayer: game.currentPlayer,
        nextTurn: game.currentPlayer
      });
    }
  });

  // مغادرة اللعبة
  socket.on('leave_game', () => {
    handlePlayerDisconnect(socket);
  });

  // عند قطع الاتصال
  socket.on('disconnect', () => {
    console.log(`👋 لاعب غادر: ${socket.id}`);
    handlePlayerDisconnect(socket);
  });
});

// معالجة مغادرة اللاعب
function handlePlayerDisconnect(socket) {
  // إزالة من قائمة الانتظار
  const waitingIndex = waitingPlayers.findIndex(p => p.socketId === socket.id);
  if (waitingIndex !== -1) {
    waitingPlayers.splice(waitingIndex, 1);
  }
  
  // البحث عن الألعاب التي يشارك فيها
  for (const [gameId, game] of games.entries()) {
    if (game.player1.socketId === socket.id || game.player2.socketId === socket.id) {
      game.status = 'abandoned';
      
      // إشعار اللاعب الآخر
      socket.to(gameId).emit('player_left', {
        message: 'اللاعب الآخر غادر اللعبة',
        gameEnded: true
      });
      
      console.log(`🚪 لاعب غادر اللعبة ${gameId}`);
      
      // حذف اللعبة
      setTimeout(() => {
        games.delete(gameId);
      }, 5000);
    }
  }
  
  // إزالة اللاعب
  players.delete(socket.id);
}

// فحص الفائز
function checkWinner(board) {
  const winPatterns = [
    [0, 1, 2], [3, 4, 5], [6, 7, 8], // صفوف
    [0, 3, 6], [1, 4, 7], [2, 5, 8], // أعمدة
    [0, 4, 8], [2, 4, 6] // أقطار
  ];
  
  for (const pattern of winPatterns) {
    const [a, b, c] = pattern;
    if (board[a] && board[a] === board[b] && board[a] === board[c]) {
      return board[a];
    }
  }
  
  return null;
}

// تشغيل الخادم
const PORT = process.env.PORT || 3000;
server.listen(PORT, () => {
  console.log(`🚀 خادم Tic Tac Toe يعمل على المنفذ ${PORT}`);
  console.log(`🌐 http://localhost:${PORT}`);
});

// معالجة الإغلاق الآمن
process.on('SIGINT', () => {
  console.log('\n👋 إغلاق الخادم...');
  io.close();
  server.close(() => {
    console.log('✅ تم إغلاق الخادم بنجاح');
    process.exit(0);
  });
});
