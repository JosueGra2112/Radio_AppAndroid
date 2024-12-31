import 'dart:io'; // Para manejar archivos
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';

class AddStationScreen extends StatefulWidget {
  @override
  _AddStationScreenState createState() => _AddStationScreenState();
}

class _AddStationScreenState extends State<AddStationScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();
  File? _selectedImage;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _callSignController = TextEditingController();
  final TextEditingController _sloganController = TextEditingController();
  final TextEditingController _streamingUrlController = TextEditingController();

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedImage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor selecciona una imagen')),
        );
        return;
      }

      try {
        await _apiService.addStation(
          title: _titleController.text,
          state: _stateController.text,
          city: _cityController.text,
          callSign: _callSignController.text,
          slogan: _sloganController.text,
          streamingUrl: _streamingUrlController.text,
          imagePath: _selectedImage!.path,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Estación agregada exitosamente')),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al agregar estación: $e')),
        );
      }
    }
  }

  bool _isValidUrl(String url) {
    final uri = Uri.tryParse(url);
    return uri != null && (uri.isAbsolute && (uri.hasScheme && uri.hasAuthority));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Estación'),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Registrar nueva estación',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2C3E50),
                  ),
                ),
                const SizedBox(height: 20),
                _buildTextField(_titleController, 'Título', 'Por favor ingresa un título'),
                const SizedBox(height: 15),
                _buildTextField(_stateController, 'Estado', 'Por favor ingresa un estado'),
                const SizedBox(height: 15),
                _buildTextField(_cityController, 'Ciudad', 'Por favor ingresa una ciudad'),
                const SizedBox(height: 15),
                _buildTextField(_callSignController, 'Siglas', 'Por favor ingresa unas siglas'),
                const SizedBox(height: 15),
                _buildTextField(_sloganController, 'Eslogan', 'Por favor ingresa un eslogan'),
                const SizedBox(height: 15),
                _buildTextField(
                  _streamingUrlController,
                  'URL de streaming',
                  'Por favor ingresa una URL válida',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa una URL de streaming';
                    }
                    if (!_isValidUrl(value)) {
                      return 'Por favor ingresa una URL válida';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                Center(
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          height: 150,
                          width: 150,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: Colors.grey[300],
                          ),
                          child: _selectedImage != null
                              ? ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Image.file(
                              _selectedImage!,
                              fit: BoxFit.cover,
                            ),
                          )
                              : const Icon(Icons.image, size: 50, color: Colors.grey),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Seleccionar Imagen',
                        style: TextStyle(fontSize: 16, color: Color(0xFF2C3E50)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CA1AF), // Azul claro
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: _submitForm,
                    child: const Text(
                      'Registrar Estación',
                      style: TextStyle(fontSize: 18, color: Colors.white), // Texto blanco
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller,
      String label,
      String errorMessage, {
        String? Function(String?)? validator,
      }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Color(0xFF2C3E50)),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      validator: validator ??
              (value) {
            if (value == null || value.isEmpty) {
              return errorMessage;
            }
            return null;
          },
    );
  }
}
