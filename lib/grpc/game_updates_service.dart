import 'dart:async';

import 'package:batufo/engine/geometry/dart_geometry.dart';
import 'package:batufo/engine/tile_position.dart';
import 'package:batufo/generated/message_bus.pbgrpc.dart';
import 'package:batufo/grpc/game_loop.dart';
import 'package:batufo/grpc/message_types/game_state_event.dart';
import 'package:batufo/grpc/server_game/arena.dart';
import 'package:batufo/models/player_model.dart';
import 'package:batufo/utils/ids.dart';
import 'package:grpc/grpc.dart';

class Game {
  final int id;
  final List<PlayingClient> _clients;

  final GameLoop _gameLoop;

  Game(this.id, GameState gameState, {List<PlayingClient> clients})
      : _clients = clients ?? <PlayingClient>[],
        _gameLoop = GameLoop(gameState);

  void tryStart(Arena arena) => _gameLoop.tryStart(arena);

  void addClient(PlayingClient playingClient) {
    _clients.add(playingClient);
    final player = PlayerModel(
      id: playingClient.clientID,
      tilePosition: _getTilePosition(),
      angle: 0.0,
      velocity: Offset.zero,
      appliedThrust: false,
    );
    _gameLoop.addPlayer(player);
  }

  TilePosition _getTilePosition() {
    // TODO: derive tile position from tilemap and idx of player
    return TilePosition(1, 2, 20.0, 20.0);
  }

  Stream<GameState> get gameState$ => _gameLoop.gameState$;

  void dispose() {
    _gameLoop.dispose();
  }
}

class GameUpdatesService extends GameUpdatesServiceBase {
  int _currentGameID;
  final Map<int, Game> _games;

  GameUpdatesService() : _games = <int, Game>{};

  final _gameStateEvent$ = StreamController<GameStateEvent>.broadcast();
  Stream<GameStateEvent> get gameStateEvent$ => _gameStateEvent$.stream;

  Future<PlayingClient> play(ServiceCall call, PlayRequest request) {
    final game = _getOrCreateCurrentGame();

    final clientID = getRandomInt();
    // TODO(thlorenz): support multiple active arenas
    final arena = Arena.forLevel(request.levelName)..registerClient(clientID);
    final playingClient = PlayingClient()
      ..gameID = game.id
      ..clientID = clientID
      ..arena = arena.pack();

    game
      ..addClient(playingClient)
      ..tryStart(arena);
    return Future.value(playingClient);
  }

  Stream<GameStateEvent> subscribeGameStates(
    ServiceCall call,
    PlayingClient request,
  ) {
    final game = _games[request.gameID];
    assert(game != null, 'cannot find game ${request.gameID}');
    return game.gameState$.map((gs) {
      final event = GameStateEvent()..gameState = gs.pack();
      return event;
    });
  }

  Future<Empty> playingClientSync(
    ServiceCall call,
    Stream<PlayingClientEvent> request,
  ) {
    StreamSubscription<PlayingClientEvent> sub;
    sub = request.listen(
      _processPlayingClientEvent,
      onDone: () => sub.cancel(),
      onError: print,
      cancelOnError: true,
    );
    return Future.value(Empty());
  }

  void _processPlayingClientEvent(PlayingClientEvent event) {
    final client = event.client;
    final game = _games[client.gameID];
    assert(game != null, 'cannot find game with id ${client.gameID}');
    // TODO: tell the game about the player input
  }

  Game _getOrCreateCurrentGame() {
    Game game;
    if (_games.isEmpty) {
      _currentGameID = getRandomInt();
      final gameState = GameState();
      game = Game(_currentGameID, gameState);
      _games[_currentGameID] = game;
    } else {
      game = _games[_currentGameID];
    }
    return game;
  }

  void dispose() {
    if (!_gameStateEvent$.isClosed) _gameStateEvent$?.close();
    for (final game in _games.values) game.dispose();
  }
}
