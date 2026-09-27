import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/job_type_model.dart';

/// Real-time stream of job types from Firestore collection 'job_types'.
/// Reads active job types ordered by their display priority.
final firestoreJobTypesStreamProvider =
    StreamProvider<List<JobTypeModel>>((ref) {
  try {
    return FirebaseFirestore.instance
        .collection('job_types')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      final list = <JobTypeModel>[];
      for (final doc in snapshot.docs) {
        final data = doc.data();
        data['id'] = doc.id;
        try {
          final model = JobTypeModel.fromMap(data, doc.id);
          if (model.isActive) {
            list.add(model);
          }
        } catch (_) {}
      }
      list.sort((a, b) => a.order.compareTo(b.order));
      return list.isNotEmpty ? list : JobTypeModel.defaultJobTypes;
    });
  } catch (_) {
    return Stream.value(JobTypeModel.defaultJobTypes);
  }
});

/// Master Job Types Provider:
/// Watches the real-time Firestore stream; falls back to defaultJobTypes if loading or offline.
final jobTypesProvider = Provider<List<JobTypeModel>>((ref) {
  final streamVal = ref.watch(firestoreJobTypesStreamProvider);
  return streamVal.maybeWhen(
    data: (items) => items.isNotEmpty ? items : JobTypeModel.defaultJobTypes,
    orElse: () => JobTypeModel.defaultJobTypes,
  );
});
