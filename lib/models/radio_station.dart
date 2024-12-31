class RadioStation {
  final int id;
  final String title;
  final String state;
  final String city;
  final String callSign;
  final String slogan;
  final String streamingUrl;
  final String image;
  final bool isFavorite;

  RadioStation({
    required this.id,
    required this.title,
    required this.state,
    required this.city,
    required this.callSign,
    required this.slogan,
    required this.streamingUrl,
    required this.image,
    required this.isFavorite,
  });

  factory RadioStation.fromJson(Map<String, dynamic> json) {
    return RadioStation(
      id: json['id'],
      title: json['title'],
      state: json['state'],
      city: json['city'],
      callSign: json['call_sign'],
      slogan: json['slogan'],
      streamingUrl: json['streaming_url'],
      image: json['image'],
      isFavorite: json['is_favorite'],
    );
  }
}
