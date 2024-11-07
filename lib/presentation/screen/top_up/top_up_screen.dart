import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:zippy/domain/model/top_up/parameter_model.dart';
import 'package:zippy/domain/model/top_up/provider_model.dart';
import 'package:zippy/domain/state/dashboard/dashboard_state.dart';
import 'package:zippy/presentation/screen/dashboard/widgets/transaction_history_panel.dart';
import 'package:zippy/presentation/widget/custom_text_field.dart';

class TopUpScreen extends StatelessWidget {
  TopUpScreen({Key? key}) : super(key: key);

  final List<Provider> providers = [
    Provider(
      description: "",
      name: "Provider",
      logo:
          "https://avatars.mds.yandex.net/i?id=92ffb7cb522205dac648018012173f3f77ccfa81-13310033-images-thumbs&n=13",
      parameters: [
        Parameter(
          name: "Name",
          required: true,
          min: 1,
          max: 15,
          type: 'string',
          pattern: '',
        ),
        Parameter(
          name: "Surname",
          required: true,
          min: 1,
          max: 15,
          type: 'string',
          pattern: '',
        ),
        Parameter(
          name: "Amount",
          required: true,
          min: 1,
          max: 15,
          type: 'number',
          pattern: '',
        ),
      ],
    ),
    Provider(
      description: "",
      name: "Hui",
      logo:
          "https://avatars.mds.yandex.net/i?id=92ffb7cb522205dac648018012173f3f77ccfa81-13310033-images-thumbs&n=13",
      parameters: [
        Parameter(
          name: "Pidor",
          required: true,
          min: 1,
          max: 15,
          type: 'string',
          pattern: '',
        ),
        Parameter(
          name: "Zalupa",
          required: true,
          min: 1,
          max: 15,
          type: 'string',
          pattern: '',
        ),
        Parameter(
          name: "Ochko",
          required: true,
          min: 1,
          max: 15,
          type: 'number',
          pattern: '',
        )
      ],
    ),
  ];

  final TextEditingController emailController = TextEditingController();
  final TextEditingController amountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        toolbarHeight: 40,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              const SizedBox(height: 56),
              Center(
                child: Text(
                  "Total balance",
                  style: Theme.of(context).textTheme.displayLarge,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/images/dollar.svg',
                    height: 32.0,
                    width: 32.0,
                  ),
                  const SizedBox(width: 16),
                  Text(
                    '1 800.08',
                    style: Theme.of(context).textTheme.titleLarge,
                  )
                ],
              ),
              const SizedBox(height: 24),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Select Top Up option:",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const SizedBox(height: 12),
              ListView.builder(
                shrinkWrap: true,
                itemCount: providers.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 32.0),
                          child: Positioned.fill(
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .tertiaryContainer,
                                  borderRadius: const BorderRadius.only(
                                    bottomLeft: Radius.circular(16),
                                    bottomRight: Radius.circular(16),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      left: 16.0,
                                      right: 16.0,
                                      top: 40,
                                      bottom: 8),
                                  child: Column(
                                    children: providers[index]
                                        .parameters
                                        .map((param) {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8.0),
                                        child: CustomTextField(
                                          controller: TextEditingController(),
                                          labelText: param.name,
                                          keyboardType:
                                              getKeyBoardType(param.type),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Container(
                          height: 64.0,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .secondaryContainer,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(16),
                              bottom: Radius.circular(16),
                            ),
                          ),
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.only(left: 48.0, right: 48.0),
                              child: Row(
                                children: [
                                  Text(providers[index].name),
                                  Spacer(),
                                  Icon(Icons.assist_walker),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

getKeyBoardType(String type) {
  if (type == "number") {
    return TextInputType.number;
  } else {
    return TextInputType.name;
  }
}
