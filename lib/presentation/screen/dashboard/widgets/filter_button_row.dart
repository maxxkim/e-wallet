import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zippy/domain/state/dashboard/dashboard_state.dart';
import 'package:zippy/presentation/bloc/dashboard/dashboard_cubit.dart';

class FilterButtonRow extends StatelessWidget {
  final DashboardStateLoaded state;
  FilterButtonRow({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        FilledButton(
          onPressed: () =>
              context.read<DashboardCubit>().selectFilter(FilterType.period),
          style: ButtonStyle(
            padding: WidgetStateProperty.all(
                const EdgeInsets.symmetric(horizontal: 24.0)),
            backgroundColor: WidgetStateProperty.all(
              state.filterType == FilterType.period
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.secondaryContainer,
            ),
            foregroundColor: WidgetStateProperty.all(
              state.filterType == FilterType.period
                  ? Colors.white
                  : Colors.black,
            ),
            textStyle: WidgetStateProperty.all(
                state.filterType == FilterType.period
                    ? Theme.of(context).textTheme.displaySmall
                    : Theme.of(context).textTheme.bodyMedium),
          ),
          child: const Text("Period"),
        ),
        const Spacer(),
        FilledButton(
          onPressed: () =>
              context.read<DashboardCubit>().selectFilter(FilterType.deposit),
          style: ButtonStyle(
            padding: WidgetStateProperty.all(
                const EdgeInsets.symmetric(horizontal: 24.0)),
            backgroundColor: WidgetStateProperty.all(
              state.filterType == FilterType.deposit
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.secondaryContainer,
            ),
            foregroundColor: WidgetStateProperty.all(
              state.filterType == FilterType.deposit
                  ? Colors.white
                  : Colors.black,
            ),
            textStyle: WidgetStateProperty.all(
                state.filterType == FilterType.deposit
                    ? Theme.of(context).textTheme.displaySmall
                    : Theme.of(context).textTheme.bodyMedium),
          ),
          child: const Text("Deposit"),
        ),
        const Spacer(),
        FilledButton(
          onPressed: () => context
              .read<DashboardCubit>()
              .selectFilter(FilterType.withdrawal),
          style: ButtonStyle(
            padding: WidgetStateProperty.all(
                const EdgeInsets.symmetric(horizontal: 24.0)),
            backgroundColor: WidgetStateProperty.all(
              state.filterType == FilterType.withdrawal
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.secondaryContainer,
            ),
            foregroundColor: WidgetStateProperty.all(
              state.filterType == FilterType.withdrawal
                  ? Colors.white
                  : Colors.black,
            ),
            textStyle: WidgetStateProperty.all(
                state.filterType == FilterType.withdrawal
                    ? Theme.of(context).textTheme.displaySmall
                    : Theme.of(context).textTheme.bodyMedium),
          ),
          child: const Text("Withdrawal"),
        ),
      ],
    );
  }
}
