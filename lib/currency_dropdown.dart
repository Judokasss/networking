import 'package:flutter/material.dart';
//import 'package:networking/main.dart';

class CurrencyDropdown extends StatelessWidget {
  const CurrencyDropdown({
    Key? key,
    required this.label,
    required this.value,
    required this.currencies,
    required this.onChanged,
  }) : super(key: key);

  final String label;
  final String value;
  final List<String> currencies;
  final Function(String?) onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey),
          ),
          child: DropdownButton<String>(
            value: value,
            items: currencies
                .map<DropdownMenuItem<String>>(
                  (String currency) => DropdownMenuItem<String>(
                    value: currency,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Text(
                        currency,
                        style: TextStyle(
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
            onChanged: onChanged,
            icon: Icon(
              Icons.arrow_drop_down,
              color: Colors.blue,
            ),
          ),
        ),
      ],
    );
  }
}
