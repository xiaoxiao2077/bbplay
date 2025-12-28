class Upgrade {
  String? version;
  String? url;
  String? size;
  String? releaseDate;
  String? description;
  bool needUpgrade = false;

  Upgrade.fromJson(Map<String, dynamic> json) {
    version = json['version'];
    url = json['url'];
    size = json['size'];
    releaseDate = json['releaseDate'];
    description = json['description'];
  }
}
