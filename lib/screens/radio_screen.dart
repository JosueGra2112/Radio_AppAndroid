import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/radio_station.dart';
import '../services/api_service.dart';

class RadioScreen extends StatefulWidget {
  final RadioStation station;

  RadioScreen({required this.station});

  @override
  _RadioScreenState createState() => _RadioScreenState();
}

class _RadioScreenState extends State<RadioScreen> {
  late AudioPlayer _audioPlayer;
  late bool _isFavorite; // Inicializa el estado favorito
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _isFavorite = widget.station.isFavorite; // Sincroniza el estado inicial con la estación
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _toggleFavorite() async {
    setState(() {
      _isFavorite = !_isFavorite; // Cambia el estado local inmediatamente
    });

    try {
      await _apiService.updateFavoriteStatus(widget.station.id, _isFavorite);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isFavorite ? 'Añadido a favoritos' : 'Eliminado de favoritos',
          ),
        ),
      );
    } catch (e) {
      setState(() {
        _isFavorite = !_isFavorite; // Revertir estado si ocurre un error
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar favorito: $e')),
      );
    }
  }

  Future<void> _toggleAudio() async {
    try {
      if (_audioPlayer.state == PlayerState.playing) {
        await _audioPlayer.pause();
      } else {
        await _audioPlayer.play(UrlSource(widget.station.streamingUrl));
      }
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al reproducir audio: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(
          context,
          RadioStation(
            id: widget.station.id,
            title: widget.station.title,
            state: widget.station.state,
            city: widget.station.city,
            callSign: widget.station.callSign,
            slogan: widget.station.slogan,
            streamingUrl: widget.station.streamingUrl,
            image: widget.station.image,
            isFavorite: _isFavorite,
          ),
        );
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.station.title),
          centerTitle: true,
          backgroundColor: Colors.white,
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF2C3E50), // Azul oscuro
                Color(0xFF4CA1AF), // Azul claro
              ],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20), // Bordes redondeados
                  child: Image.network(
                    widget.station.image,
                    height: 200,
                    width: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(Icons.image, size: 200, color: Colors.white);
                    },
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  widget.station.title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  widget.station.slogan,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(
                        _isFavorite ? Icons.favorite : Icons.favorite_border,
                        size: 40,
                        color: _isFavorite ? Colors.red : Colors.white,
                      ),
                      onPressed: _toggleFavorite,
                    ),
                    const SizedBox(width: 20),
                    IconButton(
                      icon: Icon(
                        _audioPlayer.state == PlayerState.playing
                            ? Icons.pause_circle
                            : Icons.play_circle,
                        size: 64,
                        color: Colors.white,
                      ),
                      onPressed: _toggleAudio,
                    ),
                    const SizedBox(width: 20),
                    IconButton(
                      icon: const Icon(
                        Icons.share,
                        size: 40,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Funcionalidad en desarrollo')),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
