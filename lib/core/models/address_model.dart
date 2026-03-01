class AddressModel {
  final String displayName;
  final double lat;
  final double lon;
  final String? street;
  final String? city;
  final String? country;

  const AddressModel({
    required this.displayName,
    required this.lat,
    required this.lon,
    this.street,
    this.city,
    this.country,
  });

  factory AddressModel.fromNominatim(Map<String, dynamic> json) {
    final address = json['address'] as Map<String, dynamic>? ?? {};
    return AddressModel(
      displayName: json['display_name'] ?? '',
      lat: double.tryParse(json['lat']?.toString() ?? '0') ?? 0,
      lon: double.tryParse(json['lon']?.toString() ?? '0') ?? 0,
      street: address['road'] ?? address['street'],
      city: address['city'] ?? address['town'] ?? address['village'],
      country: address['country'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'displayName': displayName,
      'lat': lat,
      'lon': lon,
      'street': street,
      'city': city,
      'country': country,
    };
  }

  factory AddressModel.fromMap(Map<String, dynamic> map) {
    return AddressModel(
      displayName: map['displayName'] ?? '',
      lat: (map['lat'] ?? 0).toDouble(),
      lon: (map['lon'] ?? 0).toDouble(),
      street: map['street'],
      city: map['city'],
      country: map['country'],
    );
  }

  String get shortName {
    if (street != null && city != null) return '$street, $city';
    if (city != null) return city!;
    // Return first 2 parts of display name
    final parts = displayName.split(', ');
    if (parts.length >= 2) return '${parts[0]}, ${parts[1]}';
    return displayName;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AddressModel && other.lat == lat && other.lon == lon;
  }

  @override
  int get hashCode => lat.hashCode ^ lon.hashCode;
}
