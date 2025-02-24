import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zippy/domain/model/offer/offer_model.dart';
import 'package:zippy/domain/repository/offer/offer_repository.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class OfferTile extends StatefulWidget {
  final Offer offer;
  final VoidCallback onTap;

  const OfferTile({
    Key? key,
    required this.offer,
    required this.onTap,
  }) : super(key: key);

  @override
  State<OfferTile> createState() => _OfferTileState();
}

class _OfferTileState extends State<OfferTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  bool _isExpanded = false;
  bool _isActivating = false;

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

  void _toggleExpand() {
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
    return Card(
      margin: const EdgeInsets.only(bottom: 4.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      elevation: 0,
      color: Colors.white,
      child: InkWell(
        onTap: _toggleExpand,
        borderRadius: BorderRadius.circular(16.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 80,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          widget.offer.image,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.1),
                              child: Icon(
                                Icons.error_outline,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  widget.offer.title,
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                              ),
                              if (widget.offer.discount != "0.00") ...[
                                Text(
                                  '${widget.offer.discount}%',
                                  style: Theme.of(context).textTheme.inText,
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.offer.merchantName,
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          const SizedBox(height: 4),
                          Expanded(
                            child: Text(
                              widget.offer.description,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Colors.black54,
                                  ),
                              maxLines: _isExpanded ? null : 2,
                              overflow:
                                  _isExpanded ? null : TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizeTransition(
              sizeFactor: _expandAnimation,
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 16,
                  right: 16,
                  bottom: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Text(
                      'Offer Details',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    _buildOfferDetail(context, 'Type', widget.offer.type),
                    _buildOfferDetail(context, 'Min Amount',
                        '${widget.offer.currency} ${widget.offer.minAmount}'),
                    if (widget.offer.discount != "0.00")
                      _buildOfferDetail(context, 'Discount',
                          '${widget.offer.discount}${widget.offer.discountType == "PERCENTAGE" ? "%" : " " + widget.offer.currency}'),
                    if (widget.offer.bonus != "0.00")
                      _buildOfferDetail(context, 'Bonus',
                          '${widget.offer.bonus}${widget.offer.bonusType == "PERCENTAGE" ? "%" : " " + widget.offer.currency}'),
                    _buildOfferDetail(context, 'Valid Until',
                        widget.offer.dateEnd.toString().split(' ')[0]),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (widget.offer.is_activation)
                          Container(
                            height: 36,
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .tertiaryContainer,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: ElevatedButton(
                              onPressed: null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .secondaryContainer,
                                foregroundColor:
                                    Theme.of(context).colorScheme.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 8,
                                ),
                              ),
                              child: Text(
                                'Activated',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(
                                      color: Colors.white,
                                    ),
                              ),
                            ),
                          )
                        else
                          ElevatedButton(
                            onPressed: _isActivating ? null : _activateOffer,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 8,
                              ),
                            ),
                            child: _isActivating
                                ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Theme.of(context).colorScheme.onPrimary,
                                      ),
                                    ),
                                  )
                                : Text(
                                    AppLocalizations.of(context)!.getOfferNow,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(
                                          color: Colors.white,
                                        ),
                                  ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOfferDetail(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Future<void> _activateOffer() async {
    final l10n = AppLocalizations.of(context)!;
    if (_isActivating) return;

    setState(() {
      _isActivating = true;
    });

    try {
      final repository = RepositoryProvider.of<OfferRepository>(context);
      final activation = await repository.activateOffer(widget.offer.id);

      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.offerActivatedSuccess,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
          ),
        );

        // Launch offer URL
        final url = Uri.parse(widget.offer.link);
        if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
          throw Exception('Could not launch ${widget.offer.link}');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.offerActivationError,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isActivating = false;
        });
      }
    }
  }
}
