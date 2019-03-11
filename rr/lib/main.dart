import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:flutter/services.dart' ; 
import 'package:dio/dio.dart'; 
import 'package:http/http.dart' as http; 
import './place.dart'; 
import 'dart:async'; 
import 'dart:convert'; 
import 'dart:math'; 


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
  var test; 

  List<Place> allLocations; 


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

    findFood(); 
    print(currentLocation); 
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
              RaisedButton(child:Text("Search"),onPressed: getFinalLocation,),
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
    print("hello"); 
    getNearby().then((data){
      setState(() {
       allLocations = data;  
      });
    }).catchError((e){
      print(e); 
    });
  }


  void getFinalLocation(){
    findFood(); 
    if(allLocations != null)
    {
      allLocations.shuffle();
      setState(() {
      goHere = allLocations[0].name; 
      });
    }
  }

  Future<List<Place>> getNearby() async{
        String url = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=-33.8670522,151.1957362&radius=1500&type=restaurant&key=AIzaSyA6LYlJFjgHgaftXDrKNkrmcjJWzyU4Rfg"; 
        var response = await http.get(url, headers:{"Accept":"application/json"}); 

        var places = <Place>[]; 

        List data = json.decode(response.body)["results"]; 
        
        for(int i =0;i<data.length;i++){
          var current = data[i]; 
          print(current['name']); 
          places.add(new Place(current['name'],current['vicinity'])); 
        }

        return places; 
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