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
  late Map<String, dynamic> _lastRemoved;
  late int _lastRemovedPos;

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
      _saveData(); // Salva os dados após adicionar uma nova tarefa
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

  Future<Null> _refresh() async {
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _todoList.sort((a, b) {
        if(a["ok"] && !b["ok"]) return 1;
        else if(!a["ok"] && b["ok"]) return -1;
        else return 0;
        });
      _saveData();
    });
    return null;
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
            child: RefreshIndicator(onRefresh: _refresh,
            child: ListView.builder(
                padding: const EdgeInsets.only(top: 10.0),
                itemCount: _todoList.length,
                itemBuilder: buildItem),
                )
          ),
        ],
      ),
    );
  }

  Widget buildItem(BuildContext context, int index) {
    return Dismissible(
      key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
      background: Container(
        color: Colors.red,
        child: const Align(
          alignment: Alignment(-0.9, 0.0),
          child: Icon(Icons.delete, color: Colors.white,),
        ),
      ),
      direction: DismissDirection.startToEnd,
      child: CheckboxListTile(
        title: Text(_todoList[index]["title"]),
        value: _todoList[index]["ok"],
        onChanged: (bool? value) {
          setState(() {
            _todoList[index]["ok"] = value;
            _saveData(); // Salva os dados após alterar o estado de uma tarefa
          });
        },
      ),
      onDismissed: (direction){
        setState(() {
          _lastRemoved = Map.from(_todoList[index]);
          _lastRemovedPos = index;
          _todoList.removeAt(index);

          _saveData();

          final snack = SnackBar(
            content: Text('Tarefa "${_lastRemoved["title"]}" removida!'),
            action: SnackBarAction(
                label: "Desfazer",
                onPressed: () {
                  setState(() {
                    _todoList.insert(_lastRemovedPos, _lastRemoved);
                    _saveData();
                  });
                }
            ),
            duration: const Duration(seconds: 2),
          );
          ScaffoldMessenger.of(context).showSnackBar(snack);
        });
      },
    );
  }

  Future<File> _getFile() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final path = directory.path;
      print("Path do arquivo: $path");
      return File("$path/data.json");
    } catch (e) {
      print("Erro ao obter o arquivo: $e");
      rethrow; // Repassa o erro para ser tratado em outros lugares
    }
  }

  Future<File> _saveData() async {
    try {
      String data = json.encode(_todoList);
      final file = await _getFile();
      print("Salvando dados...");
      return file.writeAsString(data);
    } catch (e) {
      print("Erro ao salvar os dados: $e");
      rethrow; // Repassa o erro para tratamento adicional, se necessário
    }
  }

  Future<String?> _readData() async {
    try {
      final file = await _getFile();
      if (await file.exists()) {
        print("Lendo dados...");
        return file.readAsString();
      } else {
        print("Arquivo não encontrado");
        return null;
      }
    } catch (e) {
      print("Erro ao ler o arquivo: $e");
      return null; // Garante que o código não falhe, mesmo se ocorrer um erro
    }
  }
}




