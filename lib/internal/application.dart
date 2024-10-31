import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:zippy/data/repository/auth/auth_data_repository.dart';
import 'package:zippy/data/repository/dashboard/dashboard_data_repository.dart';
import 'package:zippy/domain/repository/auth/auth_repository.dart';
import 'package:zippy/domain/repository/dashboard/dashboard_repository.dart';
import 'package:zippy/presentation/app_router.dart';
import 'package:zippy/presentation/session/session_cubit.dart';
import 'package:zippy/presentation/theme/app_theme.dart';
import 'package:zippy/presentation/theme/app_theme_dark.dart';
import 'package:zippy/domain/repository/top_up/top_up_repository.dart';
import 'package:zippy/data/repository/top_up/top_up_data_repository.dart';
import 'package:zippy/data/api/api_util.dart';
import 'package:zippy/data/api/service/api_service.dart';
import 'package:zippy/presentation/theme/theme_cubit.dart';

class ZippyApp extends StatelessWidget {
  const ZippyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return KeyboardDismisser(
      gestures: const [
        GestureType.onTap,
        GestureType.onPanUpdateDownDirection,
      ],
      child: MultiRepositoryProvider(
        providers: [
          RepositoryProvider<ApiService>(
            create: (context) => ApiService(),
          ),
          RepositoryProvider<ApiUtil>(
            create: (context) => ApiUtil(
              RepositoryProvider.of<ApiService>(context),
            ),
          ),
          RepositoryProvider<TopUpRepository>(
            create: (context) => TopUpDataRepository(
              RepositoryProvider.of<ApiUtil>(context),
            ),
          ),
          RepositoryProvider<DashboardRepository>(
            create: (context) => DashboardDataRepository(
                RepositoryProvider.of<ApiUtil>(context)),
          ),
          RepositoryProvider<AuthRepository>(
            create: (context) =>
                AuthDataRepository(RepositoryProvider.of<ApiUtil>(context)),
          ),
        ],
        child: MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) => ThemeCubit(),
            ),
            BlocProvider(
              create: (context) => SessionCubit(),
            ),
          ],
          child: BlocBuilder<ThemeCubit, AppTheme>(
            builder: (context, theme) {
              context.read<SessionCubit>().checkAuthentication();
              return MaterialApp.router(
                routerConfig: appRouter,
                title: 'Zippy',
                theme: (theme == AppTheme.light) ? appTheme : appThemeDark,
              );
            },
          ),
        ),
      ),
    );
  }
}
