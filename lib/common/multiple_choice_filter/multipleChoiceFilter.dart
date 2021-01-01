import 'package:flutter/cupertino.dart';

class MultipleChoiceFilter extends StatefulWidget {
  final List<String> _choices;
  final List<String> _currentChoices;

  final void Function(List<String> currentChoices) onChoiceChanged;

  const MultipleChoiceFilter( this._choices, this._currentChoices, {Key key, this.onChoiceChanged}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _MultipleChoiceFilterState(this._choices, this._currentChoices, this.onChoiceChanged);
  }

}

class _MultipleChoiceFilterState extends State<MultipleChoiceFilter> {
  final List<String> _choices;
  final void Function(List<String> currentChoices) _onChoiceChanged;
  List<String> _currentChoices;

  _MultipleChoiceFilterState(this._choices, this._currentChoices, this._onChoiceChanged);
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}

