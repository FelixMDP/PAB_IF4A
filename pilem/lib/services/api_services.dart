import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String apiKey = '7d8e18a52e73f8a58f367e9731c85e99';
  static const String baseUrl = 'https://api.themoviedb.org/3';

  /// Mengambil semua film dari daftar populer dan tren
  Future<List<Map<String, dynamic>>> getAllMovies() async {
    final response =
        await http.get(Uri.parse('$baseUrl/movie/now_playing?api_key=$apiKey'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data['results']);
    } else {
      throw Exception('Failed to load movies: ${response.statusCode}');
    }
  }

  /// Mendapatkan daftar film populer dari TMDb
  Future<List<Map<String, dynamic>>> getPopularMovies() async {
    final response =
        await http.get(Uri.parse('$baseUrl/movie/popular?api_key=$apiKey'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data['results']);
    } else {
      throw Exception('Failed to load popular movies: ${response.statusCode}');
    }
  }

  /// Mendapatkan daftar film yang sedang tren dari TMDb
  Future<List<Map<String, dynamic>>> getTrendingMovies() async {
    final response = await http
        .get(Uri.parse('$baseUrl/trending/movie/week?api_key=$apiKey'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data['results']);
    } else {
      throw Exception('Failed to load trending movies: ${response.statusCode}');
    }
  }

  Future<List<Map<String, dynamic>>> searchMovies(String query) async {
    final response = await http
        .get(Uri.parse('$baseUrl/search/movie?query=$query&api_key=$apiKey'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data['results']);
    } else {
      throw Exception('Failed to load search movies: ${response.statusCode}');
    }
  }
}
