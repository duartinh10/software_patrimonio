import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Busca extends StatefulWidget {
  const Busca({Key? key}) : super(key: key);

  @override
  _BuscaState createState() => _BuscaState();
}

class _BuscaState extends State<Busca> {
  final TextEditingController _filterController = TextEditingController();
  List<Map<String, dynamic>> _patrimonios = [];
  List<Map<String, dynamic>> _filteredPatrimonios = [];

  @override
  void initState() {
    super.initState();
    _fetchPatrimonios();
  }

  Future<void> _fetchPatrimonios() async {
    const String url = "http://localhost/server/processa_bdCeet.php";
    final Map<String, String> data = {'comando': 'listar'};

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        if (responseBody['status'] == 'success') {
          setState(() {
            _patrimonios = List<Map<String, dynamic>>.from(responseBody['produtos']);
            _filteredPatrimonios = _patrimonios;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao buscar: ${responseBody['message']}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (error) {
      print("Erro durante a requisição: $error");
    }
  }

  void _filterPatrimonios(String query) {
    setState(() {
      _filteredPatrimonios = _patrimonios.where((patrimonio) {
        return patrimonio['marca'].toLowerCase().contains(query.toLowerCase()) ||
               patrimonio['modelo'].toLowerCase().contains(query.toLowerCase()) ||
               patrimonio['data'].contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors:  [Color(0xFF1C3A5C), Color(0xFF004d40), Color(0xFF311B92)], // A última cor já é um roxo escuro
            
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _filterController,
                decoration: InputDecoration(
                  labelText: 'Filtrar por marca, modelo ou data',
                  labelStyle: const TextStyle(color: Colors.white),
                  fillColor: Colors.white.withOpacity(0.1),
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color.fromARGB(255, 0, 0, 0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color.fromARGB(255, 0, 0, 0)),
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search, color: Colors.black),
                    onPressed: () => _filterPatrimonios(_filterController.text),
                  ),
                ),
                onChanged: _filterPatrimonios,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: _filteredPatrimonios.length,
                  itemBuilder: (context, index) {
                    final patrimonio = _filteredPatrimonios[index];
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      elevation: 4,
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(8.0),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            'http://localhost/server/' + patrimonio['imagem'],
                            width: 45,
                            height: 45,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              print(
                                  'Erro ao carregar imagem: ${error.toString()} | URL: http://localhost/server/' +
                                      patrimonio['imagem']);
                              return const Icon(Icons.error);
                            },
                          ),
                        ),
                        title: Text(
                          'Marca: ${patrimonio['marca']}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Modelo: ${patrimonio['modelo']}', style: const TextStyle(color: Colors.white)),
                            Text('Cor: ${patrimonio['cor']}', style: const TextStyle(color: Colors.white)),
                            Text('Data: ${patrimonio['data']}', style: const TextStyle(color: Colors.white)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}