import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter/foundation.dart';
import 'unified_auth_services.dart';
import '../models/complete_user_models.dart' as UserModels;

/// خدمة الألعاب الجماعية باستخدام Socket.IO
class OnlineGameService extends ChangeNotifier {
  static final OnlineGameService _instance = OnlineGameService._internal();
  factory OnlineGameService() => _instance;
  OnlineGameService._internal();

  final FirebaseAuthService _authService = FirebaseAuthService();
  IO.Socket? _socket;
  bool _isConnected = false;
  String? _gameRoomId;
  String? _playerId;
  Map<String, dynamic>? _currentGame;
  UserModels.User? _opponent;

  // Game state
  List<String> _board = List.filled(9, '');
  bool _isMyTurn = false;
  String _mySymbol = '';
  String _gameStatus = 'waiting'; // waiting, playing, finished
  String? _winner;

  // Getters
  bool get isConnected => _isConnected;
  String? get gameRoomId => _gameRoomId;
  String? get playerId => _playerId;
  Map<String, dynamic>? get currentGame => _currentGame;
  UserModels.User? get opponent => _opponent;
  List<String> get board => _board;
  bool get isMyTurn => _isMyTurn;
  String get mySymbol => _mySymbol;
  String get gameStatus => _gameStatus;
  String? get winner => _winner;

  /// ??????? ???????
  Future<void> connect() async {
    if (_isConnected) return;

    try {
      // تهيئة اتصال السوكت الجديد - Socket.IO Client 3.x
      _socket = IO.io('http://localhost:3000', <String, dynamic>{
        'transports': ['websocket', 'polling'],
        'autoConnect': false, // تعطيل الاتصال التلقائي
        'timeout': 5000, // تقليل timeout إلى 5 ثواني
        'forceNew': true,
      });

      // محاولة الاتصال مع timeout محدود
      final connectFuture = Future(() {
        _socket?.connect();
        return _socket?.onConnect;
      });

      // انتظار لمدة 3 ثواني فقط
      await connectFuture.timeout(
        const Duration(seconds: 3),
        onTimeout: () {
          debugPrint(
            '⚠️ Socket connection timeout - continuing in offline mode',
          );
          _socket?.disconnect();
          _socket?.dispose();
          _socket = null;
          return null;
        },
      );

      if (_socket?.connected == true) {
        _isConnected = true;
        debugPrint('✅ Connected to game server');

        // تسجيل اللاعب الحالي عند الاتصال
        final currentUser = _authService.currentUserModel;
        if (currentUser != null) {
          registerPlayer(currentUser);
        }
        _setupEventListeners();
        notifyListeners();
      } else {
        debugPrint('⚠️ Failed to connect to game server - offline mode');
      }
    } catch (e) {
      debugPrint('⚠️ Socket connection error (offline mode): $e');
      _isConnected = false;
      _socket?.disconnect();
      _socket?.dispose();
      _socket = null;
      // لا نرمي الخطأ - نستمر في الوضع غير المتصل
    }
  }

  /// ????? ?????? ?? ??????
  void registerPlayer(UserModels.User user) {
    if (_socket?.connected == true) {
      _socket?.emit('register_player', {
        'username': user.displayName,
        'userId': user.id,
        'email': user.email,
        'avatarUrl': user.photoURL,
        'gems': user.gems,
      });
      debugPrint('?? Registering player: ${user.displayName}');
    }
  }

  /// ??? ???????
  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _isConnected = false;
    _resetGameState();
    notifyListeners();
  }

  /// إعداد مستمعي الأحداث
  void _setupEventListeners() {
    if (_socket?.connected != true) return;

    // عند تسجيل اللاعب بنجاح
    _socket?.on('player_registered', (data) {
      debugPrint('✅ Player registered: $data');
      _playerId = data['playerId'];
    });

    // عند العثور على مباراة
    _socket?.on('match_found', (data) {
      debugPrint('🎮 Match found: $data');
      _handleMatchFound(data);
    });

    // عند تحريك خصم
    _socket?.on('move_made', (data) {
      debugPrint('👋 Opponent move: $data');
      _handleOpponentMove(data);
    });

    // عند انتهاء المباراة
    _socket?.on('game_over', (data) {
      debugPrint('🏁 Game over: $data');
      _handleGameOver(data);
    });

    // عند قطع الاتصال
    _socket?.onDisconnect((_) {
      _isConnected = false;
      debugPrint('🔌 Disconnected from game server');
      _resetGameState();
      notifyListeners();
    });

    // عند حدوث خطأ في الاتصال
    _socket?.onConnectError((error) {
      debugPrint('❌ Connection error: $error');
      _isConnected = false;
      notifyListeners();
    });
  }

  /// ????? ?? ??????
  Future<void> findMatch() async {
    if (!_isConnected) {
      debugPrint('? Not connected to server');
      return;
    }

    if (!_authService.isSignedIn) {
      debugPrint('? User not authenticated');
      return;
    }

    _gameStatus = 'searching';
    notifyListeners();

    final currentUser = _authService.currentUserModel;
    if (currentUser == null) return;

    _socket?.emit('find_match', {
      'userId': currentUser.id,
      'username': currentUser.displayName,
      'avatarUrl': currentUser.photoURL,
      'gems': currentUser.gems,
    });

    debugPrint('?? Searching for match...');
  }

  /// ???? ???? ????
  Future<void> inviteFriend(String friendId) async {
    if (!_isConnected) {
      debugPrint('? Not connected to server');
      return;
    }

    if (!_authService.isSignedIn) {
      debugPrint('? User not authenticated');
      return;
    }

    final currentUser = _authService.currentUserModel;
    if (currentUser == null) return;

    _socket?.emit('invite_friend', {
      'fromUserId': currentUser.id,
      'toUserId': friendId,
      'fromUsername': currentUser.displayName,
    });

    debugPrint('?? Inviting friend: $friendId');
  }

  /// ???? ???? ????
  void acceptFriendInvite(String gameRoomId) {
    _socket?.emit('accept_invite', {'gameRoomId': gameRoomId});
  }

  /// ??? ???? ????
  void rejectFriendInvite(String gameRoomId) {
    _socket?.emit('reject_invite', {'gameRoomId': gameRoomId});
  }

  /// ????? ???? ?? ??????
  void makeMove(int position) {
    if (!_isMyTurn ||
        position < 0 ||
        position >= 9 ||
        _board[position].isNotEmpty) {
      return;
    }

    _board[position] = _mySymbol;
    _isMyTurn = false;

    _socket?.emit('make_move', {
      'gameRoomId': _gameRoomId,
      'position': position,
      'symbol': _mySymbol,
    });

    notifyListeners();
  }

  /// ?????? ??????
  void leaveGame() {
    if (_gameRoomId != null) {
      _socket?.emit('leave_game', {'gameRoomId': _gameRoomId});
    }
    _resetGameState();
    notifyListeners();
  }

  /// معالجة العثور على مباراة
  void _handleMatchFound(Map<String, dynamic> data) {
    try {
      _gameRoomId = data['roomId'];
      _mySymbol = data['symbol'] ?? 'X';
      _isMyTurn = data['isYourTurn'] ?? (_mySymbol == 'X');
      _gameStatus = 'playing';

      // معلومات الخصم
      if (data['opponent'] != null) {
        // يمكن إضافة معالجة معلومات الخصم هنا
      }

      _board = List.filled(9, '');
      notifyListeners();
    } catch (e) {
      debugPrint('Error handling match found: $e');
    }
  }

  /// معالجة حركة الخصم
  void _handleOpponentMove(Map<String, dynamic> data) {
    try {
      final position = data['position'];
      final symbol = data['symbol'];

      if (position != null && position >= 0 && position < 9) {
        _board[position] = symbol ?? 'O';
        _isMyTurn = true;

        // التحقق من انتهاء اللعبة
        _checkGameEnd();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error handling opponent move: $e');
    }
  }

  /// معالجة انتهاء اللعبة
  void _handleGameOver(Map<String, dynamic> data) {
    try {
      _winner = data['winner'];
      _gameStatus = 'finished';
      notifyListeners();
    } catch (e) {
      debugPrint('Error handling game over: $e');
    }
  }

  /// إعادة تعيين حالة اللعبة
  void _resetGameState() {
    _gameRoomId = null;
    _opponent = null;
    _board = List.filled(9, '');
    _isMyTurn = false;
    _mySymbol = '';
    _gameStatus = 'waiting';
    _winner = null;
  }

  /// التحقق من انتهاء اللعبة
  void _checkGameEnd() {
    // فحص الصفوف
    for (int i = 0; i < 9; i += 3) {
      if (_board[i].isNotEmpty &&
          _board[i] == _board[i + 1] &&
          _board[i] == _board[i + 2]) {
        _winner = _board[i];
        _gameStatus = 'finished';
        return;
      }
    }

    // فحص الأعمدة
    for (int i = 0; i < 3; i++) {
      if (_board[i].isNotEmpty &&
          _board[i] == _board[i + 3] &&
          _board[i] == _board[i + 6]) {
        _winner = _board[i];
        _gameStatus = 'finished';
        return;
      }
    }

    // فحص الأقطار
    if (_board[0].isNotEmpty &&
        _board[0] == _board[4] &&
        _board[0] == _board[8]) {
      _winner = _board[0];
      _gameStatus = 'finished';
      return;
    }

    if (_board[2].isNotEmpty &&
        _board[2] == _board[4] &&
        _board[2] == _board[6]) {
      _winner = _board[2];
      _gameStatus = 'finished';
      return;
    }

    // فحص التعادل
    if (!_board.contains('')) {
      _winner = 'draw';
      _gameStatus = 'finished';
    }
  }

  /// مكافأة الفائز
  Future<void> _rewardWinner() async {
    try {
      final currentUser = _authService.currentUserModel;
      if (currentUser.id == _playerId && _winner == _mySymbol) {
        const int winReward = 10; // 10 جوهرة للفوز

        // TODO: Implement updateUserModel method in AuthService to update gems
        debugPrint('🎉 Reward added: $winReward gems');
      }
    } catch (e) {
      debugPrint('❌ Error adding reward: $e');
    }
  }

  /// ?????? ?? ?????
  bool checkWin(String symbol) {
    // ?????? ???????
    for (int i = 0; i < 9; i += 3) {
      if (_board[i] == symbol &&
          _board[i + 1] == symbol &&
          _board[i + 2] == symbol) {
        return true;
      }
    }

    // ?????? ????????
    for (int i = 0; i < 3; i++) {
      if (_board[i] == symbol &&
          _board[i + 3] == symbol &&
          _board[i + 6] == symbol) {
        return true;
      }
    }

    // ?????? ???????
    if (_board[0] == symbol && _board[4] == symbol && _board[8] == symbol) {
      return true;
    }
    if (_board[2] == symbol && _board[4] == symbol && _board[6] == symbol) {
      return true;
    }

    return false;
  }

  /// ?????? ?? ???????
  bool checkDraw() {
    return _board.every((cell) => cell.isNotEmpty) &&
        !checkWin('X') &&
        !checkWin('O');
  }

  @override
  void dispose() {
    disconnect();
    super.dispose();
  }
}
