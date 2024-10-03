import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:zippy/presentation/widget/custom_rectangular_button.dart';
//import 'package:flutter_bloc/flutter_bloc.dart';
//import 'package:zippy/presentation/bloc/dashboard/dashboard_cubit.dart';

class PaymentInfoScreen extends StatelessWidget {
  const PaymentInfoScreen({super.key});

  @override
   Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment info')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center, // Убедитесь, что все элементы центрированы
          children: <Widget>[
            const SizedBox(height: 24),
            Center( // Добавлено Center для текста
              child: Text(
                'Transaction completed\n successfully!', // Исправлена опечатка
                textAlign: TextAlign.center, // Центрируем текст
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Top Up',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  SvgPicture.asset(
                    'assets/images/icon_tick.svg',
                    height: 48.0,
                    width: 48.0,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '1808.00',
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
                          '\$ 1356.32',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        Text(" → ", style: Theme.of(context).textTheme.titleMedium),
                        Text(
                          '\$ 1342.24',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ),
                ],
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
                        height: 48.0,
                        width: 48.0,
                      ),
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
                        height: 48.0,
                        width: 48.0,
                      ),
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
                        height: 48.0,
                        width: 48.0,
                      ),
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
}