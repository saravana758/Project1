import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:s/levels/level_3.dart';

import '../home/home_screen.dart';
//import '../levels/level_3.dart';

class ResultScreen extends StatelessWidget {
  final int correctAnswerCount;
  final String formattedTimer;
  final String selectedId;
  final String levelId;
  final String sectionId;
  final String token;
  final String levelName;
  final String type;


  ResultScreen({
    required this.correctAnswerCount,
    required this.selectedId,
    required this.sectionId,
    required this.levelId,
    required this.formattedTimer,
    required this.type,
    required this.levelName,
    required this.token,
    required List<int> answers,
  });
  
 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(context),
      body: buildBody(context),
    );
  }

  PreferredSize buildAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: Size.fromHeight(56),
      child: AppBar(
        backgroundColor: Color(0xFF791EAA),
        title: Text(
          'Brainobrain Dictation',
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0,3,7,3),
            child: IconButton(
              icon: Icon(Icons.home, color: Colors.white, size: 31),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => HomeScreen(token: ''),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildBody(BuildContext context) {
    String resultText = getResultText(correctAnswerCount);

    return Column(
      children: [
        buildPracticeHeader(),
        SizedBox(height: 20),
        buildResultContainer(resultText, context),
        SizedBox(height: 10,),
        logo(),
      ],
    );
  }
   Widget logo() {
    return Container(
      padding: EdgeInsets.all(20.0),
      child: Image.asset(
        'assets/5.png', 
        width: 180,
        height: 150,
      ),
    );
  }

  Widget buildPracticeHeader() {
    return Container(
      height: 30,
      color: Color(0xFFE8D3E9),
      child: Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              "Practices >",
              style: TextStyle(
                color: Color(0xFFBD1699),
                fontSize: 15,
              ),
            ),
            SizedBox(width: 2),
            Text(
              "Levels",
              style: TextStyle(
                color: Color(0xFFBD1699),
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildResultContainer(String resultText, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: Column(
        children: [
          Container(
            height: 350,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.blue,
                width: 3.0,
              ),
            ),
            child: Stack(
              children: [
                buildTimeWidget(),
                buildCenterLottieWidget(),
                buildBottomText(resultText),
                buildTryAgainButton(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTimeWidget() {
    return Align(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(30, 10, 30, 60),
            child: Text(
              'Time taken: $formattedTimer',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

 Widget buildCenterLottieWidget() {
  return Padding(
    padding: const EdgeInsets.fromLTRB(70, 0, 0,70),
    child: Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Container(
          width: 150,
          height: 150,
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              if (correctAnswerCount >= 9)
                Lottie.asset(
                  'assets/celebrate.json',
                  fit: BoxFit.contain,
                ),
              Image.asset(
                'assets/rond.png',
                fit: BoxFit.contain,
              ),
            ],
          ),
        ),
        Positioned(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                '$correctAnswerCount',
                style: TextStyle(
                  color: Color.fromARGB(255, 248, 4, 4),
                  fontSize: 32.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Out of 10',
                style: TextStyle(
                  color: Color.fromARGB(255, 13, 14, 0),
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}


  Widget buildBottomText(String resultText) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 50,
        color: Color.fromARGB(255, 235, 198, 243),
        child: Center(
          child: Text(
            resultText,
            style: TextStyle(
              color: Color.fromARGB(255, 153, 127, 127),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTryAgainButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(100, 224, 4, 4),
      child:ElevatedButton(
  onPressed: () {
    _postDataAndNavigate1(context); 
  },
  child: Text('Try Again'),
),
    );
  }

  String getResultText(int correctAnswerCount) {
    if (correctAnswerCount >= 0 && correctAnswerCount <= 5) {
      return "Speak with your teacher";
    } else if (correctAnswerCount >= 6 && correctAnswerCount <= 8) {
      return "Good";
    } else if (correctAnswerCount >= 9 && correctAnswerCount <= 10) {
      return "Excellent";
    } else {
      return "Invalid count"; // You can customize this as needed
    }
  }

  Future<void> _postDataAndNavigate(BuildContext context) async {
    var headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization':
           'Bearer ${token}',
    };
    var url = Uri.parse(
      'https://bob-fms.trainingzone.in/api/practice/$levelId/$selectedId/store-stats');
    var request = http.Request('POST', url);
    request.body = json.encode({
      "email": "student1@mail.com",
      "password": "Test@123"
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
       String responseBody = await response.stream.bytesToString();
    print(responseBody);
   
    Navigator.pop(context);
  } else {
      print(response.reasonPhrase);
     
    }
  }
  Future<void> _postDataAndNavigate1(BuildContext context) async {
  var headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization':
         'Bearer ${token}',
  };

  var url = Uri.parse(
      'https://bob-fms.trainingzone.in/api/practice/$levelId/$selectedId/store-stats');
  var request = http.Request('POST', url);
  request.body = json.encode({
    "email": "student1@mail.com",
    "password": "Test@123",
  });
  request.headers.addAll(headers);

  http.StreamedResponse response = await request.send();

  if (response.statusCode == 200) {
    String responseBody = await response.stream.bytesToString();
    print(responseBody); // Print the response

    // Update the existing instance of ResultScreen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => NextScreen(
            // Reset correct answer count
            selectedId: selectedId,
            sectionId: sectionId,
            levelId: levelId, selectedName: '', 
            token: token,
              levelName: levelName, 
      type: type, 
            
          ),
      ),
    );
  } else {
    print(response.reasonPhrase);
    // Handle the error or show an error message
  }
}


  
}








