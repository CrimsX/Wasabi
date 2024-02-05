import 'package:flutter/material.dart';
//import 'package:provider/provider.dart';
//import '../viewmodels/counter_view_model.dart';

class InputField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
      final counterviewmodel = Provider.of<counter_view_model>(context);

      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'Counter value',
          ),
          Text(
            '${counterviewmodel.countervalue}',
            style: Theme.of(context).textTheme.headline4,         
          )

        ]
      )
    }
}
