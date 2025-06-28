class SoundModel {
  late String id;
  late String name;
  late String url;
  String? image;
  num duration = 0; //UI

  SoundModel(
      {required this.id, required this.name, required this.url, this.image});

  SoundModel.localSound({required this.name, required this.url});

  SoundModel.toMap({required this.name, required this.url}); // for dummy data
  factory SoundModel.fromJson(Map<String, dynamic> json, {required String id}) {
    return SoundModel(
      id: id,
      name: json['name'],
      url: json['url'],
      image: json['image'],
    );
  }
}
