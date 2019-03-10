import 'package:flutter/material.dart';
import 'dart:async'; 
import 'package:location/location.dart';
import 'package:flutter/services.dart' ; 
import 'package:dio/dio.dart'; 


void main() => runApp(MyApp());

class MyApp extends StatefulWidget{
  @override 
  State<StatefulWidget> createState() => MyAppState(); 

}

class MyAppState extends State<MyApp>{

  // vars for the location 
  Map<String,double> currentLocation = new Map(); 
  StreamSubscription<Map<String,double>> locationSubscription; 
  Location location = new Location();
  String error; 

  // vars for the first slider 
  double distance = 1.0; 
  String distanceMessage = ""; 

  // string for the final answer 
  String goHere = ""; 

  // sets up the state with the current location 
  @override
  void initState(){
    super.initState(); 

    currentLocation['latitude']=0.0; 
    currentLocation['longitude']=0.0; 

    initPlatformState(); 
    locationSubscription = location.onLocationChanged().listen((Map<String,double> result){
      setState(() { 
        currentLocation = result; 
      });
    });
  }

  @override 
  void didChangeDependencies() async {
    super.didChangeDependencies(); 
    print(await searchNearBy('bagel')); 
  }

  Future<List<String>> searchNearBy(String keyword) async {
    var dio = Dio(); 
    var url = "https://maps.googleapis.com/maps/api/place/nearbysearch/json"; 
    var parameters = {
      'key' : "AIzaSyA6LYlJFjgHgaftXDrKNkrmcjJWzyU4Rfg",
      'location': "40.748445, -73.9878531",
      'radius': '8000',
      'keyword': keyword
    }; 

    var response = await dio.get(url, data:parameters); 
    return response.data['results'].map<String>((result) => result['name'].toString()).toList(); 
  }

  @override 
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(title: Text("Where should I eat?")),
        body:Center(
          child:Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text("Lat/Lng: ${currentLocation['latitude']}/ ${currentLocation['longitude']}", style: TextStyle(fontSize: 20.0, color: Colors.teal),),
              Slider(
                value: distance,
                onChanged: (double e) => changed(e),
                activeColor: Colors.red,
                inactiveColor: Colors.grey,
                divisions: 10,
                label: "Slider",
                max: 10.0,
                min: 1.0
              ), 
              Text(distanceMessage),
              RaisedButton(child:Text("Search"),onPressed: findFood,),
              Text("You should eat at: ${goHere}"),
            ],
          )
        )
      )
    ); 
  }

  void changed(e){
    setState(() {
      distance = e;  

      distanceMessage = "Distance: ${e.toString()} miles"; 
    });
  }

  void findFood(){
    // in here call the api and choose a random place 
    setState(() {
     goHere = "Here" ; 
    });
  }

  void initPlatformState() async{
    // gets permissions for locations 
    Map<String,double> myLocation; 
    try{
      myLocation = await location.getLocation(); 
      error = ""; 
    }on PlatformException catch(e){
      if(e.code == "PERMISSION_DENIED"){
        error = "Permission Denied"; 
      }
      else if(e.code == "PERMISSION_DENIED_NEVER_ASK")
        error = "Permission Denied"; 
        myLocation = null; 
    }

    setState(() {
     currentLocation = myLocation;  
    });
  }

}