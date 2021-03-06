import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:flutter/services.dart' ; 
import 'package:dio/dio.dart'; 
import 'package:http/http.dart' as http; 
import './place.dart'; 
import 'dart:async'; 
import 'dart:convert'; 
import 'dart:math'; 
import 'package:flutter_dotenv/flutter_dotenv.dart';


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
  String distanceMessage = "Distance: 1.0 mile";

  // vars for the second slider 
  double price = 1;  

  // string for the final answer 
  String goHere = ""; 
  var test; 

  List<Place> allLocations; 
  double radius = 1609; 


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
              Text("How much can you spend? (0-4)", style: TextStyle(fontSize: 20.0, color: Colors.teal),),
              Slider(
                value: price,
                onChanged: (double e) => changedp(e),
                activeColor: Colors.red,
                inactiveColor: Colors.grey,
                divisions: 4,
                label: "Slider",
                max: 4.0,
                min: 0.0
              ),
              Text("Price Meter: ${price.toString()}"), 
              RaisedButton(child:Text("Search"),onPressed: getFinalLocation, color: Colors.blue[100],),
              Text("You should eat at: ${goHere}"),
            ],
          )
        )
      )
    ); 
  }

  void changedp(e){
    setState(() {
      price = e;  
    });
  }

  void findFood(){
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
        radius = (distance*1609.34); 
        print(radius.toInt().toString()); 
        
        String url = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${currentLocation['latitude']},${currentLocation['longitude']}&rankby=distance&type=restaurant&maxprice=${price.toInt().toString()}&key="+ DotEnv().env['GPAPIKEY']; 
        var response = await http.get(url, headers:{"Accept":"application/json"}); 

        var places = <Place>[]; 

        List data = json.decode(response.body)["results"]; 
        
        for(int i =0;i<data.length;i++){
          var current = data[i];  
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