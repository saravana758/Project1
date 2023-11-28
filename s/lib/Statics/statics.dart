import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class StatisticsScreen extends StatefulWidget {
  @override
  _StatisticsScreenState createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  Map<String, dynamic> apiResponse = {}; // To store the API response

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    var headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer 2|1BwbYdEmAuyFjzecsk3OiONS34Xi2A4teH6mEF5Y3c656940',
    };
    var response = await http.get(
      Uri.parse('https://bob-fms.trainingzone.in/api/user/stats'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      // Parse the response JSON
      Map<String, dynamic> jsonResponse = json.decode(response.body);

      // Access the "data" part of the response
      Map<String, dynamic> data = jsonResponse["data"];

      setState(() {
        apiResponse = data["Practice"]["2023-10-27"]["Level 3"]["SD 15 Rows"][0];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('API Response Example'),
      ),
      body: ListView(
        children: <Widget>[
          ListTile(
            title: Text("Success: ${apiResponse['success']}"),
          ),
          ListTile(
            title: Text("Message: ${apiResponse['message']}"),
          ),
          ListTile(
            title: Text("Activity: ${apiResponse['activity']}"),
          ),
          ListTile(
            title: Text("Date: ${apiResponse['date']}"),
          ),
          ListTile(
            title: Text("Level Name: ${apiResponse['l_name']}"),
          ),
          ListTile(
            title: Text("Session Name: ${apiResponse['s_name']}"),
          ),
          ListTile(
            title: Text("Correct Answers: ${apiResponse['correct_answers']}"),
          ),
          ListTile(
            title: Text("Time Taken: ${apiResponse['time_taken']}"),
          ),
          ListTile(
            title: Text("Average Time Taken: ${apiResponse['average_time_taken']}"),
          ),
          // Add more data as needed
        ],
      ),
    );
  }
}
