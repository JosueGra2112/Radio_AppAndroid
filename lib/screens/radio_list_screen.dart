import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/radio_station.dart';
import 'radio_screen.dart';
import 'add_station_screen.dart'; // Importa la pantalla de agregar estación

class RadioListScreen extends StatefulWidget {
  @override
  _RadioListScreenState createState() => _RadioListScreenState();
}

class _RadioListScreenState extends State<RadioListScreen> {
  List<RadioStation> _stations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStations();
  }

  Future<void> _fetchStations() async {
    try {
      final stations = await ApiService().fetchStations();
      setState(() {
        _stations = stations;
        _isLoading = false;
      });
    } catch (e) {
      print('Error al cargar estaciones: $e');
    }
  }

  void _updateStation(RadioStation updatedStation) {
    setState(() {
      final index = _stations.indexWhere((station) => station.id == updatedStation.id);
      if (index != -1) {
        _stations[index] = updatedStation;
      }
    });
  }

  void _addStation() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddStationScreen(), // Navega a la pantalla de agregar estación
      ),
    );

    if (result == true) {
      // Si la pantalla de agregar estación devuelve `true`, actualiza la lista
      _fetchStations();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Estaciones de radio'),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _fetchStations,
        child: ListView.builder(
          padding: const EdgeInsets.all(10.0),
          itemCount: _stations.length,
          itemBuilder: (context, index) {
            final station = _stations[index];
            return GestureDetector(
              onTap: () async {
                final updatedStation = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RadioScreen(station: station),
                  ),
                );

                if (updatedStation != null) {
                  _updateStation(updatedStation);
                }
              },
              child: Card(
                elevation: 5,
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Container(
                  padding: const EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF2C3E50), // Azul oscuro
                        Color(0xFF4CA1AF), // Azul claro
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          station.image,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(Icons.image, size: 80, color: Colors.grey);
                          },
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              station.title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              station.slogan,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        station.isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: station.isFavorite ? Colors.red : Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addStation,
        backgroundColor: const Color(0xFF4CA1AF),
        child: const Icon(Icons.add),
      ),
    );
  }
}
