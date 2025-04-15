import 'package:dartchess/src/models.dart';
import 'package:rooktook/src/model/analysis/opening_service.dart';
import 'package:rooktook/src/model/common/chess.dart';

class FakeOpeningService implements OpeningService {
  @override
  Future<FullOpening?> fetchFromMoves(Iterable<Move> moves) {
    // TODO: implement fetchFromMoves when needed
    return Future.value(null);
  }
}
