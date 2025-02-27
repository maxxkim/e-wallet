import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zippy/domain/model/transaction/transaction_model.dart';
import 'package:zippy/domain/model/transaction/transaction_share_model.dart';
import 'package:zippy/domain/repository/dashboard/dashboard_repository.dart';
import 'package:zippy/presentation/animation/fade_animation_mixin.dart';
import 'package:zippy/presentation/screen/history/widgets/transaction_utils.dart';
import 'package:zippy/presentation/widget/custom_rectangular_button.dart';

class PaymentInfoScreen extends StatefulWidget {
  final Transaction transaction;
  const PaymentInfoScreen({required this.transaction, super.key});

  @override
  State<PaymentInfoScreen> createState() => _PaymentInfoScreenState();
}

class _PaymentInfoScreenState extends State<PaymentInfoScreen>
    with FadeInAnimationMixin, SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  double? _previousBalance;
  double? _currentBalance;
  bool _isLoading = true;

  // Pre-defined container size
  final double _containerHeight = 198.0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _loadBalanceInfo();
    _animationController.forward();
  }

  Future<void> _loadBalanceInfo() async {
    try {
      final repository = RepositoryProvider.of<DashboardRepository>(context);
      final currentBalance = await repository.getBalance();

      // Derive previous balance by adding/subtracting transaction amount
      final diff = widget.transaction.type == 'payin'
          ? -widget.transaction.amount
          : widget.transaction.amount;

      setState(() {
        _currentBalance = currentBalance.toDouble();
        _previousBalance = _currentBalance! + diff;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching balance: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Calculate the container width based on screen size
    final screenWidth = MediaQuery.of(context).size.width;
    final containerWidth = screenWidth - 64.0; // Account for left/right padding

    return Scaffold(
      appBar: AppBar(
        title: fadeIn(Text(widget.transaction.type == 'payin'
            ? 'Payment Received'
            : 'Payment Sent')),
      ),
      // Wrap with SafeArea to respect device notches and home indicators
      body: SafeArea(
        // Use SingleChildScrollView to make sure content is scrollable
        child: SingleChildScrollView(
          child: Padding(
            // Add more bottom padding to prevent overflow
            padding:
                const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                Center(
                  child: Text(
                    _getText(context),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.displayLarge,
                  )
                      .animate(
                          onComplete: (controller) =>
                              controller.repeat(reverse: true))
                      .fadeIn(duration: 600.ms)
                      .then(delay: 800.ms)
                      .shimmer(delay: 1400.ms, duration: 1800.ms),
                ),
                const SizedBox(height: 24),
                Center(
                  child: _buildTransactionCard(context, containerWidth),
                ),
                const SizedBox(height: 32),
                _buildActionButtonsRow(context).animate().fadeIn(delay: 900.ms),
                const SizedBox(height: 96),
                Padding(
                  padding: const EdgeInsets.only(
                      right: 40, left: 40, bottom: 24), // Add bottom padding
                  child: RectangularButton(
                    label: "Home",
                    onPressed: () {
                      context.go('/dashboard');
                    },
                  ),
                )
                    .animate()
                    .fadeIn(delay: 1200.ms)
                    .shimmer(delay: 1400.ms, duration: 1200.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionCard(BuildContext context, double width) {
    return AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              // Fixed width and height to prevent resizing
              width: width,
              height: _containerHeight,
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: _getContainerColor(context),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: _getContainerColor(context).withOpacity(0.5),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Opacity(
                opacity: _animationController.value,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Transaction type
                    Text(
                      widget.transaction.type == "payin" ? 'Received' : 'Sent',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 16),
                    // Status icon
                    _getStatusIcon(context),
                    const SizedBox(height: 16),
                    // Amount
                    Text(
                      '${_getSign(context)} ${widget.transaction.amount} ${widget.transaction.currency}',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    // Balance info (if available)
                    if (!_isLoading &&
                        _previousBalance != null &&
                        _currentBalance != null)
                      _buildBalanceInfo(context),
                  ],
                ),
              ),
            ),
          );
        });
  }

  Widget _buildBalanceInfo(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${widget.transaction.currency} ${_previousBalance!.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  decoration: TextDecoration.lineThrough,
                ),
          ),
          Text(" → ", style: Theme.of(context).textTheme.titleMedium),
          Text(
            '${widget.transaction.currency} ${_currentBalance!.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtonsRow(BuildContext context) {
    return fadeIn(
      Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildActionButton(
              context,
              'assets/images/icon_support_lg.svg',
              'Help',
              () => _showHelpDialog(context),
            ),
            const SizedBox(width: 32),
            _buildActionButton(
              context,
              'assets/images/icon_copy_lg.svg',
              'Copy',
              () => _copyTransactionDetails(context),
            ),
            const SizedBox(width: 32),
            _buildActionButton(
              context,
              'assets/images/icon_share_lg.svg',
              'Share',
              () => _shareTransaction(context),
            ),
          ],
        ),
      ),
      delay: 300,
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String iconPath,
    String label,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          SvgPicture.asset(
            iconPath,
            height: 40.0,
            width: 40.0,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }

  Future<void> _copyTransactionDetails(BuildContext context) async {
    await TransactionUtils.copyTransactionDetails(
      id: widget.transaction.id,
      type: widget.transaction.type,
      currency: widget.transaction.currency,
      amount: widget.transaction.amount,
      date: widget.transaction.date,
      status: widget.transaction.status,
      context: context,
    );
  }

  Future<void> _shareTransaction(BuildContext context) async {
    await TransactionShare.shareTransaction(
      id: widget.transaction.id,
      type: widget.transaction.type,
      currency: widget.transaction.currency,
      amount: widget.transaction.amount,
      date: widget.transaction.date,
      status: widget.transaction.status,
      context: context,
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Need Help? 🤔',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          content: Text(
            'Contact our support team for assistance with your transaction.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  String _getSign(BuildContext context) {
    if (widget.transaction.type == "payin") {
      return "+";
    } else {
      return "-";
    }
  }

  Color _getContainerColor(BuildContext context) {
    if (widget.transaction.status == "completed") {
      return Theme.of(context).colorScheme.secondaryContainer;
    } else if (widget.transaction.status == "pending") {
      return Theme.of(context).colorScheme.onTertiaryContainer;
    } else {
      return Theme.of(context).colorScheme.onErrorContainer;
    }
  }

  Widget _getStatusIcon(BuildContext context) {
    if (widget.transaction.status == "completed") {
      return SvgPicture.asset(
        'assets/images/icon_tick.svg',
        height: 48.0,
        width: 48.0,
      );
    } else if (widget.transaction.status == "pending") {
      return SvgPicture.asset(
        'assets/images/icon_transaction_pending.svg',
        height: 48.0,
        width: 48.0,
      );
    } else {
      return SvgPicture.asset(
        'assets/images/icon_transaction_error.svg',
        height: 48.0,
        width: 48.0,
      );
    }
  }

  String _getText(BuildContext context) {
    if (widget.transaction.status == "completed") {
      return widget.transaction.type == "payin"
          ? "Payment was received\nsuccessfully!"
          : "Transaction was completed\nsuccessfully!";
    } else if (widget.transaction.status == "pending") {
      return "Transaction is being\nprocessed!";
    } else {
      return "Transaction\nwas not complete!";
    }
  }
}
