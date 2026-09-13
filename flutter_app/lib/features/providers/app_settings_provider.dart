import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_settings_model.dart';

final appSettingsProvider = Provider<AppSettingsModel>((ref) {
  // Returns cached default settings; in production can be seeded from Firebase or remote config
  return const AppSettingsModel();
});
