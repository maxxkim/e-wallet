import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

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
                        widget.transaction.amount.toStringAsFixed(2)),
                    style: getColor(widget.transaction.type),
                  ),
                  const SizedBox(width: 8.0),
                  _buildStatusIcon(),
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
                                '${l10n.transactionId}: ',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              Text(
                                '${widget.transaction.id.substring(0, 8)}...',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Text(
                                '${l10n.transactionAmount}: ',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              Text(
                                '${widget.transaction.currency} ${widget.transaction.amount}',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Text(
                                '${l10n.transactionDate}: ',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              Text(
                                DateFormat('MMMM d, yyyy')
                                    .format(widget.transaction.date),
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Text(
                                '${l10n.transactionTime}: ',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              Text(
                                DateFormat('hh:mm a')
                                    .format(widget.transaction.date),
                                style: Theme.of(context).textTheme.bodyMedium,
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
                              '${l10n.transactionStatus}: ${widget.transaction.status}',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const Spacer(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                _buildActionButton(
                                  context,
                                  'assets/images/icon_support.svg',
                                  l10n.transactionHelp,
                                  () => _showHelpDialog(context, l10n),
                                ),
                                const SizedBox(width: 16.0),
                                _buildActionButton(
                                  context,
                                  'assets/images/icon_copy.svg',
                                  l10n.transactionCopy,
                                  () => _copyTransaction(context, l10n),
                                ),
                                const SizedBox(width: 16.0),
                                _buildActionButton(
                                  context,
                                  'assets/images/icon_share.svg',
                                  l10n.transactionShare,
                                  () => _shareTransaction(context, l10n),
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

  Widget _buildStatusIcon() {
    final Color iconColor = Theme.of(context).colorScheme.primary;

    switch (widget.transaction.status.toLowerCase()) {
      case 'completed':
        return Icon(
          Icons.check_circle,
          size: 24.0,
          color: iconColor,
        );
      case 'pending':
        return Icon(
          Icons.schedule,
          size: 24.0,
          color: iconColor,
        );
      case 'error':
      case 'failed':
        return Icon(
          Icons.cancel,
          size: 24.0,
          color: iconColor,
        );
      default:
        return Icon(
          Icons.error_outline,
          size: 24.0,
          color: iconColor,
        );
    }
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
          /*        SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.headlineLarge,
          ),*/
        ],
      ),
    );
  }

  void _showHelpDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            l10n.transactionNeedHelp,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          content: Text(
            l10n.transactionSupportMessage,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.transactionClose),
            ),
          ],
        );
      },
    );
  }

  Future<void> _copyTransaction(
      BuildContext context, AppLocalizations l10n) async {
    try {
      await TransactionUtils.copyTransactionDetails(
        id: widget.transaction.id,
        type: widget.transaction.type,
        currency: widget.transaction.currency,
        amount: widget.transaction.amount,
        date: widget.transaction.date,
        status: widget.transaction.status,
        context: context,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.transactionCopiedSuccess)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.transactionCopyError(e.toString())),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _shareTransaction(
      BuildContext context, AppLocalizations l10n) async {
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

  String getIcon(String type) {
    if (type == "payin") {
      return 'assets/images/icon_transaction.svg';
    } else {
      return 'assets/images/icon_transaction_out.svg';
    }
  }

  String getText(String type, String text) {
    if (type == "payin") {
      return "+$text";
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
