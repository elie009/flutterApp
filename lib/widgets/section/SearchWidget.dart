import 'package:flutter/material.dart';
import 'package:flutter_app/utils/Constant.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../components/ModalBox.dart';

class SearchWidget extends StatelessWidget {
  SearchWidget({this.widthFactor});
  final double widthFactor;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _typeAheadController = TextEditingController();
  FocusNode focusNode = new FocusNode();

  String _selectedCity;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: widthFactor == null ? 1 : widthFactor,
      child: Container(
        child: Padding(
          padding: EdgeInsets.all(5),
          child: Form(
            key: this._formKey,
            child: Padding(
              padding: EdgeInsets.all(5.0),
              child: Column(
                children: <Widget>[
                  TypeAheadFormField(
                    textFieldConfiguration: TextFieldConfiguration(
                        focusNode: this.focusNode,
                        controller: this._typeAheadController,
                        decoration: InputDecoration(
                          labelText: 'City',
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(5.0)),
                            borderSide: BorderSide(
                              width: 0,
                              color: primaryColor,
                              style: BorderStyle.none,
                            ),
                          ),
                          filled: true,
                          prefixIcon: IconButton(
                            icon: Icon(Icons.search),
                            color: primaryColor,
                            onPressed: () {
                              if (this._formKey.currentState.validate()) {
                                this._formKey.currentState.save();
                                Scaffold.of(context).showSnackBar(SnackBar(
                                    content: Text(
                                        'Your Favorite City is ${this._selectedCity}')));
                              } else {
                                this.focusNode.unfocus();
                              }
                            },
                          ),
                          fillColor: Color(0xFFFAFAFA),
                          hintStyle: new TextStyle(
                              color: Color(0xFFd0cece), fontSize: 18),
                          hintText: "What would your like to buy?",
                        )),
                    suggestionsCallback: (pattern) {
                      return CitiesService.getSuggestions(pattern);
                    },
                    itemBuilder: (context, suggestion) {
                      return ListTile(
                        title: Text(suggestion),
                      );
                    },
                    transitionBuilder: (context, suggestionsBox, controller) {
                      return suggestionsBox;
                    },
                    onSuggestionSelected: (suggestion) {
                      this._typeAheadController.text = suggestion;
                    },
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please select a city';
                      }
                    },
                    onSaved: (value) => this._selectedCity = value,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CitiesService {
  static final List<String> cities = [
    'Beirut',
    'Damascus',
    'San Fransisco',
    'Rome',
    'Los Angeles',
    'Madrid',
    'Bali',
    'Barcelona',
    'Paris',
    'Bucharest',
    'New York City',
    'Philadelphia',
    'Sydney',
  ];

  static List<String> getSuggestions(String query) {
    List<String> matches = <String>[];
    matches.addAll(cities);

    matches.retainWhere((s) => s.toLowerCase().contains(query.toLowerCase()));
    return matches;
  }
}
