import 'package:zippy/data/api/api_util.dart';
import 'package:zippy/domain/model/top_up/top_up_initiate_model.dart';
import 'package:zippy/domain/model/top_up/top_up_model.dart';
import 'package:zippy/domain/repository/top_up/top_up_repository.dart';

class TopUpDataRepository extends TopUpRepository {
  final ApiUtil _apiUtil;

  TopUpDataRepository(this._apiUtil);

  @override
  Future<TopUp> getProviders() {
    return _apiUtil.getProviders();
  }

  @override
  Future<TopUpInitiate> initiateTopUp(Map<String, dynamic> data) {
    return _apiUtil.initiateTopUp(data);
  }
}
