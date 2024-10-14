import 'package:flutter/material.dart';
import 'package:zippy/presentation/screen/payment/widgets/balance_display.dart';
import 'package:zippy/presentation/screen/payment/widgets/transaction_form_display.dart';
import 'package:zippy/presentation/widget/custom_contact_button.dart';
import 'package:zippy/presentation/widget/custom_contact_button_row.dart';
//import 'package:flutter_bloc/flutter_bloc.dart';
//import 'package:zippy/presentation/bloc/dashboard/dashboard_cubit.dart';

class PaymentScreen extends StatelessWidget {
   PaymentScreen({super.key});
    final TextEditingController emailController = TextEditingController();
    final TextEditingController amountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New payment')),
      body:  Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              const BalanceDisplay(amount: 3500),
              const SizedBox(height: 8),
              Center(
                child: ContactButtonRow(
                  buttons: [
                    ContactButton(
                      color: Theme.of(context).colorScheme.primary,
                      icon: Icons.add,
                      subtitle: 'New\nContact',
                    ),
                    ContactButton(
                      color: Theme.of(context).colorScheme.primary,
                      icon: Icons.arrow_right_alt,
                      subtitle: 'New\nTransaction',
                    ),
                    ContactButton(
                      color: Theme.of(context).colorScheme.tertiaryContainer,
                      icon: Icons.person,
                      subtitle: 'Enrique\nIglesias',
                    ),
                    ContactButton(
                      color: Theme.of(context).colorScheme.tertiaryContainer,
                      icon: Icons.person,
                      subtitle: 'Lionel\nMessi',
                    ),
                    ContactButton(
                      color: Theme.of(context).colorScheme.tertiaryContainer,
                      icon: Icons.person,
                      subtitle: 'Juan\nPeron',
                    ),
                    ContactButton(
                      color: Theme.of(context).colorScheme.tertiaryContainer,
                      icon: Icons.person,
                      subtitle: 'John\nDoe',
                    ),
                    ContactButton(
                      color: Theme.of(context).colorScheme.tertiaryContainer,
                      icon: Icons.person,
                      subtitle: 'Ximena\nMerino',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const TransactionFormDisplay(),
              const SizedBox(height: 4),
            ],
          ),
        ),
      ),
    );
  }


}
