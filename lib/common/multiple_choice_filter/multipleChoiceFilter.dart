import 'package:devops/common/multiple_choice_filter/multiple_choice_filter_item.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MultipleChoiceFilter extends StatefulWidget {
  final List<String> _choices;
  final List<String> _currentChoices;

  final void Function(List<String> currentChoices) onChoiceChanged;

  const MultipleChoiceFilter(this._choices, this._currentChoices,
      {Key key, this.onChoiceChanged})
      : super(key: key);
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _MultipleChoiceFilterState(
        this._choices, this._currentChoices, this.onChoiceChanged);
  }
}

class _MultipleChoiceFilterState extends State<MultipleChoiceFilter> {
  final List<String> _choices;
  final void Function(List<String> currentChoices) _onChoiceChanged;
  List<String> _currentChoices;

  _MultipleChoiceFilterState(
      this._choices, this._currentChoices, this._onChoiceChanged);
  @override
  Widget build(BuildContext context) {
    return Container(
        child: Scrollbar(
            child: ListView(
      children: _choices
          .map((e) => MultipleChoiceFilterItem(
              e,
              (x) => {
                    if (_currentChoices.contains(x))
                      _currentChoices.remove(x)
                    else
                      _currentChoices.add(x),
                    _onChoiceChanged(_currentChoices)
                  },
              _currentChoices.contains(e)))
          .toList(growable: false),
    )));
  }
}
