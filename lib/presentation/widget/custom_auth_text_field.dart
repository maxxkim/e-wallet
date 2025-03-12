import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:zippy/presentation/bloc/locale/locale_cubit.dart';
import 'package:zippy/domain/model/auth/country_model.dart';
import 'package:zippy/presentation/screen/auth/auth_screen.dart';

class AuthTextField extends StatelessWidget {
  final String label;
  final bool switchValue;
  final ValueChanged<bool> onSwitchChanged;
  final TextEditingController controller;
  final MaskTextInputFormatter? maskFormatter;
  final String? placeholder;
  final CountryModel? selectedCountry;
  final List<CountryModel> countries;
  final ValueChanged<CountryModel?> onCountryChanged;
  final String countryCode;
  final List<TextInputFormatter>? formatters;

  const AuthTextField({
    Key? key,
    this.label = 'Mobile number',
    required this.switchValue,
    required this.onSwitchChanged,
    required this.controller,
    this.maskFormatter,
    this.placeholder,
    required this.selectedCountry,
    required this.countries,
    required this.onCountryChanged,
    this.countryCode = '+',
    this.formatters,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currentLocale = Localizations.localeOf(context);

    // Create a formatter that prevents deletion of the country code
    final effectiveMaskFormatter = maskFormatter ??
        MaskTextInputFormatter(
          mask: "+# (###) ### ## ##",
          filter: {"#": RegExp(r'[0-9]')},
        );

    // Use provided formatters or create a default one
    final List<TextInputFormatter> inputFormatters = formatters ??
        [
          effectiveMaskFormatter,
          CountryCodeFormatter(countryCode),
        ];

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      final newLocale = currentLocale.languageCode == 'en'
                          ? const Locale('es')
                          : const Locale('en');
                      context.read<LocaleCubit>().changeLocale(newLocale);
                    },
                    child: Container(
                      width: 57,
                      height: 32,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Theme.of(context).colorScheme.secondary,
                        border: Border.all(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          currentLocale.languageCode.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => onSwitchChanged(!switchValue),
                    child: Container(
                      width: 57,
                      height: 32,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: switchValue
                            ? Theme.of(context).colorScheme.secondary
                            : Theme.of(context).colorScheme.primary,
                        border: Border.all(
                          color: switchValue
                              ? Theme.of(context).colorScheme.secondary
                              : Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      alignment: switchValue
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Stack(
                        children: [
                          Positioned(
                            left: switchValue ? 0 : 25,
                            child: CircleAvatar(
                              backgroundColor: Colors.white,
                              radius: 15,
                              child: SvgPicture.asset(
                                  height: 24,
                                  switchValue
                                      ? 'assets/images/icon_theme_light.svg'
                                      : "assets/images/icon_theme_dark.svg",
                                  semanticsLabel: 'Theme Icon'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 72.0,
            child: TextField(
              controller: controller,
              inputFormatters: inputFormatters,
              // When focusing, put cursor at the end of the text
              onTap: () {
                if (controller.selection.baseOffset == 0) {
                  controller.selection = TextSelection.fromPosition(
                    TextPosition(offset: controller.text.length),
                  );
                }
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.0),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.0),
                  borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.secondary),
                ),
                prefixIcon: Container(
                  margin: const EdgeInsets.only(left: 16),
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      canvasColor: Theme.of(context).scaffoldBackgroundColor,
                    ),
                    child: DropdownButton<CountryModel>(
                      value: selectedCountry,
                      icon: const Icon(Icons.arrow_drop_down, size: 24),
                      underline: const SizedBox(),
                      items: countries.map((CountryModel country) {
                        return DropdownMenuItem<CountryModel>(
                          value: country,
                          child: Container(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  country.flagEmoji,
                                  style: const TextStyle(fontSize: 24),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: onCountryChanged,
                    ),
                  ),
                ),
                hintText: placeholder ??
                    effectiveMaskFormatter.getMask() ??
                    "+ 66 (119) 345 97 90",
                hintStyle: Theme.of(context).textTheme.labelMedium,
                contentPadding: const EdgeInsets.symmetric(
                    vertical: 20.0, horizontal: 16.0),
              ),
              keyboardType: TextInputType.phone,
            ),
          ),
        ],
      ),
    );
  }
}

// Note: The CountryCodeFormatter class is now imported from auth_screen.dart
