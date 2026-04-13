import 'package:flutter/material.dart';

class WebARTryOnView extends StatelessWidget {
  final String selectedFilterId;
  const WebARTryOnView({super.key, required this.selectedFilterId});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Web AR View only supported in Chrome.'));
  }
}
