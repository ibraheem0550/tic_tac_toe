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
      // تهيئة اتصال السوكت الجديد
      _socket = IO.io(
        'http://localhost:3000',
        IO.OptionBuilder()
            .setTransports(['websocket', 'polling'])
            .enableAutoConnect()
            .setTimeout(20000)
            .build(),
      );

      _socket?.connect();

      _socket?.onConnect((_) {
        _isConnected = true;
        debugPrint('? Connected to game server');

        // ????? ?????? ???????? ??? ???????
        final currentUser = _authService.currentUserModel;
        if (currentUser != null) {
          registerPlayer(currentUser);
        }

        notifyListeners();
      });

      _socket?.onDisconnect((_) {
        _isConnected = false;
        debugPrint('? Disconnected from game server');
        _resetGameState();
        notifyListeners();
      });

      _socket?.onConnectError((error) {
        debugPrint('? Connection error: $error');
        _isConnected = false;
        notifyListeners();
      });

      _setupEventListeners();

      // ?????? ??????? ???? 5 ?????
      await Future.delayed(const Duration(seconds: 5));

      if (!_isConnected) {
        throw Exception('??? ?? ??????? ???????');
      }
    } catch (e) {
      debugPrint('? Connection error: $e');
      rethrow;
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

  /// ????? ?????? ???????
  void _setupEventListeners() {
    // ????? ????? ??????
    _socket?.on('player_registered', (data) {
      debugPrint('? Player registered: $data');
      _playerId = data['playerId'];
    });

    // ????? ??? ?????? ??? ??????
    _socket?.on('match_found', (data) {
      debugPrint('?? Match found: $data');
      _handleMatchFound(data);
    });

    // ????? ???? ???? ?????
    _socket?.on('move_made', (data) {
      debugPrint('?? Move made: $data');
      _handleMoveMade(data);
    });

    // ????? ????? ??????
    _socket?.on('game_ended', (data) {
      debugPrint('?? Game ended: $data');
      _handleGameEnded(data);
    });

    // ????? ????? ????
    _socket?.on('player_left', (data) {
      debugPrint('?? Player left: $data');
      _handlePlayerLeft(data);
    });

    // ????? ?????
    _socket?.on('error', (data) {
      debugPrint('? Game server error: $data');
    });

    // ????? ??????? ??????
    _socket?.on('game_info', (data) {
      debugPrint('?? Game info: $data');
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

  /// ??????? ?? ?????? ??? ??????
  void _handleMatchFound(dynamic data) {
    _gameRoomId = data['gameId'];
    _mySymbol = data['yourSymbol'];
    _gameStatus = 'playing';
    _isMyTurn = data['currentPlayer'] == _mySymbol;
    _board = List.filled(9, ''); // ????? ????? ??????

    // ????? ?????? ?????
    Map<String, dynamic>? opponentData;
    final currentUser = _authService.currentUser;

    if (currentUser != null) {
      // ????? ?? ?? ?????
      if (data['player1']['socketId'] != _playerId) {
        opponentData = data['player1'];
      } else {
        opponentData = data['player2'];
      }
    }

    if (opponentData != null) {
      _opponent = UserModels.User(
        id: opponentData['userId'] ?? opponentData['socketId'],
        email: opponentData['email'] ?? '',
        displayName: opponentData['username'] ?? '????',
        photoURL: opponentData['avatarUrl'],
        provider: UserModels.AuthProvider.email,
        gems: opponentData['gems'] ?? 0,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
        profile: UserModels.UserProfile(
          preferences: const UserModels.UserPreferences(),
          gameStats: UserModels.GameStats.empty(
            opponentData['userId'] ?? opponentData['socketId'],
          ),
        ),
        linkedProviders: [UserModels.AuthProvider.email],
        linkedAccounts: [],
      );
    }
    debugPrint(
      '?? Match found! Room: $_gameRoomId, Symbol: $_mySymbol, My turn: $_isMyTurn',
    );
    notifyListeners();
  }

  /// ??????? ?? ???? ????
  void _handleMoveMade(dynamic data) {
    int position = data['position'];
    String symbol = data['symbol'];

    _board[position] = symbol;
    _isMyTurn = !_isMyTurn; // ????? ?????

    debugPrint('?? Move made at position $position with symbol $symbol');
    notifyListeners();
  }

  /// ??????? ?? ?????? ??????
  void _handleGameEnded(dynamic data) {
    _gameStatus = 'finished';
    _winner = data['winner'];
    _isMyTurn = false;

    // ????? ???????? ??????
    if (_winner == _playerId) {
      _rewardWinner();
    }

    debugPrint('?? Game ended! Winner: $_winner');
    notifyListeners();
  }

  /// ??????? ?? ?????? ????
  void _handlePlayerLeft(dynamic data) {
    _gameStatus = 'finished';
    _winner = _playerId; // ??? ?????? ??? ???? ?????
    _isMyTurn = false;

    debugPrint('?? Opponent left the game');
    notifyListeners();
  }

  /// ?????? ??????
  Future<void> _rewardWinner() async {
    try {
      final currentUser = _authService.currentUserModel;
      if (currentUser == null) return;

      const int winReward = 10; // 10 ????? ?????

      // TODO: Implement updateUserModel method in AuthService to update gems
      debugPrint('?? Reward added: $winReward gems');
    } catch (e) {
      debugPrint('? Error adding reward: $e');
    }
  }

  /// ????? ????? ???? ??????
  void _resetGameState() {
    _gameRoomId = null;
    _playerId = null;
    _currentGame = null;
    _opponent = null;
    _board = List.filled(9, '');
    _isMyTurn = false;
    _mySymbol = '';
    _gameStatus = 'waiting';
    _winner = null;
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
