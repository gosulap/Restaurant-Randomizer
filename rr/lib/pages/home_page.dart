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

        // this column will have the two buttons and the question that is to be displayed 
        // essentially our main page 
        return new Column(
          children: <Widget>[
              new Text("Test", style: new TextStyle(color: Colors.white)), 
          ],
        );
 
  }


  String testAgain(LocationData location){
    return location.longitude.toString(); 
  }
  Future<void> test() async {
  
     await location.getLocation().then(testAgain);
     
  }

}