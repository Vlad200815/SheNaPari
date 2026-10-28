import 'package:flutter/material.dart';

abstract class BaseViewHolder<T> extends StatelessWidget {
  final T _data;
  final Function(T) onItemClicked;
  Widget createContent(BuildContext context, T data);

  const BaseViewHolder(T data, Function(T) onClickCallback, {super.key})
      : _data = data,
        onItemClicked = onClickCallback;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        highlightColor: Colors.transparent,
        splashFactory: NoSplash.splashFactory,
        onTap: () => onItemClicked(_data),
        child: createContent(context, _data),
      ),
    );
  }
}
