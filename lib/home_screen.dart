import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:weatherapp/core/const.dart' as obj;

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    currentLocation();
  }

  bool Isvisible=false;
  num? humidity;
  num? temperature;
  num? pressure;
  num? cover;
  String? cityName;
  TextEditingController controller=TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration:const BoxDecoration(
        gradient: LinearGradient(colors: [
          Colors.black,
          Colors.white
        ],
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter
        )
      ),
      child: SafeArea(
        child: Visibility(
          visible: Isvisible,
          replacement:const Center(child: CircularProgressIndicator()),
          child: Column(children: [
          Container(
            width: MediaQuery.of(context).size.width*0.85,
            height: MediaQuery.of(context).size.height*0.09,
            child: Center(
              child: TextFormField(
                validator: (value) {
                  if(value==null||value.isEmpty){
                    return "Enter a city name";
                  }
                },
                controller: controller,
                onFieldSubmitted: (value){
                 setState(() {
                    cityName=value;
                  getCityWeather(value);
                  Isvisible=false;
                  controller.clear();
                 });
                } ,
                // onChanged: (value) {
                //   setState(() {
                //     cityName=value;
                //   });
                //   print(cityName);
                // },
                decoration: InputDecoration(border: InputBorder.none,
                label: Text("Search city"),
                prefixIcon: Icon(Icons.search)
                ),
                ),
            ),
              padding: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(color: Colors.black.withOpacity(0.3),
              borderRadius: BorderRadius.all(Radius.circular(20))),
          ),
          const SizedBox(height: 10,),
           Padding(
            padding:  EdgeInsets.all(8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Icon(Icons.pin_drop,size: 40,),
                Text(cityName!,style: TextStyle(fontSize: 25),
                overflow: TextOverflow.ellipsis,),
            ],),
          ),
          SizedBox(height: 20,),
                Container(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height*0.12,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 111, 111, 111),
                    boxShadow: [
                      BoxShadow(
                        color: const Color.fromARGB(255, 83, 83, 83),
                        offset: Offset(1, 2),
                        blurRadius: 3,
                        spreadRadius: 1,
                      )
                    ],
                    borderRadius: BorderRadius.all(Radius.circular(20),)
                  ),
                  child: Row(children: [
                    Image.asset("assest/thermometer.png",
                    width: MediaQuery.of(context).size.width*0.09,),
                    SizedBox(width: 10,),
                    Text("Temperature: ${temperature!.toStringAsFixed(2)}")
                  ],),
                ),
                SizedBox(height: 20,),
                Container(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height*0.12,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 111, 111, 111),
                    boxShadow: [
                      BoxShadow(
                        color: const Color.fromARGB(255, 83, 83, 83),
                        offset: Offset(1, 2),
                        blurRadius: 3,
                        spreadRadius: 1,
                      )
                    ],
                    borderRadius: BorderRadius.all(Radius.circular(20),)
                  ),
                  child: Row(children: [
                    Image.asset("assest/barometer.png",
                    width: MediaQuery.of(context).size.width*0.09,),
                    SizedBox(width: 10,),
                    Text("Pressure ${pressure!.toStringAsFixed(2)}")
                  ],),
                ),
                SizedBox(height: 20,),
                Container(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height*0.12,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 111, 111, 111),
                    boxShadow: [
                      BoxShadow(
                        color: const Color.fromARGB(255, 83, 83, 83),
                        offset: Offset(1, 2),
                        blurRadius: 3,
                        spreadRadius: 1,
                      )
                    ],
                    borderRadius: BorderRadius.all(Radius.circular(20),)
                  ),
                  child: Row(children: [
                    Image.asset("assest/humidity.png",
                    width: MediaQuery.of(context).size.width*0.09,),
                    SizedBox(width: 10,),
                    Text("Humidity ${humidity!.toStringAsFixed(2)}")
                  ],),
                ),
                SizedBox(height: 20,),
                Container(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height*0.12,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 111, 111, 111),
                    boxShadow: [
                      BoxShadow(
                        color: const Color.fromARGB(255, 83, 83, 83),
                        offset: Offset(1, 2),
                        blurRadius: 3,
                        spreadRadius: 1,
                      )
                    ],
                    borderRadius: BorderRadius.all(Radius.circular(20),)
                  ),
                  child: Row(children: [
                    Image.asset("assest/cloud cover.png",
                    width: MediaQuery.of(context).size.width*0.09,),
                    SizedBox(width: 10,),
                    Text("Cover ${temperature!.toStringAsFixed(2)}")
                  ],),
                )
          ],),
        ),
      ),
    ),);
  }

  //current location featching
  currentLocation() async {
    Position p = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        forceAndroidLocationManager: true);
    if (p!= null) {
      print("Longitude ${p.longitude}");
      print("Latitude ${p.latitude}");
      getCurrentCityWeather(p);
       setState(() {
        Isvisible=true;
      });
    } else {
      print("Data not available");
    }
  }

  //api callling convert to dart
  getCurrentCityWeather(Position position) async {
    var response= await http.get(Uri.parse("${obj.domain}lat=${position.latitude}&lon=${position.longitude}&appid=${obj.apiKey}"));
    if (response.statusCode == 200) {
      var jsondata= jsonDecode(response.body);
      updateUi(jsondata);
       setState(() {
        Isvisible=true;
      });
    } else {
      print("No data");
    }
  }

  //getcityweather
  getCityWeather(String cityName) async{
    var response= await http.get(Uri.parse("${obj.domain}q=${cityName}&appid=${obj.apiKey}"));
    if(response.statusCode==200){
     var jsondata=jsonDecode(response.body);
     updateUi(jsondata);
     setState(() {
       Isvisible=true;
     });
    }
  }

  //after getting data update the ui
  updateUi(var decodedData){
    setState(() {
      if(decodedData!=null){
      temperature=decodedData["main"]["temp"]-273;
      pressure=decodedData["main"]["pressure"];
      humidity=decodedData["main"]["humidity"];
      cover=decodedData["clouds"]["all"];
      cityName=decodedData["name"];

    }else{
      temperature=0;
      pressure=0;
      humidity=0;
      cover=0;
      cityName="Not available";
    }
    });
    }
    @override
    void dispose() {
      controller.dispose();
      super.dispose();
    }
}
