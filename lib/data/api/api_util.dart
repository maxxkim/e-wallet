import 'package:flutter_contacts/contact.dart';
import 'package:zippy/data/api/service/api_service.dart';
import 'package:zippy/data/mapper/auth/auth_initiate_mapper.dart';
import 'package:zippy/data/mapper/auth/auth_refresh_mapper.dart';
import 'package:zippy/data/mapper/auth/auth_verify_mapper.dart';
import 'package:zippy/data/mapper/auth/token_verification_mapper.dart';
import 'package:zippy/data/mapper/dashboard/balance_mapper.dart';
import 'package:zippy/data/mapper/dashboard/transaction_mapper.dart';
import 'package:zippy/data/mapper/topUp/top_up_initiate_mapper.dart';
import 'package:zippy/data/mapper/topUp/top_up_mapper.dart';
import 'package:zippy/data/mapper/transfer/transfer_initiate_mapper.dart';
import 'package:zippy/data/mapper/withdrawal/withdrawal_initiate.dart';
import 'package:zippy/data/mapper/withdrawal/withdrawal_mapper.dart';
import 'package:zippy/domain/model/auth/auth_inititate_model.dart';
import 'package:zippy/domain/model/auth/auth_refresh_mode.dart';
import 'package:zippy/domain/model/auth/auth_verify_model.dart';
import 'package:zippy/domain/model/contacts/contact_model.dart';
import 'package:zippy/domain/model/offer/activation_model.dart';
import 'package:zippy/domain/model/offer/category_model.dart';
import 'package:zippy/domain/model/offer/offer_model.dart';
import 'package:zippy/domain/model/qr/payment_response_model.dart';
import 'package:zippy/domain/model/qr/qr_payment_model.dart';
import 'package:zippy/domain/model/top_up/top_up_initiate_model.dart';
import 'package:zippy/domain/model/top_up/top_up_model.dart';
import 'package:zippy/domain/model/transaction/transaction_model.dart';
import 'package:zippy/domain/model/transfer/transfer_model.dart';
import 'package:zippy/domain/model/withdrawal/withdrawal_initiate_model.dart';
import 'package:zippy/domain/model/withdrawal/withdrawal_model.dart';

class ApiUtil {
  final ApiService _apiService;

  ApiUtil(this._apiService);

  Future<List<Transaction>> getTransactions() async {
    final result = await _apiService.getTransactions();
    return TransactionMapper.fromApi(result);
  }

  Future<num> getBalance() async {
    final result = await _apiService.getBalance();
    return BalanceMapper.fromApi(result);
  }

  Future<AuthInitiate> initiateAuth(String phone, String countryCode) async {
    final result = await _apiService.initiateAuth(phone, countryCode);
    return AuthInitiateMapper.fromApi(result);
  }

  Future<AuthVerify> verifyAuth(
    String code,
    String phone,
    String userId,
  ) async {
    final result = await _apiService.verifyAuth(code, phone, userId);
    return AuthVerifyMapper.fromApi(result);
  }

  Future<AuthRefresh> refreshAuth(String refreshToken) async {
    final result = await _apiService.refreshAuth(refreshToken);
    return AuthRefreshMapper.fromApi(result);
  }

  Future<bool> verifyToken(String accessToken) async {
    final result = await _apiService.verifyToken(accessToken);
    return TokenVerificationMapper.fromApi(result);
  }

  Future<TopUp> getProviders() async {
    final result = await _apiService.getProviders();
    return TopUpMapper.fromApi(result);
  }

  Future<TopUpInitiate> initiateTopUp(Map<String, dynamic> data) async {
    final result = await _apiService.initiateTopUp(data);
    return TopUpInitiateMapper.fromApi(result);
  }

  Future<Withdrawal> getWithdrawalProviders() async {
    final result = await _apiService.getWithdrawalProviders();
    return WithdrawalMapper.fromApi(result);
  }

  Future<WithdrawalInitiate> initiateWithdrawal(
      Map<String, dynamic> data) async {
    final result = await _apiService.initiateWithdrawal(data);
    return WithdrawalInitiateMapper.fromApi(result);
  }

  Future<TransferInitiate> initiateTransfer(Map<String, dynamic> data) async {
    final result = await _apiService.initiateTransfer(data);
    return TransferInitiateMapper.fromApi(result);
  }

  Future<QrPaymentResponse> checkQrCode(String hash) async {
    final result = await _apiService.checkQrCode(hash);
    return QrPaymentResponse.fromJson(result);
  }

  Future<PaymentResponse> processPayment(String hash, double amount) async {
    final result = await _apiService.processPayment(hash, amount);
    return PaymentResponse.fromJson(result); // Now we can parse the result
  }

  Future<List<ContactModel>> getContacts() async {
    return _apiService.getContacts();
  }

  Future<ContactModel> addContact(String phone, String? nickname) async {
    return _apiService.addContact(phone, nickname);
  }

  Future<ContactModel> updateContact(
      int id, String phone, String? nickname) async {
    return _apiService.updateContact(id, phone, nickname);
  }

  Future<void> deleteContact(String phone) async {
    await _apiService.deleteContact(phone);
  }

  Future<List<ContactModel>> getRecentContacts() async {
    final result = await _apiService.getRecentContacts();
    return result;
  }

  Future<List<Activation>> getActivations({int limit = 20}) async {
    final result = await _apiService.getActivations(limit);
    return result;
  }

  Future<Activation> activateOffer(int offerId) async {
    final result = await _apiService.activateOffer(offerId);
    return result;
  }

  Future<List<Offer>> getOffers({
    int page = 1,
    int limit = 100,
    String? search,
    int? categoryId,
    String? merchantId,
    String? sortBy = 'desc',
    String? filterFrom,
    String? filterTo,
    String? filterType,
  }) async {
    final result = await _apiService.getOffers(
      page: page,
      limit: limit,
      search: search,
      categoryId: categoryId,
      merchantId: merchantId,
      sortBy: sortBy,
      filterFrom: filterFrom,
      filterTo: filterTo,
      filterType: filterType,
    );
    return result;
  }

  Future<List<Offer>> getTopOffers({int limit = 5}) async {
    final result = await _apiService.getTopOffers(limit);
    return result;
  }

  Future<List<CategoryModel>> getCategories(
      {int limit = 20, String? search}) async {
    final result =
        await _apiService.getCategories(limit: limit, search: search);
    return result.categories;
  }

  Future<List<CategoryModel>> getFavoriteCategories({int limit = 100}) async {
    final result = await _apiService.getFavoriteCategories(limit: limit);
    return result.categories;
  }

  Future<List<CategoryModel>> addFavoriteCategory(int categoryId) async {
    final result = await _apiService.addFavoriteCategory(categoryId);
    return result.categories;
  }

  Future<List<CategoryModel>> deleteFavoriteCategory(int categoryId) async {
    final result = await _apiService.deleteFavoriteCategory(categoryId);
    return result.categories;
  }
}
