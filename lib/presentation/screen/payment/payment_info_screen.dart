import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:zippy/domain/model/transaction/transaction_model.dart';
import 'package:zippy/presentation/widget/custom_rectangular_button.dart';
//import 'package:flutter_bloc/flutter_bloc.dart';
//import 'package:zippy/presentation/bloc/dashboard/dashboard_cubit.dart';

class PaymentInfoScreen extends StatelessWidget {
  final Transaction transaction;
  const PaymentInfoScreen({required this.transaction, super.key});

  @override
   Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment info')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center, // Убедитесь, что все элементы центрированы
          children: <Widget>[
            const SizedBox(height: 40),
            Center( // Добавлено Center для текста
              child: Text(
                getText(context),
                textAlign: TextAlign.center, // Центрируем текст
                style: Theme.of(context).textTheme.displayLarge,
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.only(left: 32.0, right: 32.0),
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: getContainer(context),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if(transaction.type == "deposit")
                      Text(
                        'Top Up',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    if(transaction.type == "withdraw")
                      Text(
                        'Withdraw',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    const SizedBox(height: 16),
                    getIcon(context),
                    const SizedBox(height: 16),
                    Text(
                      '${getSign(context)} ${transaction.amount} ${transaction.currency}',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.center, // Центрируем содержимое
                      child: Row(
                        mainAxisSize: MainAxisSize.min, 
                        children: [
                          Text("Balance: ", style: Theme.of(context).textTheme.titleMedium),
                          Text(
                            '${transaction.currency} 1356.32',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                          Text(" → ", style: Theme.of(context).textTheme.titleMedium),
                          Text(
                            '${transaction.currency} ${1356.32 + transaction.amount.roundToDouble()}',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            Center( // Центрируем Row с иконками
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center, // Центрируем содержимое Row
                children: [
                  Column(
                    children: [
                      SvgPicture.asset(
                        'assets/images/icon_support_lg.svg',
                        height: 40.0,
                        width: 40.0,
                      ),
                      const SizedBox(height: 4,),
                      Text(
                        'Help',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(width: 32),
                  Column(
                    children: [
                      SvgPicture.asset(
                        'assets/images/icon_copy_lg.svg',
                        height: 40.0,
                        width: 40.0,
                      ),
                      const SizedBox(height: 4,),
                      Text(
                        'Copy',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(width: 32),
                  Column(
                    children: [
                      SvgPicture.asset(
                        'assets/images/icon_share_lg.svg',
                        height: 40.0,
                        width: 40.0,
                      ),
                      const SizedBox(height: 4,),
                      Text(
                        'Share',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(right: 40,left: 40),
              child: RectangularButton(
                label: "Home",
                onPressed: () {
                  context.go('/dashboard');
                },
              ),
            ),
            const SizedBox(height: 88),
          ],
        ),
      ),
    );
  }
  String getSign(BuildContext context)
  {
    if (transaction.type == "in") {
      return "+";
    }
    else {
      return "-";
    }
  }
  Color getContainer(BuildContext context)
  {
    if (transaction.status == "completed") {
      return Theme.of(context).colorScheme.secondaryContainer;
    }
    else if (transaction.status == "pending") {
      return Theme.of(context).colorScheme.onTertiaryContainer;
    }
    else {
      return Theme.of(context).colorScheme.onErrorContainer;
    }
  }
  Widget getIcon(BuildContext context){
    if (transaction.status == "completed") {
      return SvgPicture.asset(
                    'assets/images/icon_tick.svg',
                    height: 48.0,
                    width: 48.0,
                  );
    }
    else if (transaction.status == "pending") {
      return SvgPicture.asset(
                    'assets/images/icon_transaction_pending.svg',
                    height: 48.0,
                    width: 48.0,
                  );
    }
    else {
      return SvgPicture.asset(
                    'assets/images/icon_transaction_error.svg',
                    height: 48.0,
                    width: 48.0,
                  );
    }
  }
  String getText(BuildContext context){
    if (transaction.status == "completed") {
      return "Transaction was completed\nsuccessfully!";
    }
    else if (transaction.status == "pending") {
      return "Transaction is being\nprocessed!";
    }
    else {
      return "Transaction\nwas not complete!";
    }
  }
}