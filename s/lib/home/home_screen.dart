import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../Statics/statics.dart';
import '../levels/Level_list_screen.dart';
import '../main.dart';
import '../widget.dart';

class HomeScreen extends StatefulWidget {
  final String token;

  const HomeScreen({Key? key, required this.token}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? userName;
  String? userEmail;
  String? apiResponse;

  @override
  void initState() {
    super.initState();
    _fetchDataFromApi();
  }

  Future<void> _fetchDataFromApi() async {
    try {
      final Uri apiUrl = Uri.parse('https://bob-fms.trainingzone.in/api/user/dashboard');
      final Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${widget.token}',
      };
      final http.Response response = await http.get(apiUrl, headers: headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final String name = responseData['name'];
        final String email = responseData['email'];

        setState(() {
          userName = name;
          userEmail = email;
          apiResponse = response.body; // Store the API response
        });

        print('Response: ${response.body}');
        print('Token: ${widget.token}');
      } else {
        print('API Error: ${response.reasonPhrase}');
        setState(() {
          apiResponse = 'API Error: ${response.reasonPhrase}';
        });
      }
    } catch (error) {
      print('API Error: $error');
      setState(() {
        apiResponse = 'API Error: $error';
      });
    }
  }

  Future<void> _logout() async {
    try {
      final storage = FlutterSecureStorage();
      await storage.delete(key: 'token');

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => HomePage(),
        ),
      );
    } catch (error) {
      print('Logout Error: $error');
    }
  }

  Widget _buildProfileInfo() {
    return Row(
      children: [
        SizedBox(width: 20),
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            image: DecorationImage(
              image: AssetImage('assets/account.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        SizedBox(width: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('$userName', style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold)),
            Text('$userEmail', style: TextStyle(fontSize: 13)),
          ],
        ),
      ],
    );
  }

  Widget _buildExploreSection() {
    return Column(
      children: [
        SizedBox(height: 10),
        Row(
          children: [
            SizedBox(width: 35),
            Text(
              "Explore",
              style: TextStyle(fontSize: 25, color: Colors.grey),
            ),
          ],
        ),
        SizedBox(height: 20),
      ],
    );
  }

  Widget _buildPracticeItem(String title) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 30),
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Colors.black,
            width: 2.0,
          ),
        ),
        child: Row(
          children: [
            SizedBox(width: 50),
            Text(
              title,
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.normal),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 121, 14, 170),
        title: Center(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(37,3,3,3),
            child: Text(
              'Brainobrain Dictation',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.white,
              ),
            ),
          ),
        ),
        actions: <Widget>[
          Container(
            child: CustomDropdownButton(
             height: 40, 
  width: 70, // Replace with the desired width
               backgroundColor: Colors.blue,
              items: [
                CustomDropdownMenuItem(
                  value: 1,
                  child: Container(
                   
                    child: ListTile(
                      leading: Icon(Icons.settings),
                      title: Text('Settings', style: TextStyle(fontSize: 20)),
                    ),
                  ),
                ),
                CustomDropdownMenuItem(
                  value: 2,
                  child: Container(
                  
                    child: ListTile(
                      leading: Icon(Icons.person),
                      title: Text('Profile', style: TextStyle(fontSize: 20)),
                    ),
                  ),
                ),
                CustomDropdownMenuItem(
                  value: 3,
                  child: Container(
                    
                    child: ListTile(
                      leading: Icon(Icons.insert_chart),
                      title: Text('Statistics', style: TextStyle(fontSize: 20)),
                    ),
                  ),
                ),
                CustomDropdownMenuItem(
                  value: 4,
                  child: Container(
                   
                    child: ListTile(
                      leading: Icon(Icons.logout),
                      title: Text('Logout', style: TextStyle(fontSize: 20)),
                    ),
                  ),
                ),
              ],
              onSelected: (value) async {
                if (value == 1) {
                  // Handle Settings
                } else if (value == 2) {
                  // Handle Profile
                } else if (value == 3) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => StatisticsScreen(),
                    ),
                  );
                } else if (value == 4) {
                  await _logout();
                }
              },
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Container(
          color: Colors.white,
          child: Column(
            children: [
              SizedBox(height: 20),
              _buildProfileInfo(),
              _buildExploreSection(),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => LevelListScreen(token: widget.token),
                    ),
                  );
                },
                child: SafeArea(
                  child: _buildPracticeItem("Practices"),
                ),
              ),
              SizedBox(height: 20),
              _buildPracticeItem("Table Practices"),
              SizedBox(height: 20),
              _buildPracticeItem("Multi Taskings"),
              Container(
                height: 150,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  image: DecorationImage(
                    image: AssetImage('assets/mynew.png'),
                    fit: BoxFit.fitHeight,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
