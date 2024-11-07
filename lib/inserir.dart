import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class Inserir extends StatefulWidget {
  const Inserir({Key? key}) : super(key: key);

  @override
  _InserirState createState() => _InserirState();
}

class _InserirState extends State<Inserir> {
  final TextEditingController _corController = TextEditingController();
  final TextEditingController _codigoController = TextEditingController();
  final TextEditingController _dataController = TextEditingController();
  final TextEditingController _descricaoController = TextEditingController();
  String? _fotoBase64;

  // Listas de opções para marca, modelo, setor e status
  final List<String> marcas = ['MOOB', 'MOOB Chicago', 'Atlanta Duoffice'];
  final List<String> modelos = ['Modelo X', 'Modelo Y', 'Modelo Z'];
  final List<String> setores = ['ADM', 'Radio e TV', 'TI', 'Modelagem'];
  final List<String> statusList = ['Usando', 'Emprestado', 'descartado'];

  // Valores selecionados
  String? _marcaSelecionada;
  String? _modeloSelecionado;
  String? _setorSelecionado;
  String? _statusSelecionado;

  Future<void> _enviarDados(BuildContext context) async {
    // Altere localhost para o IP do servidor, ex: "http://192.168.1.100/server/processa_bdCeet.php"
    const String url = "http://localhost/server/processa_bdCeet.php"; 

    // Verificando se todos os campos necessários estão preenchidos
    if (_marcaSelecionada == null || _modeloSelecionado == null || _corController.text.isEmpty || 
        _codigoController.text.isEmpty || _setorSelecionado == null || _statusSelecionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, preencha todos os campos obrigatórios!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final Map<String, String> data = {
      'acao': 'inserirDados',
      'marca': _marcaSelecionada ?? '',
      'modelo': _modeloSelecionado ?? '',
      'cor': _corController.text,
      'codigo': _codigoController.text,
      'data': _dataController.text,
      'foto': _fotoBase64 ?? '',
      'status': _statusSelecionado ?? '',
      'setor': _setorSelecionado ?? '',
      'descricao': _descricaoController.text,
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        body: json.encode(data),
        headers: {'Content-Type': 'application/json'}, // Adicionando o cabeçalho Content-Type
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        if (responseBody['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Inserção realizada com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
          setState(() {
            _marcaSelecionada = null;
            _modeloSelecionado = null;
            _corController.clear();
            _codigoController.clear();
            _dataController.clear();
            _fotoBase64 = null;
            _statusSelecionado = null;
            _setorSelecionado = null;
            _descricaoController.clear();
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Falha ao inserir: ${responseBody['message']}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        print("Erro na requisição. Código de resposta: ${response.statusCode}");
        print("Resposta do servidor: ${response.body}");
      }
    } catch (error) {
      print("Erro durante a requisição: $error");
    }
  }

  Future<void> _escolherFoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _fotoBase64 = base64Encode(bytes);
      });
    }
  }

  Future<void> _selecionarData(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      setState(() {
        _dataController.text = "${pickedDate.toLocal()}".split(' ')[0];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inserir Dados'),
        backgroundColor: Colors.blue,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1C3A5C), Color(0xFF004d40), Color(0xFF311B92)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                children: [
                  _buildDropdown('Marca', _marcaSelecionada, marcas, (newValue) {
                    setState(() => _marcaSelecionada = newValue);
                  }),
                  const SizedBox(height: 16),
                  _buildDropdown('Modelo', _modeloSelecionado, modelos, (newValue) {
                    setState(() => _modeloSelecionado = newValue);
                  }),
                  const SizedBox(height: 16),
                  _buildTextField('Cor', _corController),
                  const SizedBox(height: 16),
                  _buildTextField('Código', _codigoController),
                  const SizedBox(height: 16),
                  _buildTextField('Descrição', _descricaoController),
                  const SizedBox(height: 16),
                  _buildDropdown('Setor', _setorSelecionado, setores, (newValue) {
                    setState(() => _setorSelecionado = newValue);
                  }),
                  const SizedBox(height: 16),
                  _buildDropdown('Status', _statusSelecionado, statusList, (newValue) {
                    setState(() => _statusSelecionado = newValue);
                  }),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _dataController,
                    decoration: InputDecoration(
                      labelText: 'Data',
                      labelStyle: const TextStyle(color: Colors.white),
                      fillColor: Colors.white.withOpacity(0.1),
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.white),
                      ),
                    ),
                    readOnly: true,
                    onTap: () => _selecionarData(context),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _escolherFoto,
                    child: const Text('Escolher Foto'),
                  ),
                  if (_fotoBase64 != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Image.memory(
                        base64Decode(_fotoBase64!),
                        height: 100,
                      ),
                    ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _enviarDados(context),
                    child: const Text('Inserir'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, String? selectedValue, List<String> options, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      value: selectedValue,
      items: options.map((String option) {
        return DropdownMenuItem(
          value: option,
          child: Text(option, style: const TextStyle(color: Colors.black)),
        );
      }).toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white),
        fillColor: Colors.white.withOpacity(0.1),
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white),
        fillColor: Colors.white.withOpacity(0.1),
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.white),
        ),
      ),
    );
  }
}
