import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PinEntryWidget extends StatefulWidget {
  final int pinLength;
  final Function(String) onPinComplete;
  final String title;
  final String subtitle;
  final bool showError;
  final String errorMessage;
  final bool confirmMode;
  final String? firstPin;

  const PinEntryWidget({
    Key? key,
    this.pinLength = 4,
    required this.onPinComplete,
    required this.title,
    required this.subtitle,
    this.showError = false,
    this.errorMessage = 'Incorrect PIN, please try again',
    this.confirmMode = false,
    this.firstPin,
  }) : super(key: key);

  @override
  State<PinEntryWidget> createState() => _PinEntryWidgetState();
}

class _PinEntryWidgetState extends State<PinEntryWidget>
    with SingleTickerProviderStateMixin {
  late List<String> _pin;
  late AnimationController _errorAnimController;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _pin = List.filled(widget.pinLength, '');
    _errorAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    if (widget.showError) {
      _errorAnimController.forward();
    }
  }

  @override
  void didUpdateWidget(PinEntryWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showError && !oldWidget.showError) {
      _errorAnimController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _errorAnimController.dispose();
    super.dispose();
  }

  void _onDigitPressed(String digit) {
    if (_isProcessing) return;

    // Find the first empty slot
    final emptyIndex = _pin.indexWhere((element) => element.isEmpty);
    if (emptyIndex != -1) {
      setState(() {
        _pin[emptyIndex] = digit;
      });

      // If this was the last digit
      if (emptyIndex == widget.pinLength - 1) {
        _processPin();
      }
    }
  }

  void _onDeletePressed() {
    if (_isProcessing) return;

    // Find the last non-empty slot
    final lastFilledIndex =
        _pin.lastIndexWhere((element) => element.isNotEmpty);
    if (lastFilledIndex != -1) {
      setState(() {
        _pin[lastFilledIndex] = '';
      });
    }
  }

  void _processPin() async {
    setState(() {
      _isProcessing = true;
    });

    // Allow animation to show filled dots
    await Future.delayed(const Duration(milliseconds: 200));

    final pin = _pin.join();
    widget.onPinComplete(pin);

    // Reset the pins if we're staying on this screen
    setState(() {
      _pin = List.filled(widget.pinLength, '');
      _isProcessing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Logo and title
        SvgPicture.asset(
          'assets/images/zentro_logo.svg',
          width: 200,
        ).animate().fadeIn(duration: 600.ms),

        const SizedBox(height: 40),

        Text(
          widget.title,
          style: Theme.of(context).textTheme.headlineMedium,
          textAlign: TextAlign.center,
        ).animate().fadeIn(duration: 600.ms).moveY(begin: -10, end: 0),

        const SizedBox(height: 16),

        Text(
          widget.subtitle,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.8),
              ),
          textAlign: TextAlign.center,
        ).animate().fadeIn(duration: 600.ms, delay: 200.ms),

        const SizedBox(height: 40),

        // PIN dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.pinLength,
            (index) => AnimatedBuilder(
                animation: _errorAnimController,
                builder: (context, child) {
                  final shakeValue =
                      sin(_errorAnimController.value * 3 * 3.14159) * 5.0;
                  return Transform.translate(
                    offset: Offset(shakeValue, 0),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _pin[index].isNotEmpty
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.3),
                        border: Border.all(
                          color: widget.showError
                              ? Theme.of(context).colorScheme.error
                              : Theme.of(context).colorScheme.primary,
                          width: 2,
                        ),
                      ),
                    ),
                  );
                }),
          ),
        ).animate().fadeIn(duration: 600.ms, delay: 400.ms),

        // Error message
        if (widget.showError)
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Text(
              widget.errorMessage,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ).animate().fadeIn(duration: 300.ms).shake(),

        const SizedBox(height: 40),

        // Number pad
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildNumberButton("1"),
                  _buildNumberButton("2"),
                  _buildNumberButton("3"),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildNumberButton("4"),
                  _buildNumberButton("5"),
                  _buildNumberButton("6"),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildNumberButton("7"),
                  _buildNumberButton("8"),
                  _buildNumberButton("9"),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Empty button
                  SizedBox(
                    width: 64,
                    height: 64,
                  ),
                  _buildNumberButton("0"),
                  // Delete button
                  SizedBox(
                    width: 64,
                    height: 64,
                    child: IconButton(
                      onPressed: _onDeletePressed,
                      icon: const Icon(
                        Icons.backspace_outlined,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ).animate().fadeIn(duration: 800.ms, delay: 500.ms),
      ],
    );
  }

  Widget _buildNumberButton(String number) {
    return SizedBox(
      width: 64,
      height: 64,
      child: TextButton(
        onPressed: () => _onDigitPressed(number),
        style: TextButton.styleFrom(
          shape: const CircleBorder(),
          backgroundColor:
              Theme.of(context).colorScheme.primary.withOpacity(0.1),
        ),
        child: Text(
          number,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }
}
