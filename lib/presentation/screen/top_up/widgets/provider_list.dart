// ./lib/presentation/screen/top_up/widgets/provider_list.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:zippy/domain/model/top_up/provider_model.dart';
import 'package:zippy/presentation/widget/custom_text_field.dart';

class ProviderList extends StatelessWidget {
  final List<Provider> providers;

  const ProviderList({
    super.key,
    required this.providers,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: providers.length,
      itemBuilder: (context, index) {
        return ProviderCard(provider: providers[index]);
      },
    );
  }
}

class ProviderCard extends StatefulWidget {
  final Provider provider;

  const ProviderCard({
    super.key,
    required this.provider,
  });

  @override
  State<ProviderCard> createState() => _ProviderCardState();
}

class _ProviderCardState extends State<ProviderCard>
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        children: [
          InkWell(
            onTap: _toggleExpand,
            child: Container(
              height: 64.0,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondaryContainer,
                borderRadius: BorderRadius.vertical(
                  top: const Radius.circular(16),
                  bottom: Radius.circular(_isExpanded ? 0 : 16),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Row(
                  children: [
                    SvgPicture.string(
                      widget.provider.logo ?? '',
                    ),
                    Spacer(),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.provider.title ?? "",
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          widget.provider.description,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                    RotationTransition(
                      turns:
                          Tween(begin: 0.0, end: 0.5).animate(_expandAnimation),
                      child: const Icon(Icons.keyboard_arrow_down),
                    ),
                  ],
                ),
              ),
            ),
          ),
          ClipRRect(
            // Add this wrapper
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(16),
            ),
            child: SizeTransition(
              sizeFactor: _expandAnimation,
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.tertiaryContainer,
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(16),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: widget.provider.parameters.map((param) {
                      bool isLastParam =
                          widget.provider.parameters.last == param;

                      return Padding(
                        padding:
                            EdgeInsets.only(bottom: isLastParam ? 0 : 16.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: CustomTextField(
                                controller: TextEditingController(),
                                labelText:
                                    param.description?.label ?? param.name,
                                hintText: param.description?.placeholder,
                                keyboardType: _getKeyboardType(param.type),
                              ),
                            ),
                            if (isLastParam) ...[
                              const SizedBox(width: 16),
                              FilledButton(
                                onPressed: () => context.go('/dashboard'),
                                child: Text(
                                  'Continue',
                                  style:
                                      Theme.of(context).textTheme.displaySmall,
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  TextInputType _getKeyboardType(String type) {
    switch (type) {
      case 'number':
        return TextInputType.number;
      case 'email':
        return TextInputType.emailAddress;
      case 'phone':
        return TextInputType.phone;
      default:
        return TextInputType.text;
    }
  }
}
