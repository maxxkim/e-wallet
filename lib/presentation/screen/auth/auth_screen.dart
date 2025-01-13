import 'package:flutter/material.dart';
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
  AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
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
        _updateMask(loadedCountries.first);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  void _updateMask(CountryModel country) {
    maskFormatter = MaskTextInputFormatter(
      mask: country.phoneMask,
      filter: {"#": RegExp(r'[0-9]')},
    );
    phoneController.text = '';
  }

  bool _isValidPhone(String phone, String pattern) {
    final RegExp regex = RegExp(pattern);
    return regex.hasMatch(phone);
  }

  String _formatPhoneForApi(String phone) {
    return phone.replaceAll(' ', '');
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
                onCountryChanged: (CountryModel? newValue) {
                  setState(() {
                    selectedCountry = newValue;
                    if (newValue != null) {
                      _updateMask(newValue);
                    }
                  });
                },
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
