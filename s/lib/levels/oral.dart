import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
//import '../Result/result.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:lottie/lottie.dart';
import 'package:s/Result/oralresult.dart';
import 'dart:async';



class OralScreen extends StatefulWidget {
  final String selectedId;
  final String selectedName;
  final String levelId;
  final String levelName;
  final String type;
  final String token;
  OralScreen(
      {required this.selectedId,
      required this.selectedName,
      required this.levelName,
      required this.type,
      required sectionId,
      required this.levelId,
      required this.token});

  @override
  _OralScreenState createState() => _OralScreenState();
}

class _OralScreenState extends State<OralScreen> with TickerProviderStateMixin {
  TextEditingController _controller = TextEditingController();
  Future<Map<String, dynamic>>? apiData;

  List<int> answers = [];
  int currentQuestionIndex = 0;
  String temporaryAnswer = '';
  String answer = '';
  Timer? timer;
  int currentQuestionValue = 0;
  Timer? countdownTimer;
  int remainingTime = 3;
  FlutterTts flutterTts = FlutterTts();
  String previousValue = '';
  int _seconds = 0;
  List<List<String>> questionList = [];
  late AnimationController _borderColorController;
  late Animation<Color?> _borderColorAnimation;

  String get formattedTimer {
    int minutes = _seconds ~/ 60;
    int seconds = _seconds % 60;
    String minutesStr = minutes.toString().padLeft(2, '0');
    String secondsStr = seconds.toString().padLeft(2, '0');
    return '$minutesStr:$secondsStr';
  }

  set _timer(Timer _timer) {}

  @override
  void initState() {
    super.initState();

    _borderColorController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1), // Adjust the duration as needed
    );

    _borderColorAnimation = ColorTween(
      begin: Colors.blue, // Set the initial color
      end: Colors.red, // Set the final color
    ).animate(_borderColorController);

    // Optionally, add a listener to handle updates in the animation
    _borderColorController.addListener(() {
      setState(() {}); // Update the UI when the animation value changes
    });

    // Optionally, start the animation (e.g., when the countdown starts)
    _borderColorController.forward();

    apiData = fetchAndDisplayResponse();
    configureTts();
    startCountdown();
    _startTimer();
  }

  Future<void> configureTts() async {
    await flutterTts.setLanguage('en-US');
    await flutterTts
        .setVoice('en-US-male-voice-variant' as Map<String, String>);
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(1);
  }

  void startCountdown() {
    countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        remainingTime = 3 - timer.tick;
      });

      if (remainingTime == 0) {
        timer.cancel();
        setState(() {
          currentQuestionValue++;
          remainingTime = 3;
        });

        if (currentQuestionValue == questionList[currentQuestionIndex].length) {
          showNumberPadDialog();
        } else {
          startCountdown();
        }
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    _borderColorController.dispose();
    super.dispose();
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

        // Assuming 'data' is a list of questions in the API response

        return parsedData;
      } else {
        throw Exception(
            'Failed with status code: ${response.statusCode}\nReason phrase: ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Error: $e');
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

  void showNumberPadDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
            backgroundColor: Colors
                .transparent, // Set a transparent background for the AlertDialog
            content: Container(
              height: 500, // Adjust the height of the Container
              width: 300, // Adjust the width of the Container
              decoration: BoxDecoration(
                color: Colors.white, // Set background color for the Container
                borderRadius: BorderRadius.circular(8.0),
              ),
              padding: EdgeInsets.symmetric(
                  vertical: 20, horizontal: 10), // Adjust content padding
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.0),
                    height: 90.0, // Adjust the height as needed
                    width: 230.0, // Adjust the width as needed
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color.fromARGB(255, 120, 184, 236),
                        width: 4.0,
                      ),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        // labelText: "Enter an answer",
                        labelStyle: TextStyle(
                          color: Color.fromARGB(255, 233, 86, 157),
                        ),
                        border: InputBorder.none,
                      ),
                      style: TextStyle(
                          color: Color.fromARGB(255, 41, 7, 141),
                          fontSize: 33.0,
                          fontWeight: FontWeight.bold),
                      keyboardType: TextInputType.number,
                      textAlign:
                          TextAlign.center, // Align text horizontally center
                      textAlignVertical: TextAlignVertical.center,
                    ),
                  ),

                  buildAnswerPad(), // Add the answer pad widget here
                  SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildNumberButton("1"),
                      _buildNumberButton("2"),
                      _buildNumberButton("3"),
                    ],
                  ),
                  SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildNumberButton("4"),
                      _buildNumberButton("5"),
                      _buildNumberButton("6"),
                    ],
                  ),
                  SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildNumberButton("7"),
                      _buildNumberButton("8"),
                      _buildNumberButton("9"),
                    ],
                  ),
                  SizedBox(height: 5),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(70, 0, 0, 0),
                    child: Row(
                      children: [
                        _buildNumberButton("0"),

                        _buildNumberButton(Icon(
                          Icons.backspace,
                          color: Colors.red,
                          size: 30,
                        )),
                        // _buildNumberButton("submit"),
                      ],
                    ),
                  ),
                ],
              ),
            ));
      },
    );
  }

  Widget _buildNumberButton(dynamic child) {
    return TextButton(
      onPressed: () {
        _handleNumberButtonPress(child);
      },
      style: TextButton.styleFrom(
        padding: EdgeInsets.all(16.0), // Adjust the padding as needed
        textStyle: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
      ),
      child: child is String
          ? Text(
              child,
              style: TextStyle(
                  fontSize: 27.0,
                  color: Colors.black,
                  fontWeight: FontWeight.bold),
            )
          : child is Widget
              ? child
              : SizedBox.shrink(),
    );
  }

  Widget _buildNumbberButton(String buttonText) {
    return ElevatedButton(
      onPressed: () {
        _handleNumberButtonPress(buttonText);
      },
      child: Text(buttonText),
    );
  }

  void _handleNumberButtonPress(dynamic value) {
    setState(() {
      if (value is String) {
        if (value == "backspace") {
          if (_controller.text.isNotEmpty) {
            _controller.text =
                _controller.text.substring(0, _controller.text.length - 1);
          }
        } else if (value == "submit") {
          handleSubmit();
          _controller.clear();
          Navigator.pop(context);
        } else {
          temporaryAnswer = _controller.text += value;
        }
      } else if (value is Icon && value.icon == Icons.backspace) {
        // Handle backspace icon press
        if (_controller.text.isNotEmpty) {
          _controller.text =
              _controller.text.substring(0, _controller.text.length - 1);
        }
      }
    });
  }

  void moveToNextQuestion() {
    if (currentQuestionIndex < 9) {
      setState(() {
        currentQuestionIndex++;
        currentQuestionValue = 0;
        temporaryAnswer = '';

        startCountdown();
      });
    } else {
      print('All questions are completed.');

      print('Total correct answers: ${answers.length}');
      if (answers.length == 10) {
        print('All questions are answered correctly!');
      } else {
        print('Some questions are not answered correctly.');
      }

      print('Total correct answers: ${answers.length} out of 10');
    }
  }

  void handleBackspace() {
    if (temporaryAnswer.isNotEmpty) {
      setState(() {
        temporaryAnswer =
            temporaryAnswer.substring(0, temporaryAnswer.length - 1);
      });
    }
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
                  fixedSize: Size(30.0, 10.0),
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

  void handleSubmit() {
     if (temporaryAnswer == "0") {
      print('Temporary Answer is 0. Showing dialog.');
      ValidAnswerDialoge();
    } else if(temporaryAnswer.isNotEmpty) {
      apiData?.then((data) {
        final currentQuestionData = data['data'][currentQuestionIndex];
        final correctAnswer = currentQuestionData['answers'][0];

        print('Temporary Answer: $temporaryAnswer');
        print('Answer: $correctAnswer');

        if (temporaryAnswer == correctAnswer) {
          answers.add(currentQuestionIndex);
        }

        answer = '';
        temporaryAnswer = '';

        if (currentQuestionIndex < 9) {
          moveToNextQuestion();
        } else {
          print('All questions are completed.');
          // This is where the navigation should occur
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => oralResultScreen(
              correctAnswerCount: answers.length,
              formattedTimer: formattedTimer,
              answers: [],
              selectedId: widget.selectedId,
              levelId: widget.levelId,
              sectionId: '',token: widget.token, levelName: widget.levelName, 
      type: widget.type, // 
            ),
          ));
          print('Time taken: $formattedTimer');
          if (answers.length == 10) {
            print('All questions are answered correctly!');
          } else {
            print('Some questions are not answered correctly.');
          }
        }
      });
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: ListTile(
              title: Text(
                'Please Enter Answer!',
                style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
              ),
              leading: Icon(
                Icons.error,
                color: Colors.red,
                size: 48.0,
              ),
            ),
            actions: <Widget>[
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('OK'),
                  ),
                ),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> speakText(String text) async {
    await flutterTts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:  AppBar(
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
          // buildAnswerInput(),
          // buildAnswerPad(),
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
                              fontSize: 25, fontWeight: FontWeight.bold),
                        ),
                        // SizedBox(height: 10),
                        // Text(
                        //   'Answer: $answer',
                        //   style: TextStyle(
                        //       fontSize: 20, fontWeight: FontWeight.normal),
                        // ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 40,
              ),
              buildCountdownContainer(),
            ],
          );
        }
      },
    );
  }

  Widget buildCountdownContainer() {
    Color textColor =
        remainingTime <= 10 ? Colors.red : const Color.fromARGB(255, 26, 1, 1);

    return AnimatedBuilder(
      animation: _borderColorAnimation,
      builder: (context, child) {
        return Container(
          height: 40,
          width: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: _borderColorAnimation.value!,
              width: 5.0,
            ),
          ),
          child: Center(
            child: Text(
              '$remainingTime',
              style: TextStyle(
                  color: textColor, fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        );
      },
    );
  }

  Widget buildQuestionView() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 30, 20, 0),
      child: Container(
        height: 300,
        decoration: BoxDecoration(
        
              
          border: Border.all(
            color: Colors.blue,
            width: 3.0,
          ),
          borderRadius: BorderRadius.circular(15.0),
        ),
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
              questionList = List<List<String>>.from(
                data['data'].map(
                  (item) => List<String>.from(item['question']),
                ),
              );
              final currentQuestion = questionList[currentQuestionIndex];

              return buildQuestionListView(currentQuestion);
            }
          },
        ),
      ),
    );
  }

  Widget buildQuestionListView(List<String> currentQuestion) {
    String textToSpeak = currentQuestion[currentQuestionValue];

    // Define a list of colors
    List<Color> textColors = [
      const Color.fromARGB(255, 252, 158, 158),
      Colors.blue,
      Colors.red,
      Colors.pink,
      Color.fromARGB(255, 23, 168, 4),
      Colors.orange,
      Colors.blueGrey,
      Color.fromARGB(255, 45, 3, 168)
    ];

    
    Color textColor = textColors[currentQuestionValue % textColors.length];
 if (widget.type == "Multiplication") {
    
     return Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 75),
              child: Container(
                width: 300,
                height: 155,
                child: Center(
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(fontSize: 50),
                      children: [
                        TextSpan(
                          text: '${int.tryParse(currentQuestion[0]) ?? 0}',
                          style: TextStyle(
                              color: const Color.fromARGB(255, 12, 96,
                                  165)), // Change color for the first part
                        ),
                        TextSpan(
                          text: '  × ',
                          style: TextStyle(
                              color: const Color.fromARGB(255, 170, 17,
                                  6)), // Change color for the second part
                        ),
                        TextSpan(
                          text: '${int.tryParse(currentQuestion[1]) ?? 0}',
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
  } else  {
     
        speakText(textToSpeak);
        
        previousValue = textToSpeak;
     
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          height: 70,
          width: 200,
          child: Center(
            child: Text(
              textToSpeak,
              style: TextStyle(fontSize: 55, color: textColor),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildAnswerInput() {
    return SizedBox(
      height: 25,
    );
  }

  Widget buildAnswerPad() {
    return Column(
      children: [
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            if (_controller.text.isEmpty) {
              // Show dialog for empty answer
              showDialog(
                context: context,
                builder: (context) => buildAlertDialog(),
              );
            } else {
              // Handle non-empty answer submission
              handleSubmit();
              Navigator.pop(context);
              _controller.clear();
            }
          },
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
        // Add your buildToggleCard() function here if needed,
        // buildToggleCard(),
      ],
    );
  }

  Widget buildAlertDialog() {
    return AlertDialog(
      title: ListTile(
        title: Text(
          'Please Enter Answer!',
          style: TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
        ),
        leading: Icon(
          Icons.error,
          color: Colors.red,
          size: 48.0,
        ),
      ),
      actions: <Widget>[
        Center(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ),
        ),
      ],
    );
  }
}