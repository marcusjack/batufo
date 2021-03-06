import 'package:batufo/server/game/game_loop.dart';
import 'package:batufo/shared/arena/arena.dart';
import 'package:batufo/shared/controllers/game_controller.dart';
import 'package:batufo/shared/dart_types/dart_types.dart';
import 'package:batufo/shared/engine/geometry/dart_geometry.dart' show Offset;
import 'package:batufo/shared/game_props.dart';
import 'package:batufo/shared/generated/message_bus.pb.dart' show PlayingClient;
import 'package:batufo/shared/messaging/player_inputs.dart';
import 'package:batufo/shared/models/game_state.dart';
import 'package:batufo/shared/models/player_model.dart';

class ServerGame {
  final int gameID;
  final List<PlayingClient> _clients;
  final Arena arena;

  final GameLoop _gameLoop;

  ServerGame(
    this.gameID, {
    @required this.arena,
    @required GameState gameState,
    List<PlayingClient> clients,
  })  : _clients = clients ?? <PlayingClient>[],
        _gameLoop = GameLoop(GameController(arena, gameState));

  bool get isFull => arena.isFull(_clients.length);

  bool tryStart() {
    if (!isFull) return false;
    _gameLoop.start(gameID);
    return true;
  }

  void addClient(PlayingClient playingClient) {
    assert(!isFull, 'cannot add more clients to arena');
    _clients.add(playingClient);

    final player = PlayerModel(
      id: playingClient.clientID,
      tilePosition: arena.playerPosition(_clients.length - 1),
      angle: 0.0,
      velocity: Offset.zero,
      health: GameProps.playerTotalHealth,
      appliedThrust: false,
      shotBullet: false,
    );
    _gameLoop.addPlayer(player);
  }

  void syncPlayerInputs(int clientID, PlayerInputs inputs) {
    _gameLoop.syncPlayerInputs(clientID, inputs);
  }

  Stream<GameState> get gameState$ => _gameLoop.gameState$;

  void dispose() {
    _gameLoop.dispose();
  }
}
