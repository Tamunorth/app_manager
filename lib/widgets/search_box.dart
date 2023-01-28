import 'package:flutter/material.dart';

class SearchBox extends StatelessWidget {
  const SearchBox({Key? key, this.onInput}) : super(key: key);
  final void Function(String data)? onInput;

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: (data) {
        onInput?.call(data);
      },
      style: const TextStyle(
        fontWeight: FontWeight.bold,
      ),
      decoration: InputDecoration(
        fillColor: Theme.of(context).primaryColor.withOpacity(0.08),
        hintText: '搜索',
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          gapPadding: 0,
          borderSide: const BorderSide(
            width: 0,
            color: Colors.transparent,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          gapPadding: 0,
          borderSide: const BorderSide(
            width: 0,
            color: Colors.transparent,
          ),
        ),
        filled: true,
      ),
    );
  }
}
