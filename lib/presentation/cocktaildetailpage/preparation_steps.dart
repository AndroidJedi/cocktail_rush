import 'package:flutter/material.dart';

class PreparationSteps extends StatelessWidget {

  String steps;

  PreparationSteps(this.steps);

  Widget _buildPreparationSteps(String step, int stepNumber) {
    return Column(
      children: <Widget>[
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
          Text('$stepNumber.',
              style: TextStyle(
                fontSize: 18.0,
                color: Colors.purple,
              )),
          const SizedBox(width: 8.0),
          Expanded(
              flex: 9,
              child: Container(
                  child: Text(step,
                      maxLines: null,
                      style: TextStyle(
                        fontSize: 18.0,
                        color: Colors.pink,
                      ))))
        ]),
        const SizedBox(height: 8.0),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    int stepsCount = 1;
    return Column(
      children: steps
          .split('+\"\\n\"+')
          .map((step) => _buildPreparationSteps(step.trim(), stepsCount++))
          .toList(),
    );
  }
}
