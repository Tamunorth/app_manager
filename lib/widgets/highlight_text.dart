import 'package:flutter/material.dart';

class HighlightText extends StatelessWidget {
  const HighlightText({
    Key key,
    @required this.data,
    this.hightlightData = '',
    this.defaultStyle,
    this.hightlightStyle,
    this.maxLine,
  }) : super(key: key);
  final String data;
  final String hightlightData;
  final TextStyle defaultStyle;
  final TextStyle hightlightStyle;
  final int maxLine;
  @override
  Widget build(BuildContext context) {
    if (hightlightData.isNotEmpty) {
      int index = data.toLowerCase().indexOf(hightlightData);
      if (index != -1) {
        List<int> highlightOffset = [index];
        for (int i = 0; i < hightlightData.length - 1; i++) {
          highlightOffset.add(highlightOffset[i] + 1);
        }
        return RichText(
          maxLines: maxLine,
          text: TextSpan(
            text: '',
            style: defaultStyle,
            children: [
              for (int i = 0; i < data.length; i++)
                TextSpan(
                  text: data[i],
                  style: highlightOffset.contains(i)
                      ? hightlightStyle ??
                          defaultStyle.copyWith(
                              color: Theme.of(context).primaryColor)
                      : defaultStyle,
                ),
            ],
          ),
        );
      }
    }
    return Text(
      data,
      style: defaultStyle,
      maxLines: maxLine,
    );
  }
}
