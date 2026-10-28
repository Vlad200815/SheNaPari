import 'package:enum_to_string/enum_to_string.dart';

import 'config.dart';

enum Flavor { stage, production }

class Constants {
  const Constants({required this.endpoint, required this.apiKey});

  factory Constants.shared() {
    if (_instance != null) {
      return _instance!;
    }

    final flavor = EnumToString.fromString(
      Flavor.values,
      const String.fromEnvironment('FLAVOR'),
    );
    switch (flavor) {
      case Flavor.production:
        return Constants._prod();

      case Flavor.stage:
        return Constants._stag();

      default:
        return Constants._prod();
    }
  }

  factory Constants._prod() {
    return const Constants(endpoint: Config.URL, apiKey: '');
  }

  factory Constants._stag() {
    return const Constants(endpoint: Config.URL_STAGE, apiKey: '');
  }

  final String endpoint;
  final String apiKey;

  static Constants? _instance;
}
