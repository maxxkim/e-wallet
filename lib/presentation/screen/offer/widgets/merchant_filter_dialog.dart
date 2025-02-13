// lib/presentation/screen/offer/widgets/merchant_filter_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zippy/domain/repository/offer/offer_repository.dart';

class MerchantData {
  final String hash;
  final String name;
  final int totalOffers;

  MerchantData({
    required this.hash,
    required this.name,
    required this.totalOffers,
  });
}

class MerchantFilterDialog extends StatefulWidget {
  final Function(List<MerchantData>) onMerchantsSelected;
  final List<MerchantData> selectedMerchants;

  const MerchantFilterDialog({
    Key? key,
    required this.onMerchantsSelected,
    required this.selectedMerchants,
  }) : super(key: key);

  @override
  State<MerchantFilterDialog> createState() => _MerchantFilterDialogState();
}

class _MerchantFilterDialogState extends State<MerchantFilterDialog> {
  List<MerchantData> _merchants = [];
  List<MerchantData> _selectedMerchants = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _selectedMerchants = List.from(widget.selectedMerchants);
    _fetchMerchants();
  }

  Future<void> _fetchMerchants() async {
    try {
      final repository = RepositoryProvider.of<OfferRepository>(context);
      final initialData = await repository.getInitialData();

      if (mounted) {
        setState(() {
          _merchants = initialData.merchants
              .map((m) => MerchantData(
                    hash: m.hash,
                    name: m.name,
                    totalOffers: m.totalOffers,
                  ))
              .toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load merchants >~<';
          _isLoading = false;
        });
      }
    }
  }

  void _toggleMerchant(MerchantData merchant) {
    setState(() {
      if (_selectedMerchants.any((m) => m.hash == merchant.hash)) {
        _selectedMerchants.removeWhere((m) => m.hash == merchant.hash);
      } else {
        _selectedMerchants.add(merchant);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Text(
            _error!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ),
      );
    }

    return Container(
      width: double.maxFinite,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Text(
                          'Merchants',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'Total offers',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ..._merchants
                      .map((merchant) => _buildMerchantItem(context, merchant)),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ),
                const SizedBox(width: 32),
                ElevatedButton(
                  onPressed: () {
                    widget.onMerchantsSelected(_selectedMerchants);
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                  ),
                  child: const Text(
                    'Apply',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMerchantItem(BuildContext context, MerchantData merchant) {
    final isSelected = _selectedMerchants.any((m) => m.hash == merchant.hash);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: isSelected
            ? Theme.of(context).colorScheme.tertiaryContainer
            : Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _toggleMerchant(merchant),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  merchant.name,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              Text(
                '${merchant.totalOffers} offers',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
