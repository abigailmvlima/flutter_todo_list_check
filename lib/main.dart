import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Home(),
  ));
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _toDoController = TextEditingController();
  List _todoList = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _addTodo() {
    setState(() {
      Map<String, dynamic> newTodo = {};
      newTodo["title"] = _toDoController.text;
      _toDoController.text = "";
      newTodo["ok"] = false;
      _todoList.add(newTodo);
      _saveData();  // Salva os dados após adicionar uma nova tarefa
    });
  }

  void _loadData() async {
    String? data = await _readData();
    if (data != null) {
      setState(() {
        _todoList = json.decode(data);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Lista de tarefas"),
        backgroundColor: Colors.deepOrangeAccent,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(17.0, 1.0, 7.0, 1.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _toDoController,
                    decoration: const InputDecoration(
                      labelText: "Nova tarefa",
                      labelStyle: TextStyle(color: Colors.orangeAccent),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: _addTodo,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orangeAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      textStyle: const TextStyle(color: Colors.white)),
                  child: const Text("ADD"),
                )
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 10.0),
              itemCount: _todoList.length,
              itemBuilder: (context, index) {
                return CheckboxListTile(
                  title: Text(_todoList[index]["title"]),
                  value: _todoList[index]["ok"],
                  onChanged: (bool? value) {
                    setState(() {
                      _todoList[index]["ok"] = value;
                      _saveData();  // Salva os dados após alterar o estado de uma tarefa
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<File> _getFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File("${directory.path}/data.json");
  }

  Future<File> _saveData() async {
    String data = json.encode(_todoList);
    final file = await _getFile();
    return file.writeAsString(data);
  }

  Future<String?> _readData() async {
    try {
      final file = await _getFile();
      return file.readAsString();
    } catch (e) {
      return null;
    }
  }
}
