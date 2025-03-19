import 'package:zippy/domain/model/offer/banner_model.dart';
import 'package:zippy/domain/model/transaction/transaction_model.dart';

abstract class DashboardRepository {
  Future<num> getBalance();
  Future<List<Transaction>> getTransactions();
  Future<BannerResponse> getBanners();
}
