import 'package:chips_choice/chips_choice.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MultipleChoiceFilter extends StatefulWidget {
  final List<String> _choices;
  final List<String> _currentChoices;
  final String title;

  final void Function(List<String> currentChoices) onChoiceChanged;

  const MultipleChoiceFilter(this._choices, this._currentChoices,
      {Key key, this.onChoiceChanged, this.title})
      : super(key: key);
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _MultipleChoiceFilterState(
        this._choices, this._currentChoices, this.onChoiceChanged, this.title);
  }
}

class _MultipleChoiceFilterState extends State<MultipleChoiceFilter> {
  final List<String> _choices;
  final void Function(List<String> currentChoices) _onChoiceChanged;
  List<String> _currentChoices;

  final String _title;

  _MultipleChoiceFilterState(
      this._choices, this._currentChoices, this._onChoiceChanged, this._title);
  @override
  Widget build(BuildContext context) {
    return ExpandablePanel(
      header: Row(
        children: [
          Text(_title),
          ChoiceChip(
            onSelected: (b) => {
              setState(() => _currentChoices = b ? _choices : List()),
              _onChoiceChanged(_currentChoices)
            },
            label: Text("All"),
            selected: _currentChoices.length == _choices.length,
          ),
        ],
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
      ),
      expanded: ChipsChoice<String>.multiple(
        value: _currentChoices,
        onChanged: (x) => {
          setState(() => _currentChoices = x),
          _onChoiceChanged(_currentChoices)
        },
        choiceItems: _choices.map((e) => C2Choice(value: e, label: e)).toList(),
        wrapped: true,
        choiceStyle: C2ChoiceStyle(showCheckmark: false),
      ),
    );
  }
}
