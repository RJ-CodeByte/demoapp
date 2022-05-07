import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _textNameController = TextEditingController();
  final _textProfessionController = TextEditingController();
  List<String> _userNameList = [];
  List<String> _userProfessionList = [];
  List<String> _userIdList = [];

  void initState() {
    super.initState();
    _displayData();
  }

  final _formkey = GlobalKey<FormState>();
  bool isLoading = true;

  // List<User> userlist = [];

  final databaseReference = FirebaseDatabase.instance.ref();

  void addData() async {
    _formkey.currentState?.save();

    print("Name" + _textNameController.text);
    var url =
        "https://userslist-3ea1d-default-rtdb.firebaseio.com/" + "data.json";
    try {
      final response = await http.post(
        Uri.parse(url),
        body: json.encode({
          "name": _textNameController.text,
          "profession": _textProfessionController.text
        }),
      );
    } catch (error) {
      throw error;
    }
  }

  void _showDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Add New user"),
          content: Column(
            children: <Widget>[
              Form(
                key: _formkey,
                child: Column(
                  children: [
                    TextFormField(
                      textInputAction: TextInputAction.next,
                      controller: _textNameController,
                      autofocus: true,
                      onSaved: (value) {
                        _textNameController.text = value.toString();
                      },
                      decoration: const InputDecoration(
                        labelText: 'Add Name',
                      ),
                    ),
                    TextFormField(
                      textInputAction: TextInputAction.done,
                      controller: _textProfessionController,
                      autofocus: true,
                      onSaved: (value) {
                        _textProfessionController.text = value.toString();
                      },
                      decoration: const InputDecoration(
                        labelText: 'Add Profession',
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
          actions: <Widget>[
            ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancel')),
            ElevatedButton(
                onPressed: () {
                  addData();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: const Text("User Added Successfully"),
                  ));
                },
                child: const Text('Add'))
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Welcome to home Screen"),
      ),
      body: isLoading && _userIdList.length==0
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _userNameList.length,
              itemBuilder: (BuildContext context, int index) {              
                 return Card(
                  child: InkWell(
                    child: Container(
                      padding: EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                Text(
                                  "Name:${_userNameList[index]}",
                                  style: TextStyle(fontSize: 20),
                                ),
                                Text("Profession:${_userProfessionList[index]}",
                                    style: TextStyle(fontSize: 20)),
                              ],
                            ),
                          ),
                          IconButton(
                              onPressed: () {
                                var key=_userIdList[index];
                                _DeleteData(key);
                                setState(() {
                                  _userNameList.removeAt(index);
                                  _userProfessionList.removeAt(index);
                                });
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                  content: const Text("User Deleted Successfully"),
                                ));
                              },
                              icon: const Icon(Icons.delete_outlined)),
                        ],
                      ),
                    ),
                  ),
                );
              }),
      floatingActionButton: FloatingActionButton(
        onPressed: _showDialog,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  _displayData() async {
    var url =
        "https://userslist-3ea1d-default-rtdb.firebaseio.com/" + "data.json";
    try {
      final response = await http.get(Uri.parse(url));
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      if (extractedData == null) {
        return;
      }
      extractedData.forEach((userId, userData) {
        _userNameList.add(userData["name"]);
        _userProfessionList.add(userData["profession"]);
        _userIdList.add(userId);
      });
      setState(() {
        isLoading = false;
      });
    } catch (error) {
      throw error;
    }
  }

  _DeleteData(var key) async {
      databaseReference.child("data").child(key).remove();
  }
}
