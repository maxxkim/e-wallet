import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zippy/presentation/screen/payment/widgets/provider_display.dart';
import 'package:zippy/presentation/widget/custom_rectangular_button.dart';
import 'package:zippy/presentation/widget/custom_text_field.dart';
import 'package:zippy/domain/state/withdraw/withdraw_state.dart';
import 'package:zippy/presentation/bloc/withdraw/withdraw_cubit.dart';

class WithdrawScreen extends StatelessWidget {
  WithdrawScreen({Key? key}) : super(key: key);

  final TextEditingController emailController = TextEditingController();
  final TextEditingController amountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => WithdrawCubit(context.read()),
      child: BlocConsumer<WithdrawCubit, WithdrawState>(
        listener: (context, state) {
          if (state.isSuccess) {
            context.go('/dashboard/Withdraw/info');
          } else if (state.message.isNotEmpty) {
            _showErrorDialog(context, state.message);
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(title: const Text('New Withdraw')),
            body: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: <Widget>[
                  const SizedBox(height: 8),
                  const ProviderDisplay(title: 'Top Up', iconData: Icons.money),
                  const SizedBox(height: 8),
                  CustomTextField(
                    controller: emailController,
                    labelText: 'Email',
                    hintText: 'Enter email',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 8),
                  CustomTextField(
                    controller: amountController,
                    labelText: 'Amount',
                    hintText: 'Enter amount',
                    keyboardType: TextInputType.number,
                  ),
                  const Spacer(),
                  RectangularButton(
                    label: 'Pay',
                    onPressed: () => _sendTransaction(context),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          );
        },
      ),
    );
  }


Future<void> _sendTransaction(BuildContext context) async {
  String email = emailController.text;
  String amount = amountController.text;

  if (email.isEmpty || !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
    _showErrorDialog(context, 'Invalid email address');
    return;
  }
  
  if (amount.isEmpty || double.tryParse(amount) == null || double.parse(amount) <= 0) {
    _showErrorDialog(context, 'Please enter a valid amount greater than zero');
    return;
  }

  // Create the objData as a Map and then convert it to a JSON string
  final Map<String, dynamic> objDataMap = {};
   final String objDataJson = jsonEncode(objDataMap);

  // Create the transaction payload as a Map
  final Map<String, dynamic> transactionData = {
    'merchantId': "2020juegalopro-7j7g",
    'transactionId': DateTime.now().millisecondsSinceEpoch.toString(),
    'country': "CL",
    'currency': "CLP",
    'payMethod': "skin",
    'documentId': "111111111",
    'amount': "$amount.00",
    'email': email,
    'name': "User Name", // You might want to add a name field or get it from user profile
    'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
    'urlOk': "https://www.yourSite.com/okUser",
    'urlError': "https://www.yourSite.com/errorUser",
    'objData': objDataJson, // Use the JSON string here
  };

  // Print the transaction data
  print(transactionData);

  // Pass the transactionData to the getWithdraw method
  context.read<WithdrawCubit>().getWithdraw(
    merchantId: transactionData['merchantId'] ?? "",
    transactionId: transactionData['transactionId'] ?? "",
    country: transactionData['country'] ?? "",
    currency: transactionData['currency'] ?? "",
    payMethod: transactionData['payMethod'] ?? "",
    documentId: transactionData['documentId'] ?? "",
    amount: transactionData['amount'] ?? "",
    email: transactionData['email'] ?? "",
    name: transactionData['name'] ?? "",
    timestamp: transactionData['timestamp'] ?? "",
    urlOk: transactionData['urlOk'] ?? "",
    urlError: transactionData['urlError'] ?? "",
    objData: transactionData['objData'] ?? "{}",
  );
}

  void _showErrorDialog(BuildContext context, String text) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.indigo[900])),
          content: Text(text),
          actions: <Widget>[
            TextButton(
              child: Text('Ok', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo[900])),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        );
      },
    );
  }
}