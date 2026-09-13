import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/storage_service.dart';
import '../models/content_model.dart';
import 'storage_provider.dart';

class SavedJobsNotifier extends StateNotifier<List<ContentModel>> {
  final StorageService _storage;

  SavedJobsNotifier(this._storage) : super([]) {
    _loadSavedJobs();
  }

  void _loadSavedJobs() {
    final rawList = _storage.getSavedJobs();
    state = rawList
        .map((map) => ContentModel.fromMap(map, map['id']?.toString() ?? ''))
        .toList();
  }

  bool isSaved(String id) {
    return state.any((item) => item.id == id);
  }

  Future<bool> toggleSave(ContentModel job) async {
    final currentlySaved = isSaved(job.id);
    if (currentlySaved) {
      await _storage.removeSavedJob(job.id);
      state = state.where((item) => item.id != job.id).toList();
      return false; // Removed
    } else {
      await _storage.saveJob(job.toMap());
      state = [job, ...state];
      return true; // Saved
    }
  }

  Future<bool> toggleSaved(ContentModel job) => toggleSave(job);
}

final savedJobsProvider =
    StateNotifierProvider<SavedJobsNotifier, List<ContentModel>>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return SavedJobsNotifier(storage);
});

final isSavedProvider = Provider.family<bool, String>((ref, id) {
  final savedList = ref.watch(savedJobsProvider);
  return savedList.any((item) => item.id == id);
});
