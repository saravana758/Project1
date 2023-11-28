import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../home/home_screen.dart';
import 'urls.dart'; //

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late String _email = '';
  late String _password = '';
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    height: 80,
                  ),
                  Center(
                    child: Text(
                      "Brainobrain",
                      style:
                          TextStyle(fontSize: 33, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Center(
                    child: Text(
                      "Dictation",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  Text(
                    "LOGIN",
                    style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10.0, vertical: 5),
                    child: TextFormField(
                      onChanged: (value) {
                        setState(() {
                          _email = value;
                        });
                      },
                      validator: (email) {
                        if (email!.isEmpty) {
                          return "Please Enter Email";
                        }
                        bool emailValid =
                            RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                .hasMatch(email);
                        if (!emailValid) {
                          return "Please enter a valid email address";
                        }
                        return null;
                      },
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                        prefixIcon: Icon(
                          Icons.email,
                          color: Colors.orange,
                        ),
                        labelText: "Email Address",
                        labelStyle: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10.0, vertical: 5),
                    child: TextFormField(
                      onChanged: (value) {
                        setState(() {
                          _password = value;
                        });
                      },
                      validator: (password) {
                        if (password!.isEmpty) {
                          return "Please Enter Password";
                        } else if (password.length < 8 ||
                            password.length > 14) {
                          return "Password is Wrong!!!";
                        }
                        return null;
                      },
                      obscureText: _obscureText,
                      decoration: InputDecoration(
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                        prefixIcon: Icon(
                          Icons.lock_open,
                          color: Colors.orange,
                        ),
                        labelText: "Password",
                        labelStyle: TextStyle(color: Colors.black),
                        suffixIcon: GestureDetector(
                          onTap: () {
                            setState(() {
                              _obscureText = !_obscureText;
                            });
                          },
                          child: Icon(
                            _obscureText
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: SizedBox(
                        height: 54.0,
                        width: 350.0,
                        child: OutlinedButton(
                          onPressed: () {
                            _login();
                          },
                          child: Text(
                            "Login to account",
                            style: TextStyle(
                                fontSize: 30.0, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      print("Email: $_email");
      print("Password: $_password");

      final Map<String, String> requestBody = {
        "email": _email,
        "password": _password,
      };

      final String apiUrl = "$baseUrl/api/login"; // Fix the URL typo

      try {
        final response = await http.post(
          Uri.parse(apiUrl),
          body: json.encode(requestBody),
          headers: {
            "Content-Type": "application/json",
            "Accept": "application/json",
          },
        );

        print("Response: ${response.body}");

        if (response.statusCode == 200) {
          final Map<String, dynamic> responseData = json.decode(response.body);
          final String token = responseData['data']['token'];

          final storage = FlutterSecureStorage();
          await storage.write(key: 'token', value: token);

          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => HomeScreen(token: token),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Container(
                alignment: Alignment.center,
                child: Text(
                  "Invalid Details!",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.normal),
                ),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (error) {
        print("Error: $error");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("An error occurred while logging in.$error"),
          ),
        );
      }
    }
  }
}
