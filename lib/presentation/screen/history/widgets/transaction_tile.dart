import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:zippy/domain/model/transaction/transaction_model.dart';
import 'package:zippy/domain/model/transaction/transaction_share_model.dart';
import 'package:zippy/presentation/animation/fade_animation_mixin.dart';
import 'package:zippy/presentation/screen/history/widgets/transaction_utils.dart';

class TransactionTile extends StatefulWidget {
  final Transaction transaction;
  final VoidCallback onIconTap;
  final String? routePrefix;
  const TransactionTile({
    Key? key,
    required this.transaction,
    required this.onIconTap,
    this.routePrefix,
  }) : super(key: key);

  @override
  _TransactionTileState createState() => _TransactionTileState();
}

class _TransactionTileState extends State<TransactionTile>
    with SingleTickerProviderStateMixin, FadeInAnimationMixin {
  bool _isExpanded = false;
  late AnimationController _controller;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  Future<void> _shareTransaction() async {
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

  Future<void> _copyTransaction() async {
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleExpansion,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.tertiaryContainer,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16.0),
            topRight: Radius.circular(16.0),
            bottomLeft: Radius.zero,
            bottomRight: Radius.zero,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              horizontalTitleGap: 8.0,
              contentPadding: const EdgeInsets.only(left: 12.0, right: 12.0),
              title: Text(
                widget.transaction.title,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              subtitle: Text(
                DateFormat('MMMM d, hh:mm a').format(widget.transaction.date),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              leading: SvgPicture.asset(
                getIcon(widget.transaction.type),
                height: 36.0,
                width: 36.0,
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    getText(widget.transaction.type,
                        '${widget.transaction.currency} ${widget.transaction.amount.toStringAsFixed(2)}'),
                    style: getColor(widget.transaction.type),
                  ),
                  const SizedBox(width: 8.0),
                  GestureDetector(
                    onTap: widget.onIconTap,
                    child: SvgPicture.asset(
                      'assets/images/icon_receipt.svg',
                      height: 24.0,
                      width: 24.0,
                    ),
                  ),
                ],
              ),
            ),
            SizeTransition(
              sizeFactor: _expandAnimation,
              child: Container(
                padding: const EdgeInsets.all(12),
                color: Theme.of(context).scaffoldBackgroundColor,
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Transaction ID: ',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              Text(
                                '${widget.transaction.id.substring(0, 8)}...',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Text(
                                'Amount: ',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              Text(
                                '${widget.transaction.currency} ${widget.transaction.amount.toString()}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Text(
                                'Date: ',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              Text(
                                DateFormat('MMMM d, yyyy')
                                    .format(widget.transaction.date),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Text(
                                'Time: ',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              Text(
                                DateFormat('hh:mm a')
                                    .format(widget.transaction.date),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ],
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Status: ${widget.transaction.status}',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const Spacer(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                _buildActionButton(
                                  context,
                                  'assets/images/icon_support.svg',
                                  'Help',
                                  () => _showHelpDialog(context),
                                ),
                                const SizedBox(width: 16.0),
                                _buildActionButton(
                                  context,
                                  'assets/images/icon_copy.svg',
                                  'Copy',
                                  _copyTransaction,
                                ),
                                const SizedBox(width: 16.0),
                                _buildActionButton(
                                  context,
                                  'assets/images/icon_share.svg',
                                  'Share',
                                  _shareTransaction,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
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
            height: 24.0,
            width: 24.0,
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.headlineLarge,
          ),
        ],
      ),
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

  String getIcon(String type) {
    if (type == "payin") {
      return 'assets/images/icon_transaction_background.svg';
    } else {
      return 'assets/images/icon_transaction_out.svg';
    }
  }

  String getText(String type, String text) {
    if (type == "payin") {
      return text;
    } else {
      return "-$text";
    }
  }

  TextStyle? getColor(String type) {
    if (type == "payin") {
      return Theme.of(context).textTheme.inText;
    } else {
      return Theme.of(context).textTheme.outText;
    }
  }
}
