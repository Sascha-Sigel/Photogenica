class place {
  final int id;
  final String descr;
  final int? num_likes;
  final double lat;
  final double lng;
  final int? user_id;

  place({
    required this.id,
    required this.descr,
    required this.num_likes,
    required this.lat,
    required this.lng,
    required this.user_id,
  });

  factory place.fromJson(Map<String, dynamic> json) {
    return place(
      id: int.parse(json['PlaceId']),
      descr: json['PlaceDescr'],
      num_likes: int.parse(json['PlaceNumLikes']),
      lat: double.parse(json['PlaceLatitude']),
      lng: double.parse(json['PlaceLongitude']),
      user_id: int.parse(json['UserId']),
    );
  }
}
