import 'dart:convert';
//import 'package:bob_dictation_flutter/levels/oral_screen.dart';
//import 'package:bob_dictation_flutter/levels/visual_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';

import '../home/home_screen.dart';
import 'level_3.dart';
import 'oral.dart';




class MyAPIScreen extends StatefulWidget {
  final String levelId;
  final String levelName;
  final String token;
final String name;
  MyAPIScreen({
    required this.levelId,
    required this.levelName,
    required this.token,
    required this.name
  });

  @override
  _MyAPIScreenState createState() => _MyAPIScreenState();
}

class _MyAPIScreenState extends State<MyAPIScreen> {
  List<dynamic> apiData = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDataFromAPI();
  }

  Future<void> fetchDataFromAPI() async {
    print(widget.levelId);
     print('Token: ${widget.token}');
    try {
      final response = await http.get(
        Uri.parse(
          'https://bob-fms.trainingzone.in/api/practice/${widget.levelId}/sections',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization':
              'Bearer ${widget.token}',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body)["data"];
        setState(() {
          apiData = jsonData;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void handleItemClick(String id, String name) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return BottomSheetContent(
  sectionId: id,
  levelId: widget.levelId,
  token: widget.token,
  levelName: widget.levelName,
  onActionButtonPressed: () {},
);
      },
    );
  }

  Widget buildSectionItem(Map<String, dynamic> section) {
    return Container(
      child: Stack(
        children: [
      Padding(
  padding: EdgeInsets.fromLTRB(11,7,7,7),
  child: Lottie.asset(
    'assets/back.json',
    width: 340,
    height: 78,
    fit: BoxFit.fill
  ),
),

          Padding(
            padding: const EdgeInsets.fromLTRB(20,10,0,5),
            child: ListTile(
              title: Text(
                section['name'],
                style:
                    const TextStyle(fontSize: 25, fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                section['type'],
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 121, 14, 170),
        title: Text(
          'Brainobrain Dictation',
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white, size: 28),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          Padding(
           padding: const EdgeInsets.fromLTRB(0,3,7,3),
            child: IconButton(
              icon: Icon(Icons.home, color: Colors.white, size: 31),
              onPressed: () {  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HomeScreen(token:widget.token,)),
                  );},
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            height: 30,
            color:  Color.fromARGB(236, 223, 222, 222),
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    "Practices >",
                    style: TextStyle(
                      color: Color.fromARGB(255, 50, 136, 158),
                      fontSize: 15,
                    ),
                  ),
                  SizedBox(width: 2),
                  Text(
                    widget.levelName,
                    style: TextStyle(
                      color: Color.fromARGB(255, 4, 84, 104),
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: apiData.length,
              itemBuilder: (context, index) {
                final section = apiData[index];
                return GestureDetector(
                  onTap: () =>
                      handleItemClick(section['id'], section['name']),
                  child: buildSectionItem(section),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}


class BottomSheetContent extends StatefulWidget {
  final String sectionId;
  final String levelId;
  final String token;
  final String levelName;
  final VoidCallback onActionButtonPressed;

  BottomSheetContent({
    required this.sectionId,
    required this.levelId,
    required this.token,
    required this.levelName,
    required this.onActionButtonPressed,
  });

  @override
  _BottomSheetContentState createState() => _BottomSheetContentState();
}

class _BottomSheetContentState extends State<BottomSheetContent> {
  Map<String, dynamic> sectionData = {};
  bool isLoading = true;
  bool visualEnabled = false;
  bool oralEnabled = false;

  @override
  void initState() {
    super.initState();
    fetchDataForSection();
  }

  Future<void> fetchDataForSection() async {
  print(widget.sectionId);
  try {
    final response = await http.get(
      Uri.parse(
        'https://bob-fms.trainingzone.in/api/practice/${widget.levelId}/${widget.sectionId}/new',
      ),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer ${widget.token}',
      },
    );

    if (response.statusCode == 200) {
      print('Response: ${response.body}');
      print("Level Name: ${widget.levelName}");
        print('Token: ${widget.token}');

      final jsonData = json.decode(response.body);

      if (jsonData.containsKey('data')) {
        final data = jsonData['data'];
        if (data.containsKey('section')) {
          final section = data['section'];
          if (section.containsKey('type')) {
            final type = section['type'];
            print('Type: $type');
          }
        }
      }

      if (jsonData['visualEnabled'] == true) {
        setState(() {
          visualEnabled = true;
        });
      }
      if (jsonData['oralEnabled'] == true) {
        setState(() {
          oralEnabled = true;
        });
      }

      setState(() {
        sectionData = jsonData;
        isLoading = false;
      });
    } else {
      print('Failed to load data from the API: ${response.body}');
    }
  } catch (e) {
    print('Error fetching data from the API: $e');
  }
}

@override
Widget build(BuildContext context) {
  return isLoading
      ? const Center(
          child: CircularProgressIndicator(),
        )
      : Column(
          mainAxisSize: MainAxisSize.min,
          children: [
           Row(
  children: [
    Padding(
      padding: const EdgeInsets.fromLTRB(30,10,0,12),
      child: Container(
        decoration: BoxDecoration(
          color: visualEnabled ? Colors.blue : Colors.grey,
          border: Border.all(
            width: 2.0,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: ElevatedButton(
          onPressed: () {
            setState(() {
              visualEnabled = true;
              oralEnabled = false;
            });
          },
          style: ElevatedButton.styleFrom(
            primary: Colors.transparent,
            onPrimary: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 5,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.remove_red_eye,
                color: Colors.white, // Icon color for Visual is white
              ),
              SizedBox(width: 20),
              Text(
                'Visual',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    ),
    const SizedBox(width: 20),
    Container(
      decoration: BoxDecoration(
        color: oralEnabled ? Colors.blue : Colors.grey,
      border: Border.all(
            width: 2.0,
          ),
        borderRadius: BorderRadius.circular(15),
      ),
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            visualEnabled = false;
            oralEnabled = true;
          });
        },
        style: ElevatedButton.styleFrom(
          primary: Colors.transparent,
          onPrimary: Colors.white,
          elevation: 0,
           padding: const EdgeInsets.symmetric(
              horizontal: 27,
              vertical: 5,
            ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.mic,
              color: Colors.white, // Icon color for Oral is white
            ),
            SizedBox(width: 20),
            Text(
              'Oral',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ],
        ),
      ),
    ),
  ],
),



            Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Container(
                  height: 50,
                  width: 120,
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: const Color.fromARGB(255, 36, 19, 118), width: 3.0),
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: InkWell(
                    onTap: () {
                      if (visualEnabled) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    NextScreen(
      selectedId: widget.sectionId,
      selectedName: widget.levelName,token: widget.token,
      sectionId: null,
      levelId: widget.levelId,
      levelName: widget.levelName,
      type: sectionData.containsKey('data') && sectionData['data']['section'].containsKey('type')
          ? sectionData['data']['section']['type']
          : 'DefaultType', 
    ),
                            ));
                      } else if (oralEnabled) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) =>OralScreen
                        (
      selectedId: widget.sectionId,
      selectedName: widget.levelName,
     
      levelId: widget.levelId,
      levelName: widget.levelName,
      type: sectionData.containsKey('data') && sectionData['data']['section'].containsKey('type')
          ? sectionData['data']['section']['type']
          : 'DefaultType', sectionId: '',token: widget.token,
    ),),
                        );
                      }
                    },




                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.play_arrow,
                          color: Color.fromARGB(255, 36, 19, 118),
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Start',
                          style: TextStyle(fontSize: 18, color: Color.fromARGB(255, 36, 19, 118)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
}
}