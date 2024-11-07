import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/domain/state/dashboard/dashboard_state.dart';
import 'package:zippy/presentation/screen/history/widgets/transaction_tile.dart';

class TransactionHistoryPanel extends StatelessWidget {
  final DashboardStateLoaded state;
  const TransactionHistoryPanel({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: state.filteredTransactions?.length ?? 0,
      itemBuilder: (context, index) {
        return Column(
          children: [
            TransactionTile(
              transaction: state.filteredTransactions![index],
              onIconTap: () {
                // Перейти к новому экрану с передачей данных транзакции
                context.go('/dashboard/infoDashboard',
                    extra: state.filteredTransactions![index]);
              },
            ),
            Container(
              height: 1,
              color: Theme.of(context).scaffoldBackgroundColor,
            ),
          ],
        );
      },
    );
  }
}
