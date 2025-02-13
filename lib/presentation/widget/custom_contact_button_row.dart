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
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          height: 92,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: buttons.map((button) {
              return GestureDetector(
                onTap: button.onTap,
                child: SizedBox(
                  height: 92,
                  width: 64,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          gradient: button.color != null
                              ? null
                              : Theme.of(context)
                                  .extension<ThemeGradients>()
                                  ?.darkBlueGradient,
                          shape: BoxShape.circle,
                        ),
                        child: CircleAvatar(
                          radius: 24,
                          backgroundColor: button.color ?? Colors.transparent,
                          child: button.icon,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Flexible(
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
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
