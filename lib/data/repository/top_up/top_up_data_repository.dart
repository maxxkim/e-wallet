import 'package:zippy/data/api/api_util.dart';
import 'package:zippy/data/api/request/get_top_up_body.dart';
import 'package:zippy/domain/model/top_up/top_up_model.dart';
import 'package:zippy/domain/repository/top_up/top_up_repository.dart';

class TopUpDataRepository extends TopUpRepository {
  final ApiUtil _apiUtil;

  TopUpDataRepository(this._apiUtil);
}
