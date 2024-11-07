import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/domain/repository/dashboard/dashboard_repository.dart';
import 'package:zippy/domain/state/dashboard/dashboard_state.dart';
import 'package:zippy/presentation/bloc/dashboard/dashboard_cubit.dart';
import 'package:zippy/presentation/screen/dashboard/widgets/filter_button_row.dart';
import 'package:zippy/presentation/screen/dashboard/widgets/transaction_history_panel.dart';
import 'package:zippy/presentation/screen/error_screen.dart';
import 'package:zippy/presentation/session/session_cubit.dart';
import 'widgets/dashboard_display.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> months = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December",
    ];

    return FutureBuilder<DashboardCubit>(
        future: _createDashboardCubit(context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
                body: Center(
                    child: CircularProgressIndicator(
              color: Theme.of(context).colorScheme.primary,
            )));
          } else if (snapshot.hasError) {
            // Возвращаем ErrorScreen при возникновении ошибки
            return ErrorScreen(errorMessage: 'Error: ${snapshot.error}');
          } else if (snapshot.hasData) {
            final dashboardCubit = snapshot.data!;
            return BlocProvider.value(
              value: dashboardCubit,
              child: BlocBuilder<DashboardCubit, DashboardState>(
                builder: (context, state) {
                  if (state is DashboardStateLoaded) {
                    if (state.accessToken == null) {
                      context.go('/');
                    }
                    int currentIndex = months.indexOf(state.chosenMonth) + 1;
                    int startIndex = (currentIndex - 2).clamp(0, months.length);
                    int endIndex = (startIndex + 5).clamp(0, months.length);
                    return Scaffold(
                      appBar: AppBar(
                        actions: [
                          Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: IconButton(
                              icon: const Icon(Icons.exit_to_app),
                              onPressed: () {
                                logout(context);
                                context.go('/');
                              },
                            ),
                          ),
                        ],
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        toolbarHeight: 40,
                      ),
                      body: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            DashboardDisplay(balance: state.balance),
                            const SizedBox(height: 16),
                            FilterButtonRow(state: state),
                            const SizedBox(height: 16),
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .tertiaryContainer,
                                  borderRadius: BorderRadius.circular(32),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    if (state.filterType == FilterType.period)
                                      Container(
                                        height: 48.0,
                                        decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .scaffoldBackgroundColor,
                                          border: Border.all(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                            width: 1,
                                          ),
                                          borderRadius:
                                              const BorderRadius.vertical(
                                            top: Radius.circular(16),
                                            bottom: Radius.circular(16),
                                          ),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16.0),
                                          child: ListView.builder(
                                            scrollDirection: Axis.horizontal,
                                            itemCount: endIndex - startIndex,
                                            itemBuilder: (context, index) {
                                              String month =
                                                  months[startIndex + index];
                                              bool isCurrentMonth =
                                                  month == state.chosenMonth;
                                              return GestureDetector(
                                                onTap: () => context
                                                    .read<DashboardCubit>()
                                                    .selectMonth(month),
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 16.0),
                                                  child: Center(
                                                    child: Text(
                                                      month,
                                                      style: isCurrentMonth
                                                          ? Theme.of(context)
                                                              .textTheme
                                                              .headlineSmall
                                                          : Theme.of(context)
                                                              .textTheme
                                                              .bodyMedium,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    Expanded(
                                      child: TransactionHistoryPanel(
                                        state: state,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: GestureDetector(
                                            onTap: () => context
                                                .go('/dashboard/history'),
                                            child: SizedBox(
                                              height: 56,
                                              child: Center(
                                                child: Text(
                                                  "View All",
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .titleMedium,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  } else if (state is DashboardStateError) {
                    GoRouter.of(context).go('/'); // Redire
                    return ErrorScreen(errorMessage: state.errorMessage);
                  } else if (state is DashboardStateLoggedOut) {
                    GoRouter.of(context).go('/'); // Redire
                    return const ErrorScreen(errorMessage: "Sign in failed");
                  } else {
                    return const ErrorScreen(errorMessage: "Unknown error");
                  }
                },
              ),
            );
          } else {
            return const Center(child: Text("Пошел нахуй"));
          }
        });
  }

  void logout(BuildContext context) {
    context.read<DashboardCubit>().logout();
    context.read<SessionCubit>().checkAuthentication();
  }

  Future<DashboardCubit> _createDashboardCubit(BuildContext context) async {
    final dashboardRepository =
        RepositoryProvider.of<DashboardRepository>(context);
    final cubit = await DashboardCubit.create(dashboardRepository);
    return cubit;
  }
}
