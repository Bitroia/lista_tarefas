import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:async';
import 'dart:convert';


class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  List _listaTarefas = [];

  Map<String, dynamic> _ultimaTarefaRemovida = Map();

  TextEditingController _controllerTarefa = TextEditingController();

  Future<File>_getFile() async {

    final diretorio = await getApplicationDocumentsDirectory();
    return File ("${diretorio.path}/dados.json");
  }

  _salvarTarefa (){
    String textoDigitado = _controllerTarefa.text;

    Map<String, dynamic> tarefa = Map();
    tarefa["titulo"] = textoDigitado;
    tarefa["realizada"] = false;

    setState(() {
      _listaTarefas.add(tarefa);
    });

    _salvarArquivo();
    _controllerTarefa.text="";
  }

  _salvarArquivo () async {

    var arquivo = await _getFile();

    String dados = json.encode(_listaTarefas);
    arquivo.writeAsString(dados);
  }

  _lerArquivo() async {
    try{
      final arquivo = await _getFile();
      return arquivo.readAsString();

    } catch(e){
      return null;
    }
  }

  @override
  void initState(){
    super.initState();

    _lerArquivo().then((dados) {
      setState(() {
        _listaTarefas = json.decode(dados);
      });
    });
  }

  removeItem(index){
    _listaTarefas.removeAt(index);
  }

  recuperaItem(index){
    _ultimaTarefaRemovida = _listaTarefas[index];
  }

  Widget criarItemLista (context, index){
    //final item = _listaTarefas[index]["titulo"];

    return Dismissible(
        key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
        direction: DismissDirection.endToStart,
        onDismissed: (direction){
          //recuperar ultimo item excluido
          recuperaItem(index);

          //Remove item da lista
          removeItem(index);
          _salvarArquivo();

          //snackbar
          final snackbar = SnackBar(
            backgroundColor: Colors.green,
              duration: Duration(
                seconds: 3
              ),
              action: SnackBarAction(
                label: "Desfazer",
                textColor: Colors.white,
                onPressed: (){
                  //Insere novamente o item removido na lista
                  setState(() {
                    _listaTarefas.insert(index, _ultimaTarefaRemovida);
                  });
                  _salvarArquivo();
                },
              ),
              content: Text("Tarefa removida!")
          );

          ScaffoldMessenger.of(context).showSnackBar(snackbar);
        },
        background: Container(
          color: Colors.red,
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                Icons.delete,
                color: Colors.white,
              )
            ],
                mainAxisAlignment: MainAxisAlignment.end,
          ),
        ),
        child: CheckboxListTile(
            title: Text(_listaTarefas[index]['titulo']),
            value: _listaTarefas[index]['realizada'],
            onChanged: (valorAlterado){
              setState(() {
                _listaTarefas[index]['realizada'] = valorAlterado;
              });
              _salvarArquivo();
              print("Valor" + valorAlterado.toString());
            }
        ),
    );
  }

  @override
  Widget build(BuildContext context) {
   // _salvarArquivo();
    print("itens: " + DateTime.now().millisecondsSinceEpoch.toString());

    return Scaffold(
      appBar: AppBar(
        title: Text("Lista de tarefas"),
        backgroundColor: Colors.purple,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        backgroundColor: Colors.purple,
        onPressed: (){
          showDialog(
              context: context,
              builder: (context){
                return AlertDialog(
                  title: Text("Adicionar Tarefa"),
                  content: TextField(
                    controller: _controllerTarefa,
                    decoration: InputDecoration(
                      labelText: "Digite sua tarefa",
                    ),
                    onChanged: (text){

                    },
                  ),
                  actions: [
                    ElevatedButton(
                        onPressed: (){
                          Navigator.pop(context);
                        },
                        child: Text("Cancelar")
                    ),

                    ElevatedButton(onPressed: (){
                      _salvarTarefa();
                      Navigator.pop(context);
                    },
                        child: Text(
                            "Salvar"
                        ),
                    )
                  ],
                );
              }
          );
        },
      ),
      body: Column(
        children: [
          Expanded(
              child: ListView.builder(
                itemCount: _listaTarefas.length,
                  itemBuilder: criarItemLista,
              ),
          )
        ],
      ),
    );
  }
}
