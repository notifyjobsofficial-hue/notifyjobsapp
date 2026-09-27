import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/storage_service.dart';
import 'storage_provider.dart';

class UserPreferences {
  final List<String> targetExams;
  final String qualification;
  final String locationPreference; // 'Andaman & Nicobar', 'All India', 'Both'
  final bool hasCompletedOnboarding;

  const UserPreferences({
    this.targetExams = const ['All Govt Jobs'],
    this.qualification = 'Graduate',
    this.locationPreference = 'Both',
    this.hasCompletedOnboarding = false,
  });

  UserPreferences copyWith({
    List<String>? targetExams,
    String? qualification,
    String? locationPreference,
    bool? hasCompletedOnboarding,
  }) {
    return UserPreferences(
      targetExams: targetExams ?? this.targetExams,
      qualification: qualification ?? this.qualification,
      locationPreference: locationPreference ?? this.locationPreference,
      hasCompletedOnboarding:
          hasCompletedOnboarding ?? this.hasCompletedOnboarding,
    );
  }
}

class UserPreferencesNotifier extends StateNotifier<UserPreferences> {
  final StorageService _storage;

  UserPreferencesNotifier(this._storage)
      : super(UserPreferences(
          targetExams: _storage.getTargetExams(),
          qualification: _storage.getQualification(),
          locationPreference: _storage.getLocationPreference(),
          hasCompletedOnboarding: _storage.hasCompletedOnboarding(),
        ));

  Future<void> updatePreferences({
    List<String>? targetExams,
    String? qualification,
    String? locationPreference,
  }) async {
    final newExams = targetExams ?? state.targetExams;
    final newQual = qualification ?? state.qualification;
    final newLoc = locationPreference ?? state.locationPreference;

    await _storage.setTargetExams(newExams);
    await _storage.setQualification(newQual);
    await _storage.setLocationPreference(newLoc);

    state = state.copyWith(
      targetExams: newExams,
      qualification: newQual,
      locationPreference: newLoc,
    );
  }

  Future<void> completeOnboarding({
    required List<String> targetExams,
    required String qualification,
    required String locationPreference,
  }) async {
    await _storage.setTargetExams(targetExams);
    await _storage.setQualification(qualification);
    await _storage.setLocationPreference(locationPreference);
    await _storage.setCompletedOnboarding(true);

    state = UserPreferences(
      targetExams: targetExams,
      qualification: qualification,
      locationPreference: locationPreference,
      hasCompletedOnboarding: true,
    );
  }

  Future<void> skipOnboarding() async {
    await _storage.setCompletedOnboarding(true);
    state = state.copyWith(hasCompletedOnboarding: true);
  }
}

final userPreferencesProvider =
    StateNotifierProvider<UserPreferencesNotifier, UserPreferences>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return UserPreferencesNotifier(storage);
});
