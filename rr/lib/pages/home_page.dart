import 'package:flutter/material.dart';
import 'package:location/location.dart';


// a stateful widget is a widget where the visuals can change over time 
class HomePage extends StatefulWidget{
  @override
  State createState() => new HomePageState(); 
}

class HomePageState extends State<HomePage>{

  var currentLocation = <String, double>{};
  var location = new Location();

  @override 
  Widget build(BuildContext context){
    // children are on top of one another on a stack 
    return new Stack(
      children: <Widget>[
        // this column will have the two buttons and the question that is to be displayed 
        // essentially our main page 
        new Column(
          children: <Widget>[
              new Text(test()), 
          ],
        ),
      ],
    );
  }

  Future<String> test() async {
  
     var testLocation = await location.getLocation();
     print(testLocation.longitude.toString()); 
     return testLocation.latitude.toString(); 
  }

}