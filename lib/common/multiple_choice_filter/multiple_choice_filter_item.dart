import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MultipleChoiceFilterItem extends StatefulWidget {
  final String _text;
  final void Function(String text) _onSelected;
  final bool _isSelected;

  const MultipleChoiceFilterItem(this._text, this._onSelected, this._isSelected,
      {Key key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _MultipleChoiceFilterItemState(_text, _onSelected, _isSelected);
  }
}

class _MultipleChoiceFilterItemState extends State<MultipleChoiceFilterItem> {
  final String _text;
  final void Function(String text) _onSelected;
  bool _isSelected;

  _MultipleChoiceFilterItemState(
      this._text, this._onSelected, this._isSelected);
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ChoiceChip(
        label: Text(_text),
        onSelected: (b) => {
              _isSelected = b,
              if (_isSelected) _onSelected(_text),
            });
  }
}
