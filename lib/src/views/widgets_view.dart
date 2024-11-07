import 'package:flexify/src/widgets/bottom_nav_bar.dart';
import 'package:flutter/material.dart';

class WidgetsView extends StatefulWidget {
  const WidgetsView({super.key});

  static const routeName = '/widgets';

  @override
  State<WidgetsView> createState() => _WidgetsViewState();
}

class _WidgetsViewState extends State<WidgetsView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Widgets",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text("This is the widgets view"),
          ],
        ),
      ),
      bottomNavigationBar: const MaterialNavBar(
        selectedIndex: 1,
      ),
    );
  }
}
