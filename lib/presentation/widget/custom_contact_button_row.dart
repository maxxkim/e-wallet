import 'package:flutter/material.dart';
import 'package:zippy/presentation/widget/custom_contact_button.dart';
import 'package:zippy/presentation/theme/app_theme.dart';

class ContactButtonRow extends StatelessWidget {
  final List<ContactButton> buttons;

  const ContactButtonRow({Key? key, required this.buttons}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius:
            BorderRadius.circular(16.0), // Optional: Add some corner rounding
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          height: 92,
          child: Row(
            mainAxisAlignment: MainAxisAlignment
                .spaceEvenly, // Center items with equal spacing
            children: buttons.map((button) {
              return SizedBox(
                height: 92, // Set height to match overall height
                width: 64,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Using a Container to create a gradient circle background
                    Container(
                      decoration: BoxDecoration(
                        gradient: button.color != null
                            ? null // If button has a color, don't use gradient
                            : Theme.of(context)
                                .extension<ThemeGradients>()
                                ?.darkBlueGradient, // Use gradient as default
                        shape: BoxShape.circle,
                      ),
                      child: CircleAvatar(
                        radius: 24, // Increase radius for better visibility
                        backgroundColor: button.color ??
                            Colors
                                .transparent, // Keep it transparent if a color is provided
                        child: Icon(
                          button.icon,
                          size: 32,
                          color: Colors
                              .white, // Make the icon white for visibility
                        ),
                      ),
                    ),
                    const SizedBox(
                        height: 4), // Space between button and caption
                    Flexible(
                      // Use Flexible so text can take available space
                      child: Center(
                        child: Text(
                          textAlign: TextAlign.center,
                          button.subtitle,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
