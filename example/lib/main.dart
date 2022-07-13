import 'package:extensive_date_range_picker/extensive_date_range_picker.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Example',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MyHomePage(title: 'Example'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  DateTimeRangePhrase _selectedRange = DateTimeRangePreset.allTime;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CustomDropdownButton(
              hint: "Select date range",
              value: _selectedRange.phrase(),
              iconSize: 24,
              isDense: false,
              underline: Container(height: 1, color: Colors.blueAccent),
              onTap: () {
                showDateRangeDialog(
                        context: context, initialRange: _selectedRange)
                    .then((range) => setState(
                        () => _selectedRange = range ?? _selectedRange));
              },
            ),
          ],
        ),
      ),
    );
  }
}
