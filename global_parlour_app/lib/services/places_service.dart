// ignore_for_file: depend_on_referenced_packages

import 'dart:convert';
import 'package:http/http.dart' as http;

class PlacesService {
  static const String apiKey = 'AIzaSyD05nk8icrnwPG0Xc4FMUabmJoySdjfalA';

  static Future<List<dynamic>> searchParlours(String city) async {
    final url =
        'https://maps.googleapis.com/maps/api/place/textsearch/json'
        '?query=beauty+salon+in+$city'
        '&key=$apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['results'];
    } else {
      throw Exception('Failed to fetch parlours');
    }
  }
}