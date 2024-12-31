import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/radio_station.dart';

class ApiService {
  final String baseUrl = 'http://192.168.1.73:8000/api/stations/';

  Future<List<RadioStation>> fetchStations() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => RadioStation.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load stations');
    }
  }

  Future<void> updateFavoriteStatus(int stationId, bool isFavorite) async {
    final url = Uri.parse('${baseUrl}update_favorite/');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'id': stationId,
        'is_favorite': isFavorite,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Error updating favorite status');
    }
  }

  Future<void> addStation({
    required String title,
    required String state,
    required String city,
    required String callSign,
    required String slogan,
    required String streamingUrl,
    required String imagePath,
  }) async {
    final uri = Uri.parse(baseUrl);

    final request = http.MultipartRequest('POST', uri)
      ..fields['title'] = title
      ..fields['state'] = state
      ..fields['city'] = city
      ..fields['call_sign'] = callSign
      ..fields['slogan'] = slogan
      ..fields['streaming_url'] = streamingUrl
      ..files.add(
        await http.MultipartFile.fromPath('image', imagePath),
      );

    final response = await request.send();

    if (response.statusCode != 201) {
      throw Exception('Error al agregar la estación');
    }
  }

}
