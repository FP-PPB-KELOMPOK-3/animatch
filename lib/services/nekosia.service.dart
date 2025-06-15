import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/api.model.dart';

class NekosiaService {
  static final String baseUrl = 'https://api.nekosia.cat/api/v1';

  static Future<TagResponse?> getTags() async {
    try {
      var response = await http.get(Uri.parse('$baseUrl/tags'));

      if (response.statusCode == 200) {
        // Decode the JSON and convert it to Dart object
        final data = json.decode(response.body);

        return TagResponse.fromJson(data);
      }
    } catch (e) {
      print("Error: $e");
    }
    return null;
  }

  static Future<MatchResponse?> getRandomAnimeImages(
    List<String> blacklists,
  ) async {
    try {
      var response = await http.get(
        Uri.parse(
          '$baseUrl/images/random?count=5&blacklistedTags=${blacklists.join(',')}&rating=safe',
        ),
      );

      if (response.statusCode == 200) {
        // Decode the JSON and convert it to Dart object
        final data = json.decode(response.body);

        return MatchResponse.fromJson(data);
      }
    } catch (e) {
      print("Error: $e");
    }
    return null;
  }

  static Future<MatchResponse?> getAnimeImagesByTags(
    List<String> tags,
    List<String> blacklists,
  ) async {
    try {
      var response = await http.get(
        Uri.parse(
          '$baseUrl/images/nothing?count=5&additionalTags=${tags.join(',')}&blacklistedTags=${blacklists.join(',')}&rating=safe',
        ),
      );

      if (response.statusCode == 200) {
        // Decode the JSON and convert it to Dart object
        final data = json.decode(response.body);

        return MatchResponse.fromJson(data);
      }
    } catch (e) {
      print("Error: $e");
    }
    return null;
  }
}
