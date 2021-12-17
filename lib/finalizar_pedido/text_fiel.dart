import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:sergipe_shop/utils/extensions.dart';

class TextFieldOutlineBorder extends StatelessWidget {
  final String labelText;
  final TextEditingController controller;
  final TextInputType textInputType;
  final TextInputFormatter textInputFormatter;
  final String initialValue;
  const TextFieldOutlineBorder({
    Key? key,
    required this.labelText,
    required this.controller,
    this.textInputType = TextInputType.text,
    required this.textInputFormatter,
    this.initialValue = '',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    controller.text = initialValue;
    return Padding(
      padding: const EdgeInsets.only(bottom: 30),
      child: TextFormField(
        // initialValue: initialValue,

        keyboardType: textInputType,
        controller: controller,
        inputFormatters: [textInputFormatter],
        // [
        //   textInputType == TextInputType.number
        //       ? CurrencyTextInputFormatter(name: 'BR', symbol: 'R\$ ')
        //       : FilteringTextInputFormatter.singleLineFormatter
        // ],
        decoration: InputDecoration(
            border: const OutlineInputBorder(), labelText: labelText),
      ),
    );
  }
}
