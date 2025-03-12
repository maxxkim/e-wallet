import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:zippy/presentation/theme/theme_cubit.dart';
import 'package:zippy/presentation/widget/custom_auth_text_field.dart';
import 'package:zippy/presentation/widget/custom_rectangular_button.dart';
import 'package:zippy/presentation/widget/custom_outlined_button.dart';
import 'package:zippy/domain/model/auth/country_model.dart';
import 'package:zippy/data/api/service/api_service.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

/// A TextInputFormatter that prevents deletion of the country code prefix
class CountryCodeFormatter extends TextInputFormatter {
  final String countryCode;

  CountryCodeFormatter(this.countryCode);

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // If attempting to delete the country code
    if (newValue.text.length < countryCode.length) {
      return TextEditingValue(
        text: countryCode,
        selection: TextSelection.collapsed(offset: countryCode.length),
      );
    }

    // If replacing text that includes the country code
    if (newValue.text.length >= countryCode.length &&
        !newValue.text.startsWith(countryCode)) {
      return TextEditingValue(
        text: countryCode +
            newValue.text.substring(newValue.text.length -
                (newValue.text.length - oldValue.text.length)),
        selection: TextSelection.collapsed(offset: countryCode.length),
      );
    }

    return newValue;
  }
}

class _AuthScreenState extends State<AuthScreen> {
  final TextEditingController phoneController = TextEditingController();
  final ApiService _apiService = ApiService();
  List<CountryModel> countries = [];
  CountryModel? selectedCountry;
  MaskTextInputFormatter? maskFormatter;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCountries();
  }

  Future<void> _loadCountries() async {
    try {
      final loadedCountries = await _apiService.getCountries();
      final CountryModel russia = CountryModel(
          code: 'CL',
          name: "Russia",
          currency: "RUB",
          phoneMask: "+7 ### ### ####",
          phonePattern: "^\\+?7[0-9]{10}\$",
          phoneExample: "+79670553338",
          icon: ":ru:");
      loadedCountries.add(russia);
      setState(() {
        countries = loadedCountries;
        selectedCountry = loadedCountries.first;
        _initializePhoneWithCountryCode(selectedCountry!);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  void _initializePhoneWithCountryCode(CountryModel country) {
    // Extract country code from the phone mask
    String countryCode = _extractCountryCode(country);

    // Create mask formatter that preserves the country code
    String mask = country.phoneMask;
    if (!mask.startsWith('+')) {
      mask = '+$mask';
    }

    maskFormatter = MaskTextInputFormatter(
      mask: mask,
      filter: {"#": RegExp(r'[0-9]')},
      initialText: countryCode,
    );

    // Set the country code as initial value and prevent its deletion
    phoneController.text = countryCode;
    phoneController.selection = TextSelection.fromPosition(
      TextPosition(offset: countryCode.length),
    );
  }

  String _extractCountryCode(CountryModel country) {
    // Try to extract country code from the phone mask
    if (country.phoneMask.contains('+')) {
      // Extract digits after + until first non-digit
      final RegExp regex = RegExp(r'\+(\d+)');
      final match = regex.firstMatch(country.phoneMask);
      if (match != null && match.groupCount >= 1) {
        return '+${match.group(1)}';
      }
    }

    // Try to extract from pattern
    if (country.phonePattern.contains('+')) {
      final RegExp regex = RegExp(r'\+(\d+)');
      final match = regex.firstMatch(country.phonePattern);
      if (match != null && match.groupCount >= 1) {
        return '+${match.group(1)}';
      }
    }

    // Try to extract from example
    if (country.phoneExample.startsWith('+')) {
      final RegExp regex = RegExp(r'\+(\d+)');
      final match = regex.firstMatch(country.phoneExample);
      if (match != null && match.groupCount >= 1) {
        return '+${match.group(1)}';
      }
    }

    // If no country code found, use the first digit after '+'
    if (country.phoneMask.isNotEmpty) {
      return '+${country.code.substring(0, 1)}';
    }

    // Last resort fallback
    return '+';
  }

  void _updateCountry(CountryModel? newCountry) {
    if (newCountry == null) return;

    setState(() {
      selectedCountry = newCountry;
      _initializePhoneWithCountryCode(newCountry);
    });
  }

  // Create a text input formatter that specifically protects the country code
  List<TextInputFormatter> _createFormatters(String countryCode) {
    return [
      maskFormatter!,
      CountryCodeFormatter(countryCode),
    ];
  }

  bool _isValidPhone(String phone, String pattern) {
    // Clean the phone number for validation
    final cleanPhone = phone.replaceAll(RegExp(r'[^0-9+]'), '');
    final RegExp regex = RegExp(pattern);
    return regex.hasMatch(cleanPhone);
  }

  String _formatPhoneForApi(String phone) {
    // Make sure to remove all non-essential characters for API submission
    return phone.replaceAll(RegExp(r'[^0-9+]'), '');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    if (errorMessage != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $errorMessage'),
              ElevatedButton(
                onPressed: _loadCountries,
                child: Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(backgroundColor: Colors.transparent),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(height: 72),
              SvgPicture.asset(
                width: 256,
                'assets/images/zentro_logo.svg',
                semanticsLabel: 'Zentro Logo',
              ).animate().fadeIn(duration: const Duration(milliseconds: 1200)),
              const SizedBox(height: 8),
              const Row(
                children: [
                  SizedBox(width: 72),
                  Text("Simple"),
                  Spacer(),
                  Text("Fast"),
                  Spacer(),
                  Text("Secure"),
                  SizedBox(width: 72),
                ],
              ).animate().fadeIn(duration: const Duration(milliseconds: 1200)),
              const SizedBox(height: 32),
              AuthTextField(
                label: l10n.mobileNumberLabel,
                switchValue: !context.watch<ThemeCubit>().isDarkMode,
                onSwitchChanged: (value) {
                  context.read<ThemeCubit>().toggleTheme();
                },
                controller: phoneController,
                maskFormatter: maskFormatter,
                placeholder: selectedCountry?.phoneExample,
                selectedCountry: selectedCountry,
                countries: countries,
                onCountryChanged: _updateCountry,
                countryCode: selectedCountry != null
                    ? _extractCountryCode(selectedCountry!)
                    : '+',
                formatters: selectedCountry != null
                    ? _createFormatters(_extractCountryCode(selectedCountry!))
                    : null,
              ).animate().slideX(
                    begin: -1,
                    end: 0,
                    duration: const Duration(milliseconds: 1000),
                    curve: Curves.easeOutQuad,
                  ),
              const SizedBox(height: 40),
              Row(
                children: [
                  const SizedBox(width: 64),
                  Expanded(
                    child: RectangularButton(
                      label: l10n.signUpButton,
                      onPressed: () {
                        final phoneNumber = phoneController.text.trim();
                        if (selectedCountry != null &&
                            _isValidPhone(
                              phoneNumber.replaceAll(RegExp(r'[^0-9+]'), ''),
                              selectedCountry!.phonePattern,
                            )) {
                          final formattedPhone =
                              _formatPhoneForApi(phoneNumber);
                          context.go(
                              '/sms/$formattedPhone/${selectedCountry?.code}');
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l10n.invalidPhoneError),
                            ),
                          );
                        }
                      },
                    ),
                  ).animate().slideY(
                        begin: 1,
                        end: 0,
                        duration: const Duration(milliseconds: 1000),
                        curve: Curves.easeOutQuad,
                      ),
                  const SizedBox(width: 16),
                  const SizedBox(width: 64),
                ],
              ),
              const SizedBox(height: 132),
              Align(
                alignment: Alignment.bottomCenter,
                child: Text(l10n.termsAndSupport),
              ).animate().fadeIn(duration: const Duration(milliseconds: 1200)),
            ],
          ),
        ),
      ),
    );
  }
}
