// This class is for the request data you send to the API
class MatchApiRequest {
  final List<String>? tags;

  MatchApiRequest({this.tags});

  // Converts values to key-value pairs as expected by the API
  Map<String, String> toFormData() {
    return {'tags': tags.toString()};
  }
}

// This class is for the response data you receive from the API
class MatchResponse {
  final List<String> imageUrls;
  final List<String> descriptions;

  MatchResponse({required this.imageUrls, required this.descriptions});

  // Converts JSON response to Dart object
  factory MatchResponse.fromJson(Map<String, dynamic> json) {
    List<String> imageUrls = [];
    List<String> descriptions = [];

    // Check if 'images' key exists and is a list
    for (var data in json['images']) {
      imageUrls.add(
        data['image']['compressed']['url'] as String? ??
            'https://www.shutterstock.com/image-vector/default-avatar-anime-girl-profile-600w-661573342.jpg',
      );
      descriptions.add(
        data['attribution']['copyright'] as String? ??
            'No description available',
      );
    }

    // Return a new instance of MatchResponse
    return MatchResponse(imageUrls: imageUrls, descriptions: descriptions);
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
