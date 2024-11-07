import 'package:zippy/data/api/api_util.dart';
import 'package:zippy/domain/repository/top_up/top_up_repository.dart';

class TopUpDataRepository extends TopUpRepository {
  final ApiUtil _apiUtil;

  TopUpDataRepository(this._apiUtil);
}
