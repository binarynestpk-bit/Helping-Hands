import 'package:flutter/material.dart';

class FinalWidgetTest extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Final Widget Test')),
      body: Center(
        child: Text('This is the Final Widget Test Page', style: TextStyle(fontSize: 20)),
      ),
    );
  }
}
