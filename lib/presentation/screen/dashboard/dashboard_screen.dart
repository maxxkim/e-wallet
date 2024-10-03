import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zippy/presentation/bloc/dashboard/dashboard_cubit.dart';
import 'package:zippy/presentation/screen/dashboard/widgets/dashboard_display.dart';
import 'package:zippy/presentation/screen/dashboard/widgets/transaction_information_display.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => DashboardCubit(),
      child: Scaffold(
        appBar: AppBar(
          leading: Padding(
            padding: const EdgeInsets.only(left: 12),
            child: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {
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
              const DasboardDisplay(),
              const SizedBox(height: 16),
              Row(
                children: [
                  FilledButton(
                    onPressed: () => print("hui"),
                    style: ButtonStyle(
                      padding: MaterialStateProperty.all(EdgeInsets.symmetric(horizontal: 32.0)), // Adjust horizontal padding
                    ),
                    child: const Text("Period"),
                  ),
                  const Spacer(),
                  FilledButton(
                    onPressed: () => print("hui"),
                    style: ButtonStyle(
                      padding: MaterialStateProperty.all(EdgeInsets.symmetric(horizontal: 32.0)), // Adjust horizontal padding
                      backgroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.secondaryContainer), // Задаем цвет из темы
                    ),
                    child: Text("Deposit", style: Theme.of(context).textTheme.bodyMedium,),
                  ),
                  const Spacer(),
                  FilledButton(
                    onPressed: () => print("hui"),
                    style: ButtonStyle(
                      padding: MaterialStateProperty.all(EdgeInsets.symmetric(horizontal: 32)), // Adjust horizontal padding
                      backgroundColor: MaterialStateProperty.all(Theme.of(context).colorScheme.secondaryContainer), // Задаем цвет из темы
                    ),
                    child: Text("Withdrawal", style: Theme.of(context).textTheme.bodyMedium,),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const TransactionsInfoDisplay(),

            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Logout', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.indigo[900])),
          content: const Text('Are you sure you want to log out?'),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Yes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo[900])),
              onPressed: () {
                context.go('/');
              },
            ),
            TextButton(
              child: Text('Cancel', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo[900])),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}