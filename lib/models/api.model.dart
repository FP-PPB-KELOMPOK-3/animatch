// This class is for the response data you receive from the API
class MatchResponse {
  final List<String> imageUrls;
  final List<String> descriptions;
  final List<List<String>> tags;

  MatchResponse({
    required this.imageUrls,
    required this.descriptions,
    required this.tags,
  });

  // Converts JSON response to Dart object
  factory MatchResponse.fromJson(Map<String, dynamic> json) {
    List<String> imageUrls = [];
    List<String> descriptions = [];
    List<List<String>> tags = [];

    // Loop as many times as the 'count' key in the JSON
    for (var i = 0; i < json['count']; i++) {
      // Check if 'images' key exists and is a list
      if (json['images'] == null || json['images'].isEmpty) {
        break; // Exit loop if no images are available
      }

      if (i >= json['images'].length) {
        break; // Exit loop if index exceeds available images
      }
      // Use null-aware operator to handle missing keys
      imageUrls.add(
        json['images'][i]['image']['compressed']['url'] as String? ??
            'https://www.shutterstock.com/image-vector/default-avatar-anime-girl-profile-600w-661573342.jpg',
      );

      descriptions.add(
        // Use null-aware operator to handle missing keys
        json['images'][i]['attribution']['copyright'] as String? ??
            'No description available',
      );

      tags.add(json['images'][i]['tags'] as List<String>? ?? []);
    }

    // Return a new instance of MatchResponse
    return MatchResponse(
      imageUrls: imageUrls,
      descriptions: descriptions,
      tags: tags,
    );
  }
}

class TagResponse {
  final List<String> tags;

  TagResponse({required this.tags});

  // Converts JSON response to Dart object
  factory TagResponse.fromJson(Map<String, dynamic> json) {
    List<String> tags = [];

    // Check if 'tags' key exists and is a list
    for (var tag in json['tags']) {
      tags.add(tag as String);
    }

    // Return a new instance of TagResponse
    return TagResponse(tags: tags);
  }
}
