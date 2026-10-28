
class UpdateInfo {
  final PlatformInfo? android;
  final PlatformInfo? ios;

  UpdateInfo({this.android, this.ios});

  factory UpdateInfo.fromJson(Map<String, dynamic> json) {
    return UpdateInfo(
      android: json['android'] != null ? PlatformInfo.fromJson(json['android'] as Map<String, dynamic>) : null,
      ios: json['ios'] != null ? PlatformInfo.fromJson(json['ios'] as Map<String, dynamic>) : null,
    );
  }
}

class PlatformInfo {
  final String minVersion;
  final String latestVersion;
  final String? apkUrl;
  final Map<String, String?>? releaseNotes;

  PlatformInfo({
    required this.minVersion,
    required this.latestVersion,
    this.apkUrl,
    this.releaseNotes,
  });

  factory PlatformInfo.fromJson(Map<String, dynamic> json) {
    return PlatformInfo(
      minVersion: json['minVersion'] as String? ?? '',
      latestVersion: json['latestVersion'] as String? ?? '',
      apkUrl: json['apkUrl'] as String?,
      releaseNotes: json['releaseNotes'] != null
          ? Map<String, String?>.from(json['releaseNotes'] as Map)
          : null,
    );
  }
}