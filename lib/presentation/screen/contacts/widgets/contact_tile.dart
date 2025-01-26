import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:zippy/domain/model/contacts/contact_model.dart';
import 'package:zippy/presentation/theme/app_theme.dart';

class ContactTile extends StatefulWidget {
  final ContactModel contact;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onShare;
  final VoidCallback onCopy;

  const ContactTile({
    Key? key,
    required this.contact,
    required this.onEdit,
    required this.onDelete,
    required this.onShare,
    required this.onCopy,
  }) : super(key: key);

  @override
  State<ContactTile> createState() => _ContactTileState();
}

class _ContactTileState extends State<ContactTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
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
    return InkWell(
      onTap: _toggleExpand,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.tertiaryContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Container(
              height: 64.0,
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              decoration: BoxDecoration(
                color: _isExpanded
                    ? Theme.of(context).scaffoldBackgroundColor
                    : Theme.of(context).colorScheme.tertiaryContainer,
                border: Border.all(
                  color: _isExpanded
                      ? Theme.of(context).colorScheme.secondary
                      : Theme.of(context).colorScheme.primary,
                  width: _isExpanded ? 1 : 0,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            widget.contact.nickname ?? '',
                            style: Theme.of(context).textTheme.bodyLarge,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            widget.contact.name,
                            style: Theme.of(context).textTheme.bodyLarge,
                            textAlign: TextAlign.end,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        const SizedBox(width: 8),
                        SvgPicture.asset(
                          'assets/images/icon_wallet.svg',
                          height: 32.0,
                          width: 32.0,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(16)),
              child: SizeTransition(
                sizeFactor: _expandAnimation,
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.tertiaryContainer,
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      _buildActionButton(
                        context: context,
                        svgPath: 'assets/images/icon_copy_lg.svg',
                        label: 'Copy',
                        onTap: widget.onCopy,
                      ),
                      const SizedBox(width: 16),
                      _buildActionButton(
                        context: context,
                        svgPath: 'assets/images/icon_share_lg.svg',
                        label: 'Share',
                        onTap: widget.onShare,
                      ),
                      const SizedBox(width: 32),
                      Expanded(
                        child: _buildGradientButton(
                          context: context,
                          label: 'Edit',
                          onTap: widget.onEdit,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildOutlinedButton(
                          context: context,
                          label: 'Delete',
                          onTap: widget.onDelete,
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
    ).animate().fadeIn(duration: const Duration(milliseconds: 300));
  }

  Widget _buildActionButton({
    required BuildContext context,
    required String svgPath,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(
            svgPath,
            height: 32.0,
            width: 32.0,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: color ?? Theme.of(context).colorScheme.primary,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradientButton({
    required BuildContext context,
    required String label,
    required VoidCallback onTap,
  }) {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        gradient:
            Theme.of(context).extension<ThemeGradients>()?.darkBlueGradient,
        borderRadius: BorderRadius.circular(32),
      ),
      child: FilledButton(
        onPressed: onTap,
        style: ButtonStyle(
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 16),
          ),
          backgroundColor: WidgetStateProperty.all(Colors.transparent),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32),
            ),
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontSize: 13,
              ),
        ),
      ),
    );
  }

  Widget _buildOutlinedButton({
    required BuildContext context,
    required String label,
    required VoidCallback onTap,
  }) {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary,
          width: 1,
        ),
      ),
      child: FilledButton(
        onPressed: onTap,
        style: ButtonStyle(
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 16),
          ),
          backgroundColor: WidgetStateProperty.all(Colors.transparent),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(32),
            ),
          ),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 13,
              ),
        ),
      ),
    );
  }
}
