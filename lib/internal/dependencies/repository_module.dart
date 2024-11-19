import 'package:zippy/data/repository/auth/auth_data_repository.dart';
import 'package:zippy/data/repository/dashboard/dashboard_data_repository.dart';
import 'package:zippy/data/repository/top_up/top_up_data_repository.dart';
import 'package:zippy/data/repository/transfer/transfer_data_repository.dart';
import 'package:zippy/data/repository/withdrawal/withdrawal_data_repository.dart';
import 'package:zippy/domain/repository/auth/auth_repository.dart';
import 'package:zippy/domain/repository/dashboard/dashboard_repository.dart';
import 'package:zippy/domain/repository/top_up/top_up_repository.dart';
import 'package:zippy/domain/repository/transfer/transfer_repository.dart';
import 'package:zippy/domain/repository/withdrawal/withdrawal_repository.dart';

import 'api_module.dart';

class RepositoryModule {
  static TopUpRepository? _topUpRepository;
  static WithdrawalRepository? _withdrawalRepository;
  static TransferRepository? _transferRepository;
  static DashboardRepository? _dashboardRepository;
  static AuthRepository? _authRepository;

  static TopUpRepository topUpRepository() {
    _topUpRepository ??= TopUpDataRepository(
      ApiModule.apiUtil(),
    );
    return _topUpRepository!;
  }

  static WithdrawalRepository withdrawalRepository() {
    _withdrawalRepository ??= WithdrawalDataRepository(
      ApiModule.apiUtil(),
    );
    return _withdrawalRepository!;
  }

  static TransferRepository transferRepository() {
    _transferRepository ??= TransferDataRepository(
      ApiModule.apiUtil(),
    );
    return _transferRepository!;
  }

  static DashboardRepository dashboardRepository() {
    _dashboardRepository ??= DashboardDataRepository(
      ApiModule.apiUtil(),
    );
    return _dashboardRepository!;
  }

  static AuthRepository authRepository() {
    _authRepository ??= AuthDataRepository(
      ApiModule.apiUtil(),
    );
    return _authRepository!;
  }
}
