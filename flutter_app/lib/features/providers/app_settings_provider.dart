import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/app_settings_model.dart';

final firestoreAppSettingsStreamProvider =
    StreamProvider<AppSettingsModel>((ref) {
  try {
    return FirebaseFirestore.instance
        .collection('app_settings')
        .doc('main')
        .snapshots()
        .map((doc) {
      if (doc.exists && doc.data() != null) {
        return AppSettingsModel.fromMap(doc.data()!);
      }
      return const AppSettingsModel();
    });
  } catch (_) {
    return Stream.value(const AppSettingsModel());
  }
});

final appSettingsProvider = Provider<AppSettingsModel>((ref) {
  final streamVal = ref.watch(firestoreAppSettingsStreamProvider);
  return streamVal.maybeWhen(
    data: (settings) => settings,
    orElse: () => const AppSettingsModel(),
  );
});
