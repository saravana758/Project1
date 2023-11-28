import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'dart:convert';
import 'dart:async';
import 'package:flutter/animation.dart';
import '../Result/result.dart';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import '../Widgets/numpad.dart';

class NextScreen extends StatefulWidget {
  final String selectedId;
  final String selectedName;
  final String levelId;
  final String levelName;
  final String type;
  final String token;

  NextScreen({
    required this.selectedId,
    required this.selectedName,
    required this.levelName,
    required this.type,
    required this.token,
    required sectionId,
    required this.levelId,
  });

  @override
  _NextScreenState createState() => _NextScreenState();
}

class _NextScreenState extends State<NextScreen> with TickerProviderStateMixin {
  Future<Map<String, dynamic>>? apiData;
  List<int> answers = [];
  int currentQuestionIndex = 0;
  Timer? countdownTimer;
  int remainingTime = 10;
  String temporaryAnswer = '';
  String answer = '';
  int _seconds = 0;
  late Timer _timer;
  late CountDownController _controller;
  bool isTimerCompleted = false;

  String get formattedTimer {
    int minutes = _seconds ~/ 60;
    int seconds = _seconds % 60;
    String minutesStr = minutes.toString().padLeft(2, '0');
    String secondsStr = seconds.toString().padLeft(2, '0');
    return '$minutesStr:$secondsStr';
  }

  @override
  void initState() {
    super.initState();
    _controller = CountDownController();
    _controller.start();

    apiData = fetchAndDisplayResponse();
    //startCountdown();
    _startTimer();

    print('Section ID: ${widget.selectedId}');
    print('LevelName: ${widget.levelName}');
    print('Section Type: ${widget.type}');
  }

  Future<Map<String, dynamic>> fetchAndDisplayResponse() async {
    final String baseUrl = 'https://bob-fms.trainingzone.in';
    final String endpoint =
        '/api/practice/${widget.levelId}/${widget.selectedId}';
    final String authToken = 'Bearer ${widget.token}';
    final Uri uri = Uri.parse('$baseUrl$endpoint');

    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': authToken,
    };

    try {
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> parsedData = json.decode(response.body);
        print('API Response: $parsedData');

        final answers = List<String>.from(parsedData['data'].map(
          (item) => item['answers'][0].toString(),
        ));

        for (int i = 0; i < answers.length; i++) {
          print('Answer for Question $i: ${answers[i]}');
        }

        return parsedData;
      } else {
        throw Exception(
            'Failed with status code: ${response.statusCode}\nReason phrase: ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // void startCountdown() {
  //   if (countdownTimer != null && countdownTimer!.isActive) {
  //     countdownTimer!.cancel();
  //   }

  //   countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
  //     setState(() {
  //       remainingTime = 10 - timer.tick;
  //     });

  //     if (remainingTime == 0) {
  //       timer.cancel();
  //       if (temporaryAnswer.isNotEmpty) {
  //         moveToNextQuestion();
  //       }
  //     }
  //   });
  // }

  void moveToNextQuestion() {
    if (currentQuestionIndex < 9) {
      setState(() {
        currentQuestionIndex++;
        temporaryAnswer = '';
        _controller.restart(duration: 20);
        remainingTime = 10;
        //startCountdown();
      });
    } else {
      print('All questions are completed.');
      countdownTimer?.cancel();
    }
  }

  void showEnterAnswerDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          content: Container(
            height: 130.0,
            width: 60.0,
            child: Column(
              children: [
                ListTile(
                  title: Text(
                    'Please Enter Answer!',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  leading: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                    child: Icon(
                      Icons.error,
                      color: Colors.red,
                      size: 30.0,
                    ),
                  ),
                ),
                SizedBox(height: 2.0), // Adjust spacing as needed
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    fixedSize:
                        Size(30.0, 10.0), // Adjust width and height as needed
                  ),
                  child: Text('OK'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void ValidAnswerDialoge() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          content: Container(
            height: 130.0,
            width: 60.0,
            child: Column(
              children: [
                ListTile(
                  title: Text(
                    'Please Enter Valid Answer!',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  leading: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                    child: Icon(
                      Icons.error,
                      color: Colors.red,
                      size: 30.0,
                    ),
                  ),
                ),
                SizedBox(height: 2.0), // Adjust spacing as needed
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    fixedSize:
                        Size(30.0, 10.0), // Adjust width and height as needed
                  ),
                  child: Text('OK'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void handleBackspace() {
    if (temporaryAnswer.isNotEmpty) {
      setState(() {
        temporaryAnswer =
            temporaryAnswer.substring(0, temporaryAnswer.length - 1);
      });
    }
  }

  int correctAnswerCount = 0;

  void handleSubmit() {
    isTimerCompleted = false;
    if (temporaryAnswer == "0") {
      ValidAnswerDialoge();
    } else if (temporaryAnswer.isNotEmpty) {
      apiData?.then((data) {
        final currentQuestionData = data['data'][currentQuestionIndex];
        final correctAnswer = currentQuestionData['answers'][0];

        print('Temporary Answer: $temporaryAnswer');
        print('Answer: $correctAnswer');

        if (temporaryAnswer == correctAnswer) {
          answers.add(currentQuestionIndex);
          correctAnswerCount++;
        }

        answer = '';
        temporaryAnswer = '';

        if (currentQuestionIndex < 9) {
          moveToNextQuestion();
        } else {
          print('All questions are completed.');
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => ResultScreen(
              correctAnswerCount: answers.length,
              formattedTimer: formattedTimer,
              answers: [],
              selectedId: widget.selectedId,
              levelId: widget.levelId,
              sectionId: '',
              token: widget.token,
              levelName: widget.levelName,
              type: widget.type,
            ),
          ));
          countdownTimer?.cancel();
          print('Total correct answers: $correctAnswerCount');
          print('Time taken: $formattedTimer');
          if (answers.length == 10) {
            print('All questions are answered correctly!');
          } else {
            print('Some questions are not answered correctly.');
          }
        }
      });
    } else {
      showEnterAnswerDialog();
      // showDialog(
      //   context: context,
      //   builder: (context) {
      //     return AlertDialog(
      //        shape: RoundedRectangleBorder(
      //     borderRadius: BorderRadius.circular(15.0), // Adjust border radius as needed
      //   ),
      //   contentPadding: EdgeInsets.all(0),
      //   title: ListTile(
      //     title: Text(
      //       'Please Enter Answer!',
      //       style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
      //     ),
      //     leading: Icon(
      //       Icons.error,
      //       color: Colors.red,
      //       size: 40.0,
      //     ),
      //   ),
      //       actions: <Widget>[
      //         Center(
      //           child: Padding(
      //             padding: const EdgeInsets.only(bottom: 40),
      //             child: ElevatedButton(
      //               onPressed: () {
      //                 Navigator.of(context).pop();
      //               },
      //               child: Text('OK'),
      //             ),
      //           ),
      //         ),
      //       ],
      //     );
      //   },
      // );
    }
  }

  void _startTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = Timer.periodic(oneSec, (Timer timer) {
      setState(() {
        _seconds++;
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 121, 14, 170),
        title: Center(
          child: Text(
            'Brainobrain',
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
        ),
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.only(right: 6.0),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 14, 13, 5),
              child: Row(
                children: [
                  Lottie.asset(
                    'assets/3.json',
                  ),
                  SizedBox(width: 0),
                  Text(
                    '$formattedTimer',
                    style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            height: 30,
            color: Color.fromARGB(236, 223, 222, 222),
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
                      color: Color.fromARGB(255, 50, 136, 158),
                      fontSize: 15,
                    ),
                  ),
                  SizedBox(width: 2),
                  Text(
                    '>',
                    style: TextStyle(
                      color: Color.fromARGB(255, 50, 136, 158),
                      fontSize: 15,
                    ),
                  ),
                  SizedBox(width: 2),
                  Text(
                    widget.type,
                    style: TextStyle(
                      color: Color.fromARGB(255, 4, 84, 104),
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ),
          buildQuestionInfo(),
          buildQuestionView(),
          buildAnswerInput(),
          buildAnswerPad(),
        ],
      ),
    );
  }

  Widget buildQuestionInfo() {
    return FutureBuilder<Map<String, dynamic>>(
      future: apiData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else if (!snapshot.hasData || snapshot.data == null) {
          return Text('No questions available');
        } else {
          return Row(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 10, 0),
                child: Container(
                  height: 50,
                  width: 220,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Question ${currentQuestionIndex + 1} of 10',
                          style: TextStyle(
                              fontSize: 21, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 49,
              ),
              CircularCountDownTimer(
                duration: 20,
                controller: _controller,
                width: 30,
                height: 30,
                ringColor: Colors.transparent,
                fillColor: Colors.red,
                strokeWidth: 5.0,
                textStyle: TextStyle(
                    fontSize: 18.0,
                    color: Colors.black,
                    fontWeight: FontWeight.bold),
                isReverse: true,
                isReverseAnimation: true,
                onComplete: () {
                  setState(() {
                    isTimerCompleted = true;
                  });
                  if (temporaryAnswer.isEmpty) {
                    showEnterAnswerDialog();
                  } else {
                    handleSubmit();
                  }
                },
              )
            ],
          );
        }
      },
    );
  }

  Widget buildQuestionView() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 7, 10, 0),
      child: Container(
        height: 260,
        child: FutureBuilder<Map<String, dynamic>>(
          future: apiData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data == null) {
              return Center(child: Text('No questions available'));
            } else {
              final data = snapshot.data!;
              final questionList = List<List<String>>.from(
                data['data'].map(
                  (item) => List<String>.from(item['question']),
                ),
              );

              final currentQuestion = questionList[currentQuestionIndex];

              return Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.blue,
                    width: 3.0,
                  ),
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: buildQuestionGridView(currentQuestion),
              );
            }
          },
        ),
      ),
    );
  }

  Widget buildQuestionGridView(List<String> currentQuestions) {
    bool isMultiplicationSection = widget.type == 'Multiplication';

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isMultiplicationSection ? 1 : 5,
        crossAxisSpacing: 1.0,
        mainAxisSpacing: 1.0,
      ),
      itemCount: currentQuestions.length,
      itemBuilder: (context, index) {
        if (isMultiplicationSection) {
          if (index == 1) {
            // Display an empty container at index 1 for Multiplication section
            return Container();
          } else if (index == 0) {
            // Display the multiplication symbol and entire question content at index 0 for Multiplication section
            return Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 75),
              child: Container(
                width: 20,
                height: 15,
                child: Center(
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(fontSize: 50),
                      children: [
                        TextSpan(
                          text: '${int.tryParse(currentQuestions[0]) ?? 0}',
                          style: TextStyle(
                              color: const Color.fromARGB(255, 12, 96,
                                  165)), // Change color for the first part
                        ),
                        TextSpan(
                          text: '  * ',
                          style: TextStyle(
                              color: const Color.fromARGB(255, 170, 17,
                                  6)), // Change color for the second part
                        ),
                        TextSpan(
                          text: '${int.tryParse(currentQuestions[1]) ?? 0}',
                          style: TextStyle(
                              color: Color.fromARGB(255, 23, 129,
                                  9)), // Change color for the second part
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }
        } else {
          // Display the entire question content for all other indices in other sections
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              alignment: Alignment.center,
              child: Text(
                '${int.tryParse(currentQuestions[index]) ?? 0}',
                style: TextStyle(fontSize: 25),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          );
        }
        // You can also return an empty Container() if you don't want to display anything
        return Container();
      },
    );
  }

  Widget buildAnswerInput() {
    return SizedBox(
      height: 10,
    );
  }

  Widget buildAnswerPad() {
    return Column(
      children: [
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(50, 0, 10, 0),
              child: Container(
                height: 50,
                width: 150,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.blue,
                    width: 3.0,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: Text(
                      temporaryAnswer,
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 54, 10, 156),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 9,
            ),
            ElevatedButton(
              onPressed: handleSubmit,
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                'Submit',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(3.0),
          child: NumberPad(
            onTap: (value) {
              if (value == 'backspace') {
                handleBackspace();
              } else {
                setState(() {
                  temporaryAnswer += value;
                });
              }
            },
          ),
        ),
      ],
    );
  }
}
