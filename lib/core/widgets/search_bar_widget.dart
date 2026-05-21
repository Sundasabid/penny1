import 'package:flutter/material.dart';

class SearchBarWidget extends StatelessWidget {
  final TextEditingController controller;
  const SearchBarWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      textInputAction: TextInputAction.search,
      decoration: const InputDecoration(
        hintText: 'Search transactions...',
        prefixIcon: Icon(Icons.search),
      ),
    );
  }
}
