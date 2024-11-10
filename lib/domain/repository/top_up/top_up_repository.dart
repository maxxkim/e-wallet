import 'package:zippy/domain/model/top_up/top_up_initiate_model.dart';
import 'package:zippy/domain/model/top_up/top_up_model.dart';

abstract class TopUpRepository {
  Future<TopUp> getProviders();
  Future<TopUpInitiate> initiateTopUp(Map<String, dynamic> data);
}
