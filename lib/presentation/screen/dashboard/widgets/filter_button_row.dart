import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zippy/domain/state/dashboard/dashboard_state.dart';
import 'package:zippy/presentation/bloc/dashboard/dashboard_cubit.dart';
import 'package:zippy/presentation/theme/app_theme.dart';

class FilterButtonRow extends StatelessWidget {
  final DashboardStateLoaded state;
  const FilterButtonRow({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildFilterButton(
          context: context,
          type: FilterType.period,
          label: "Period",
        ),
        const Spacer(),
        _buildFilterButton(
          context: context,
          type: FilterType.deposit,
          label: "Deposit",
        ),
        const Spacer(),
        _buildFilterButton(
          context: context,
          type: FilterType.withdrawal,
          label: "Withdrawal",
        ),
      ],
    );
  }

  Widget _buildFilterButton({
    required BuildContext context,
    required FilterType type,
    required String label,
  }) {
    final isSelected = state.filterType == type;

    return Container(
      height: 40, // Smaller height ✨
      decoration: BoxDecoration(
        gradient: isSelected
            ? Theme.of(context).extension<ThemeGradients>()?.darkBlueGradient
            : null,
        borderRadius: BorderRadius.circular(32),
        border: !isSelected
            ? Border.all(
                color: deepBlueColor,
                width: 1.5,
              )
            : null,
        color: !isSelected ? Colors.white : null,
      ),
      child: FilledButton(
        onPressed: () => context.read<DashboardCubit>().selectFilter(type),
        style: ButtonStyle(
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(
                horizontal: 24.0, vertical: 0), // Reduced vertical padding
          ),
          minimumSize:
              WidgetStateProperty.all(const Size(0, 32)), // Set minimum height
          maximumSize: WidgetStateProperty.all(
              const Size(double.infinity, 32)), // Set maximum height
          backgroundColor: WidgetStateProperty.all(Colors.transparent),
          foregroundColor: WidgetStateProperty.all(
            isSelected ? Colors.white : deepBlueColor,
          ),
          textStyle: WidgetStateProperty.all(
            isSelected
                ? Theme.of(context).textTheme.displaySmall
                : Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: deepBlueColor,
                    ),
          ),
          elevation: WidgetStateProperty.all(0),
          shadowColor: WidgetStateProperty.all(Colors.transparent),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32), // Match container radius
            ),
          ),
        ),
        child: Text(label),
      ),
    );
  }
}
