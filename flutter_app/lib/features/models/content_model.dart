import 'package:intl/intl.dart';
import '../../core/utils/normalization_utils.dart';
import '../../core/utils/status_engine.dart';

/// Structured sub-item for Important Dates
class ImportantDateModel {
  final String id;
  final String label;
  final String date;
  final bool isTentative;

  const ImportantDateModel({
    required this.id,
    required this.label,
    required this.date,
    this.isTentative = false,
  });

  factory ImportantDateModel.fromMap(Map<String, dynamic> map) {
    return ImportantDateModel(
      id: map['id']?.toString() ?? '',
      label: map['label']?.toString() ?? '',
      date: map['date']?.toString() ?? '',
      isTentative: map['isTentative'] == true,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'label': label,
        'date': date,
        'isTentative': isTentative,
      };
}

/// Structured sub-item for Vacancies Breakdown
class VacancyItemModel {
  final String id;
  final String postName;
  final String category;
  final String count;
  final String? payLevel;

  const VacancyItemModel({
    required this.id,
    required this.postName,
    required this.category,
    required this.count,
    this.payLevel,
  });

  factory VacancyItemModel.fromMap(Map<String, dynamic> map) {
    return VacancyItemModel(
      id: map['id']?.toString() ?? '',
      postName: map['postName']?.toString() ?? '',
      category: map['category']?.toString() ?? '',
      count: map['count']?.toString() ?? '',
      payLevel: map['payLevel']?.toString(),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'postName': postName,
        'category': category,
        'count': count,
        if (payLevel != null) 'payLevel': payLevel,
      };
}

/// Structured category-wise vacancy breakup (UR, OBC, EWS, SC, ST, PwBD, ESM, MSP, Other)
class VacancyBreakupModel {
  final int ur;
  final int obc;
  final int ews;
  final int sc;
  final int st;
  final int pwbd;
  final int esm;
  final int msp;
  final int other;
  final int total;

  const VacancyBreakupModel({
    this.ur = 0,
    this.obc = 0,
    this.ews = 0,
    this.sc = 0,
    this.st = 0,
    this.pwbd = 0,
    this.esm = 0,
    this.msp = 0,
    this.other = 0,
    this.total = 0,
  });

  factory VacancyBreakupModel.fromMap(Map<String, dynamic> map) {
    int toInt(dynamic val) {
      if (val == null) return 0;
      if (val is num) return val.toInt();
      return int.tryParse(val.toString().replaceAll(RegExp(r'[^0-9]'), '')) ??
          0;
    }

    final u = toInt(map['ur']);
    final o = toInt(map['obc']);
    final e = toInt(map['ews']);
    final s = toInt(map['sc']);
    final st = toInt(map['st']);
    final p = toInt(map['pwbd']);
    final es = toInt(map['esm']);
    final ms = toInt(map['msp']);
    final ot = toInt(map['other']);
    final parsedTotal = toInt(map['total']);
    final computedTotal = (u + o + e + s + st + p + es + ms + ot > 0)
        ? (u + o + e + s + st + p + es + ms + ot)
        : parsedTotal;

    return VacancyBreakupModel(
      ur: u,
      obc: o,
      ews: e,
      sc: s,
      st: st,
      pwbd: p,
      esm: es,
      msp: ms,
      other: ot,
      total: computedTotal,
    );
  }

  Map<String, dynamic> toMap() => {
        'ur': ur,
        'obc': obc,
        'ews': ews,
        'sc': sc,
        'st': st,
        'pwbd': pwbd,
        'esm': esm,
        'msp': msp,
        'other': other,
        'total': total,
      };

  /// Non-zero category breakdown dictionary
  Map<String, int> get nonZeroBreakdown {
    final map = <String, int>{};
    if (ur > 0) map['UR'] = ur;
    if (obc > 0) map['OBC'] = obc;
    if (ews > 0) map['EWS'] = ews;
    if (sc > 0) map['SC'] = sc;
    if (st > 0) map['ST'] = st;
    if (pwbd > 0) map['PwBD'] = pwbd;
    if (esm > 0) map['ESM'] = esm;
    if (msp > 0) map['MSP'] = msp;
    if (other > 0) map['Other'] = other;
    return map;
  }
}

/// Structured individual post / designation in recruitment
class PostItemModel {
  final String id;
  final String postName;
  final String? postCode;
  final String? group;
  final String? cadre;
  final String? department;
  final String? categoryId;
  final String? categoryName;
  final String? qualification;
  final String? qualificationDetails;
  final String? desirableQualification;
  final String? location;
  final String? jobType;
  final String? payLevel;
  final String? payScale;
  final String? salaryMin;
  final String? salaryMax;
  final String? salaryText;
  final String? ageMin;
  final String? ageMax;
  final String? maleMaxAge;
  final String? femaleMaxAge;
  final String? ageAsOn;
  final String? ageRelaxation;
  final VacancyBreakupModel vacancies;

  const PostItemModel({
    required this.id,
    required this.postName,
    this.postCode,
    this.group,
    this.cadre,
    this.department,
    this.categoryId,
    this.categoryName,
    this.qualification,
    this.qualificationDetails,
    this.desirableQualification,
    this.location,
    this.jobType,
    this.payLevel,
    this.payScale,
    this.salaryMin,
    this.salaryMax,
    this.salaryText,
    this.ageMin,
    this.ageMax,
    this.maleMaxAge,
    this.femaleMaxAge,
    this.ageAsOn,
    this.ageRelaxation,
    this.vacancies = const VacancyBreakupModel(),
  });

  factory PostItemModel.fromMap(Map<String, dynamic> map) {
    return PostItemModel(
      id: map['id']?.toString() ?? '',
      postName: map['postName']?.toString() ?? '',
      postCode: map['postCode']?.toString(),
      group: map['group']?.toString(),
      cadre: map['cadre']?.toString(),
      department: map['department']?.toString(),
      categoryId: map['categoryId']?.toString(),
      categoryName: map['categoryName']?.toString(),
      qualification: map['qualification']?.toString(),
      qualificationDetails: map['qualificationDetails']?.toString(),
      desirableQualification: map['desirableQualification']?.toString(),
      location: map['location']?.toString(),
      jobType: map['jobType']?.toString(),
      payLevel: map['payLevel']?.toString(),
      payScale: map['payScale']?.toString(),
      salaryMin: map['salaryMin']?.toString(),
      salaryMax: map['salaryMax']?.toString(),
      salaryText: map['salaryText']?.toString(),
      ageMin: map['ageMin']?.toString(),
      ageMax: map['ageMax']?.toString(),
      maleMaxAge: map['maleMaxAge']?.toString(),
      femaleMaxAge: map['femaleMaxAge']?.toString(),
      ageAsOn: map['ageAsOn']?.toString(),
      ageRelaxation: map['ageRelaxation']?.toString(),
      vacancies: map['vacancies'] is Map
          ? VacancyBreakupModel.fromMap(
              Map<String, dynamic>.from(map['vacancies']))
          : const VacancyBreakupModel(),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'postName': postName,
        if (postCode != null) 'postCode': postCode,
        if (group != null) 'group': group,
        if (cadre != null) 'cadre': cadre,
        if (department != null) 'department': department,
        if (categoryId != null) 'categoryId': categoryId,
        if (categoryName != null) 'categoryName': categoryName,
        if (qualification != null) 'qualification': qualification,
        if (qualificationDetails != null)
          'qualificationDetails': qualificationDetails,
        if (desirableQualification != null)
          'desirableQualification': desirableQualification,
        if (location != null) 'location': location,
        if (jobType != null) 'jobType': jobType,
        if (payLevel != null) 'payLevel': payLevel,
        if (payScale != null) 'payScale': payScale,
        if (salaryMin != null) 'salaryMin': salaryMin,
        if (salaryMax != null) 'salaryMax': salaryMax,
        if (salaryText != null) 'salaryText': salaryText,
        if (ageMin != null) 'ageMin': ageMin,
        if (ageMax != null) 'ageMax': ageMax,
        if (maleMaxAge != null) 'maleMaxAge': maleMaxAge,
        if (femaleMaxAge != null) 'femaleMaxAge': femaleMaxAge,
        if (ageAsOn != null) 'ageAsOn': ageAsOn,
        if (ageRelaxation != null) 'ageRelaxation': ageRelaxation,
        'vacancies': vacancies.toMap(),
      };
}

/// Structured sub-item for Age Limits
class AgeLimitModel {
  final String id;
  final String category;
  final String relaxationYears;
  final String? maxAge;
  final String? _minAge;
  final String? ageAsOn;
  final String? notes;
  final String? maximumAgeOverride;

  const AgeLimitModel({
    this.id = '',
    this.category = '',
    this.relaxationYears = '',
    this.maxAge,
    String? minAge,
    this.ageAsOn,
    this.notes,
    this.maximumAgeOverride,
  }) : _minAge = minAge;

  String get minAge =>
      (_minAge != null && _minAge!.isNotEmpty) ? _minAge! : '18';
  String get displayAge => NormalizationUtils.formatAgeRange(minAge, maxAge);
  String get displayRelaxation =>
      NormalizationUtils.formatYears(relaxationYears);

  factory AgeLimitModel.fromMap(Map<String, dynamic> map) {
    return AgeLimitModel(
      id: map['id']?.toString() ?? '',
      category: map['category']?.toString() ?? '',
      relaxationYears: map['relaxationYears']?.toString() ?? '',
      maxAge: map['maxAge']?.toString(),
      minAge: map['minAge']?.toString(),
      ageAsOn: map['ageAsOn']?.toString() ?? map['asOnDate']?.toString(),
      notes: map['notes']?.toString(),
      maximumAgeOverride: map['maximumAgeOverride']?.toString(),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'category': category,
        'relaxationYears': relaxationYears,
        if (maxAge != null) 'maxAge': maxAge,
        if (_minAge != null) 'minAge': _minAge,
        if (ageAsOn != null) 'ageAsOn': ageAsOn,
        if (notes != null) 'notes': notes,
        if (maximumAgeOverride != null)
          'maximumAgeOverride': maximumAgeOverride,
      };
}

/// Structured sub-item for Application Fees
class ApplicationFeeModel {
  final String id;
  final String category;
  final String fee;
  final String? paymentMode;

  const ApplicationFeeModel({
    this.id = '',
    this.category = '',
    this.fee = '',
    this.paymentMode,
  });

  int get amount => int.tryParse(fee.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

  factory ApplicationFeeModel.fromMap(Map<String, dynamic> map) {
    return ApplicationFeeModel(
      id: map['id']?.toString() ?? '',
      category: map['category']?.toString() ?? '',
      fee: map['fee']?.toString() ?? '',
      paymentMode: map['paymentMode']?.toString(),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'category': category,
        'fee': fee,
        if (paymentMode != null) 'paymentMode': paymentMode,
      };
}

/// Structured sub-item for Selection Process
class SelectionStepModel {
  final String id;
  final int stageNumber;
  final String name;
  final String description;

  const SelectionStepModel({
    this.id = '',
    this.stageNumber = 1,
    this.name = '',
    this.description = '',
  });

  factory SelectionStepModel.fromMap(Map<String, dynamic> map) {
    return SelectionStepModel(
      id: map['id']?.toString() ?? '',
      stageNumber: int.tryParse(map['stageNumber']?.toString() ?? '1') ?? 1,
      name: map['name']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'stageNumber': stageNumber,
        'name': name,
        'description': description,
      };
}

/// Structured sub-item for Exam Pattern
class ExamPatternModel {
  final String id;
  final String? paperName;
  final String subject;
  final String questions;
  final String marks;
  final String? duration;
  final String? negativeMarking;
  final String? minimumQualifyingMarks;
  final String? notes;

  const ExamPatternModel({
    required this.id,
    this.paperName,
    required this.subject,
    required this.questions,
    required this.marks,
    this.duration,
    this.negativeMarking,
    this.minimumQualifyingMarks,
    this.notes,
  });

  factory ExamPatternModel.fromMap(Map<String, dynamic> map) {
    return ExamPatternModel(
      id: map['id']?.toString() ?? '',
      paperName: map['paperName']?.toString(),
      subject: map['subject']?.toString() ?? '',
      questions: map['questions']?.toString() ?? '',
      marks: map['marks']?.toString() ?? '',
      duration: map['duration']?.toString(),
      negativeMarking: map['negativeMarking']?.toString(),
      minimumQualifyingMarks: map['minimumQualifyingMarks']?.toString(),
      notes: map['notes']?.toString(),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        if (paperName != null) 'paperName': paperName,
        'subject': subject,
        'questions': questions,
        'marks': marks,
        if (duration != null) 'duration': duration,
        if (negativeMarking != null) 'negativeMarking': negativeMarking,
        if (minimumQualifyingMarks != null)
          'minimumQualifyingMarks': minimumQualifyingMarks,
        if (notes != null) 'notes': notes,
      };
}

/// Structured sub-item for Documents Required
class DocumentItemModel {
  final String id;
  final String documentName;
  final bool required;
  final String? notes;

  const DocumentItemModel({
    this.id = '',
    this.documentName = '',
    this.required = true,
    this.notes,
  });

  factory DocumentItemModel.fromMap(Map<String, dynamic> map) {
    return DocumentItemModel(
      id: map['id']?.toString() ?? '',
      documentName: map['documentName']?.toString() ?? '',
      required: map['required'] != false,
      notes: map['notes']?.toString(),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'documentName': documentName,
        'required': required,
        if (notes != null) 'notes': notes,
      };
}

/// Structured sub-item for Upload Requirements
class UploadRequirementsModel {
  final String? photographFormat;
  final String? photographMaxSize;
  final String? signatureFormat;
  final String? signatureMaxSize;
  final String? certificateFormat;
  final String? certificateMaxSize;

  const UploadRequirementsModel({
    this.photographFormat,
    this.photographMaxSize,
    this.signatureFormat,
    this.signatureMaxSize,
    this.certificateFormat,
    this.certificateMaxSize,
  });

  factory UploadRequirementsModel.fromMap(Map<String, dynamic> map) {
    return UploadRequirementsModel(
      photographFormat: map['photographFormat']?.toString(),
      photographMaxSize: map['photographMaxSize']?.toString(),
      signatureFormat: map['signatureFormat']?.toString(),
      signatureMaxSize: map['signatureMaxSize']?.toString(),
      certificateFormat: map['certificateFormat']?.toString(),
      certificateMaxSize: map['certificateMaxSize']?.toString(),
    );
  }

  Map<String, dynamic> toMap() => {
        if (photographFormat != null) 'photographFormat': photographFormat,
        if (photographMaxSize != null) 'photographMaxSize': photographMaxSize,
        if (signatureFormat != null) 'signatureFormat': signatureFormat,
        if (signatureMaxSize != null) 'signatureMaxSize': signatureMaxSize,
        if (certificateFormat != null) 'certificateFormat': certificateFormat,
        if (certificateMaxSize != null)
          'certificateMaxSize': certificateMaxSize,
      };
}

/// Structured sub-item for Exam Details
class ExamDetailsModel {
  final bool hasExam;
  final String? examMode;
  final String? examType;
  final String? examCentre;
  final String? examLocation;
  final String? examLanguage;
  final String? examDuration;
  final String? negativeMarking;
  final String? minimumQualifyingMarks;
  final String? admitCardMethod;

  const ExamDetailsModel({
    this.hasExam = false,
    this.examMode,
    this.examType,
    this.examCentre,
    this.examLocation,
    this.examLanguage,
    this.examDuration,
    this.negativeMarking,
    this.minimumQualifyingMarks,
    this.admitCardMethod,
  });

  factory ExamDetailsModel.fromMap(Map<String, dynamic> map) {
    return ExamDetailsModel(
      hasExam: map['hasExam'] == true,
      examMode: map['examMode']?.toString(),
      examType: map['examType']?.toString(),
      examCentre: map['examCentre']?.toString(),
      examLocation: map['examLocation']?.toString(),
      examLanguage: map['examLanguage']?.toString(),
      examDuration: map['examDuration']?.toString(),
      negativeMarking: map['negativeMarking']?.toString(),
      minimumQualifyingMarks: map['minimumQualifyingMarks']?.toString(),
      admitCardMethod: map['admitCardMethod']?.toString(),
    );
  }

  Map<String, dynamic> toMap() => {
        'hasExam': hasExam,
        if (examMode != null) 'examMode': examMode,
        if (examType != null) 'examType': examType,
        if (examCentre != null) 'examCentre': examCentre,
        if (examLocation != null) 'examLocation': examLocation,
        if (examLanguage != null) 'examLanguage': examLanguage,
        if (examDuration != null) 'examDuration': examDuration,
        if (negativeMarking != null) 'negativeMarking': negativeMarking,
        if (minimumQualifyingMarks != null)
          'minimumQualifyingMarks': minimumQualifyingMarks,
        if (admitCardMethod != null) 'admitCardMethod': admitCardMethod,
      };
}

/// Structured sub-item for Syllabus Topics
class SyllabusTopicModel {
  final String id;
  final String? subject;
  final String topicName;
  final String? details;

  const SyllabusTopicModel({
    this.id = '',
    this.subject,
    required this.topicName,
    this.details,
  });

  factory SyllabusTopicModel.fromMap(Map<String, dynamic> map) {
    return SyllabusTopicModel(
      id: map['id']?.toString() ?? '',
      subject: map['subject']?.toString(),
      topicName: map['topicName']?.toString() ?? map['title']?.toString() ?? '',
      details: map['details']?.toString(),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        if (subject != null) 'subject': subject,
        'topicName': topicName,
        if (details != null) 'details': details,
      };
}

/// Structured sub-item for Selection Rules
class SelectionRulesModel {
  final String? selectionBasis;
  final String? meritCalculation;
  final String? qualifyingCriteria;
  final String? documentVerificationRule;
  final String? waitingListRule;
  final String? reservationRule;
  final List<String> tieBreakingRules;

  const SelectionRulesModel({
    this.selectionBasis,
    this.meritCalculation,
    this.qualifyingCriteria,
    this.documentVerificationRule,
    this.waitingListRule,
    this.reservationRule,
    this.tieBreakingRules = const [],
  });

  factory SelectionRulesModel.fromMap(Map<String, dynamic> map) {
    return SelectionRulesModel(
      selectionBasis: map['selectionBasis']?.toString(),
      meritCalculation: map['meritCalculation']?.toString(),
      qualifyingCriteria: map['qualifyingCriteria']?.toString(),
      documentVerificationRule: map['documentVerificationRule']?.toString(),
      waitingListRule: map['waitingListRule']?.toString(),
      reservationRule: map['reservationRule']?.toString(),
      tieBreakingRules: (map['tieBreakingRules'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toMap() => {
        if (selectionBasis != null) 'selectionBasis': selectionBasis,
        if (meritCalculation != null) 'meritCalculation': meritCalculation,
        if (qualifyingCriteria != null)
          'qualifyingCriteria': qualifyingCriteria,
        if (documentVerificationRule != null)
          'documentVerificationRule': documentVerificationRule,
        if (waitingListRule != null) 'waitingListRule': waitingListRule,
        if (reservationRule != null) 'reservationRule': reservationRule,
        if (tieBreakingRules.isNotEmpty) 'tieBreakingRules': tieBreakingRules,
      };
}

/// Structured sub-item for Source Verification
class SourceVerificationModel {
  final String? sourceOrg;
  final String? notificationNumber;
  final String? gazetteNumber;
  final String? circularNumber;
  final String? sourcePdfUrl;
  final String? sourceWebsiteUrl;
  final String? sourcePublishedDate;
  final String? sourceLanguage;
  final bool sourceVerified;

  const SourceVerificationModel({
    this.sourceOrg,
    this.notificationNumber,
    this.gazetteNumber,
    this.circularNumber,
    this.sourcePdfUrl,
    this.sourceWebsiteUrl,
    this.sourcePublishedDate,
    this.sourceLanguage,
    this.sourceVerified = false,
  });

  factory SourceVerificationModel.fromMap(Map<String, dynamic> map) {
    return SourceVerificationModel(
      sourceOrg: map['sourceOrg']?.toString(),
      notificationNumber: map['notificationNumber']?.toString(),
      gazetteNumber: map['gazetteNumber']?.toString(),
      circularNumber: map['circularNumber']?.toString(),
      sourcePdfUrl: map['sourcePdfUrl']?.toString(),
      sourceWebsiteUrl: map['sourceWebsiteUrl']?.toString(),
      sourcePublishedDate: map['sourcePublishedDate']?.toString(),
      sourceLanguage: map['sourceLanguage']?.toString(),
      sourceVerified: map['sourceVerified'] == true,
    );
  }

  Map<String, dynamic> toMap() => {
        if (sourceOrg != null) 'sourceOrg': sourceOrg,
        if (notificationNumber != null)
          'notificationNumber': notificationNumber,
        if (gazetteNumber != null) 'gazetteNumber': gazetteNumber,
        if (circularNumber != null) 'circularNumber': circularNumber,
        if (sourcePdfUrl != null) 'sourcePdfUrl': sourcePdfUrl,
        if (sourceWebsiteUrl != null) 'sourceWebsiteUrl': sourceWebsiteUrl,
        if (sourcePublishedDate != null)
          'sourcePublishedDate': sourcePublishedDate,
        if (sourceLanguage != null) 'sourceLanguage': sourceLanguage,
        'sourceVerified': sourceVerified,
      };
}

/// App Display Controls per content item
class AppDisplayControlsModel {
  final bool showOverview;
  final bool showImportantDates;
  final bool showPosts;
  final bool showVacancies;
  final bool showQualification;
  final bool showAgeLimit;
  final bool showFees;
  final bool showSalary;
  final bool showApplicationProcess;
  final bool showDocuments;
  final bool showExamDetails;
  final bool showExamPattern;
  final bool showSyllabus;
  final bool showSelectionProcess;
  final bool showImportantLinks;
  final bool showFAQ;
  final bool showSourceInformation;
  final bool showDisclaimer;

  const AppDisplayControlsModel({
    this.showOverview = true,
    this.showImportantDates = true,
    this.showPosts = true,
    this.showVacancies = true,
    this.showQualification = true,
    this.showAgeLimit = true,
    this.showFees = true,
    this.showSalary = true,
    this.showApplicationProcess = true,
    this.showDocuments = true,
    this.showExamDetails = true,
    this.showExamPattern = true,
    this.showSyllabus = true,
    this.showSelectionProcess = true,
    this.showImportantLinks = true,
    this.showFAQ = true,
    this.showSourceInformation = true,
    this.showDisclaimer = true,
  });

  factory AppDisplayControlsModel.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const AppDisplayControlsModel();
    return AppDisplayControlsModel(
      showOverview: map['showOverview'] != false,
      showImportantDates: map['showImportantDates'] != false,
      showPosts: map['showPosts'] != false,
      showVacancies: map['showVacancies'] != false,
      showQualification: map['showQualification'] != false,
      showAgeLimit: map['showAgeLimit'] != false,
      showFees: map['showFees'] != false,
      showSalary: map['showSalary'] != false,
      showApplicationProcess: map['showApplicationProcess'] != false,
      showDocuments: map['showDocuments'] != false,
      showExamDetails: map['showExamDetails'] != false,
      showExamPattern: map['showExamPattern'] != false,
      showSyllabus: map['showSyllabus'] != false,
      showSelectionProcess: map['showSelectionProcess'] != false,
      showImportantLinks: map['showImportantLinks'] != false,
      showFAQ: map['showFAQ'] != false,
      showSourceInformation: map['showSourceInformation'] != false,
      showDisclaimer: map['showDisclaimer'] != false,
    );
  }

  Map<String, dynamic> toMap() => {
        'showOverview': showOverview,
        'showImportantDates': showImportantDates,
        'showPosts': showPosts,
        'showVacancies': showVacancies,
        'showQualification': showQualification,
        'showAgeLimit': showAgeLimit,
        'showFees': showFees,
        'showSalary': showSalary,
        'showApplicationProcess': showApplicationProcess,
        'showDocuments': showDocuments,
        'showExamDetails': showExamDetails,
        'showExamPattern': showExamPattern,
        'showSyllabus': showSyllabus,
        'showSelectionProcess': showSelectionProcess,
        'showImportantLinks': showImportantLinks,
        'showFAQ': showFAQ,
        'showSourceInformation': showSourceInformation,
        'showDisclaimer': showDisclaimer,
      };
}

/// Structured sub-item for Important Links
class ImportantLinkModel {
  final String id;
  final String title;
  final String url;
  final String
      type; // apply_online, official_notification, official_website, download_pdf, custom

  const ImportantLinkModel({
    required this.id,
    required this.title,
    required this.url,
    required this.type,
  });

  bool get isApplyOnline => type == 'apply_online';
  bool get isOfficialNotification =>
      type == 'official_notification' || type == 'download_pdf';
  bool get isOfficialWebsite => type == 'official_website';

  factory ImportantLinkModel.fromMap(Map<String, dynamic> map) {
    return ImportantLinkModel(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? 'Link',
      url: map['url']?.toString() ?? '',
      type: map['type']?.toString() ?? 'custom',
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'url': url,
        'type': type,
      };
}

/// Structured sub-item for FAQs
class FAQModel {
  final String id;
  final String question;
  final String answer;

  const FAQModel({
    required this.id,
    required this.question,
    required this.answer,
  });

  factory FAQModel.fromMap(Map<String, dynamic> map) {
    return FAQModel(
      id: map['id']?.toString() ?? '',
      question: map['question']?.toString() ?? '',
      answer: map['answer']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'question': question,
        'answer': answer,
      };
}

/// Comprehensive Content Document Model with Safe Null Parsing (Specification 60 & 123)
class ContentModel {
  final String id;
  final String contentType;
  final String title;
  final String slug;
  final String excerpt;
  final String body;
  final String? featuredImageUrl;

  final String organization;
  final String? department;
  final String jobRole;
  final String vacancies;
  final String qualification;
  final String salary;
  final String location;
  final String? jobType;
  final String? jobTypeId;
  final String? jobTypeName;
  final bool isReviewed;
  final String? reviewedAt;
  final String? reviewedBy;
  final Map<String, String>? customSectionHeadings;
  final bool showInLiveUpdates;

  // Private / Andaman specific fields
  final String? companyName;
  final String? island;
  final String? salaryRange;
  final String? experience;
  final List<String> skills;
  final String? employmentType;
  final String? workingHours;
  final String? applicationMethod;
  final String? contactEmail;
  final String? contactPhone;
  final String? whatsappApplyUrl;
  final String? jobDescription;
  final String? requirements;

  final String? applicationStartDate;
  final String? applicationLastDate;
  final String? statusOverride;

  final String? officialWebsiteUrl;
  final String? officialNotificationUrl;
  final String? applyUrl;

  final List<ImportantDateModel> importantDates;
  final List<VacancyItemModel> vacanciesBreakdown;
  final List<AgeLimitModel> ageLimits;
  final List<ApplicationFeeModel> applicationFees;
  final List<SelectionStepModel> selectionProcess;
  final List<ExamPatternModel> examPattern;
  final List<ImportantLinkModel> importantLinks;
  final List<FAQModel> faqs;

  final String? sourceOrg;
  final String? sourceUrl;
  final String? lastVerifiedAt;

  final String status;
  final bool isPublished;
  final String? publishedAt;
  final String? updatedAt;
  final int views;
  final List<String> categoryIds;
  final List<String> tags;

  // Visibility & Placement Controls
  final bool showInUserApp;
  final bool featured;
  final bool urgent;
  final bool showInLatestJobs;
  final bool showInAndamanSection;
  final bool showInClosingSoon;
  final bool showInSearch;
  final bool allowNotifications;
  final bool showOnHome;

  // Structured Recruitment Model (v1.2 & One-Stop Editor)
  final String? vacancyMode;
  final List<PostItemModel> posts;
  final List<String> categoryNames;
  final List<String> howToApplySteps;
  final String? qualificationDetails;
  final String? feePaymentLastDate;
  final String? correctionStartDate;
  final String? correctionEndDate;

  // One-Stop Recruitment Meta
  final String? recruitmentYear;
  final String? notificationNumber;
  final String? advtNumber;
  final String? recruitmentType;
  final String? officialLanguage;
  final String? eligibilitySummary;
  final String? experienceRequired;
  final String? nationality;
  final String? registrationRequirement;
  final String? otherEligibility;
  final String? defaultMinimumAge;
  final String? defaultMaximumAge;
  final String? ageAsOn;
  final String? payLevel;
  final String? payScale;
  final String? salaryMin;
  final String? salaryMax;
  final String? salaryText;
  final String? applicationMode;
  final bool? registrationRequired;
  final bool? oneTimeRegistration;
  final String? applicationInstructions;

  // Structured Modules
  final List<DocumentItemModel> documents;
  final UploadRequirementsModel? uploadRequirements;
  final ExamDetailsModel? examDetails;
  final List<SyllabusTopicModel> syllabusTopics;
  final String? syllabusPdfUrl;
  final SelectionRulesModel? selectionRules;
  final List<String> tieBreakingRules;
  final AppDisplayControlsModel appDisplayControls;
  final SourceVerificationModel? sourceVerification;

  // Parent Recruitment & Exam Update Specifics
  final String? parentRecruitmentId;
  final String? parentRecruitmentTitle;
  final String? pressNoteUrl;
  final String? syllabusUrl;
  final String? admitCardUrl;
  final String? resultUrl;
  final String? examDate;
  final String? admitCardReleaseDate;
  final String? reportingTime;
  final String? examCenterInfo;
  final String? resultDate;
  final String? answerKeyReleaseDate;
  final String? objectionStartDate;
  final String? objectionLastDate;
  final String? objectionFee;
  final String? instructions;
  final String? updateStatus;

  const ContentModel({
    required this.id,
    required this.contentType,
    required this.title,
    required this.slug,
    required this.excerpt,
    required this.body,
    this.featuredImageUrl,
    required this.organization,
    this.department,
    required this.jobRole,
    required this.vacancies,
    required this.qualification,
    required this.salary,
    required this.location,
    this.jobType,
    this.jobTypeId,
    this.jobTypeName,
    this.isReviewed = false,
    this.reviewedAt,
    this.reviewedBy,
    this.customSectionHeadings,
    this.showInLiveUpdates = false,
    this.showInUserApp = true,
    this.featured = false,
    this.urgent = false,
    this.showInLatestJobs = true,
    this.showInAndamanSection = false,
    this.showInClosingSoon = true,
    this.showInSearch = true,
    this.allowNotifications = true,
    this.showOnHome = true,
    this.companyName,
    this.island,
    this.salaryRange,
    this.experience,
    this.skills = const [],
    this.employmentType,
    this.workingHours,
    this.applicationMethod,
    this.contactEmail,
    this.contactPhone,
    this.whatsappApplyUrl,
    this.jobDescription,
    this.requirements,
    this.applicationStartDate,
    this.applicationLastDate,
    this.statusOverride,
    this.officialWebsiteUrl,
    this.officialNotificationUrl,
    this.applyUrl,
    this.importantDates = const [],
    this.vacanciesBreakdown = const [],
    this.ageLimits = const [],
    this.applicationFees = const [],
    this.selectionProcess = const [],
    this.examPattern = const [],
    this.importantLinks = const [],
    this.faqs = const [],
    this.sourceOrg,
    this.sourceUrl,
    this.lastVerifiedAt,
    this.status = 'published',
    this.isPublished = true,
    this.publishedAt,
    this.updatedAt,
    this.views = 0,
    this.categoryIds = const [],
    this.tags = const [],
    this.vacancyMode,
    this.posts = const [],
    this.categoryNames = const [],
    this.howToApplySteps = const [],
    this.qualificationDetails,
    this.feePaymentLastDate,
    this.correctionStartDate,
    this.correctionEndDate,
    this.recruitmentYear,
    this.notificationNumber,
    this.advtNumber,
    this.recruitmentType,
    this.officialLanguage,
    this.eligibilitySummary,
    this.experienceRequired,
    this.nationality,
    this.registrationRequirement,
    this.otherEligibility,
    this.defaultMinimumAge,
    this.defaultMaximumAge,
    this.ageAsOn,
    this.payLevel,
    this.payScale,
    this.salaryMin,
    this.salaryMax,
    this.salaryText,
    this.applicationMode,
    this.registrationRequired,
    this.oneTimeRegistration,
    this.applicationInstructions,
    this.documents = const [],
    this.uploadRequirements,
    this.examDetails,
    this.syllabusTopics = const [],
    this.syllabusPdfUrl,
    this.selectionRules,
    this.tieBreakingRules = const [],
    this.appDisplayControls = const AppDisplayControlsModel(),
    this.sourceVerification,
    this.parentRecruitmentId,
    this.parentRecruitmentTitle,
    this.pressNoteUrl,
    this.syllabusUrl,
    this.admitCardUrl,
    this.resultUrl,
    this.examDate,
    this.admitCardReleaseDate,
    this.reportingTime,
    this.examCenterInfo,
    this.resultDate,
    this.answerKeyReleaseDate,
    this.objectionStartDate,
    this.objectionLastDate,
    this.objectionFee,
    this.instructions,
    this.updateStatus,
  });

  /// JSON Deserializer for unit testing and mock data
  factory ContentModel.fromJson(String id, Map<String, dynamic> json) =>
      ContentModel.fromMap(json, id);

  String get categoryName => categoryDisplay;
  String get category => contentType;

  /// Dynamic Total Vacancies auto-calculated from posts if available,
  /// falling back to vacanciesBreakdown, then parsing vacancies string.
  int get totalVacancies {
    if (posts.isNotEmpty) {
      return posts.fold<int>(0, (sum, p) => sum + p.vacancies.total);
    }
    if (vacanciesBreakdown.isNotEmpty) {
      final breakdownSum = vacanciesBreakdown.fold<int>(
        0,
        (sum, v) =>
            sum +
            (int.tryParse(v.count.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0),
      );
      if (breakdownSum > 0) return breakdownSum;
    }
    return int.tryParse(vacancies.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
  }

  /// Clean display string for vacancy metrics
  String get displayVacancies {
    final count = totalVacancies;
    if (count > 0) {
      return NormalizationUtils.formatVacancies(count);
    }
    if (vacancies.trim().isNotEmpty) {
      return NormalizationUtils.formatVacancies(vacancies);
    }
    return 'As per Notification';
  }

  DateTime? get lastDateParsed => applicationLastDate != null
      ? DateTime.tryParse(applicationLastDate!)
      : null;
  String? get advtNo => sourceOrg;

  /// Safe Factory with Fallbacks (Specification 123)
  factory ContentModel.fromMap(Map<String, dynamic> map, String docId) {
    String? parseDate(dynamic val) {
      if (val == null) return null;
      if (val is String) {
        final t = val.trim();
        return t.isEmpty ? null : t;
      }
      if (val is DateTime) return val.toIso8601String();
      try {
        final dynamic dyn = val;
        if (dyn.toDate != null) {
          return (dyn.toDate() as DateTime).toIso8601String();
        }
      } catch (_) {}
      return val.toString();
    }

    return ContentModel(
      id: docId.isNotEmpty ? docId : (map['id']?.toString() ?? ''),
      contentType: map['contentType']?.toString() ?? 'government_job',
      title: map['title']?.toString() ?? 'Untitled Announcement',
      slug: map['slug']?.toString() ?? docId,
      excerpt: map['excerpt']?.toString() ?? '',
      body: map['body']?.toString() ?? '',
      featuredImageUrl: map['featuredImageUrl']?.toString(),
      organization: map['organization']?.toString() ?? 'Govt Organization',
      department: map['department']?.toString(),
      jobRole: map['jobRole']?.toString() ?? '',
      vacancies: () {
        final v = map['vacancies'] ?? map['totalVacancies'];
        return v != null ? v.toString() : '';
      }(),
      qualification: map['qualification'] is List
          ? (map['qualification'] as List).map((e) => e.toString()).join(', ')
          : (map['qualification']?.toString() ?? ''),
      salary:
          map['salary']?.toString() ?? map['salaryPayScale']?.toString() ?? '',
      location: map['location']?.toString() ?? 'All India',
      jobType: map['jobType']?.toString(),
      jobTypeId: map['jobTypeId']?.toString(),
      jobTypeName: map['jobTypeName']?.toString(),
      applicationStartDate: parseDate(map['applicationStartDate']),
      applicationLastDate:
          parseDate(map['applicationLastDate'] ?? map['lastDateToApply']),
      statusOverride: map['statusOverride']?.toString(),
      officialWebsiteUrl: map['officialWebsiteUrl']?.toString(),
      officialNotificationUrl: map['officialNotificationUrl']?.toString(),
      applyUrl: map['applyUrl']?.toString(),
      importantDates: () {
        final raw = map['importantDates'];
        if (raw is List) {
          return raw.map((e) {
            if (e is Map) {
              return ImportantDateModel.fromMap(Map<String, dynamic>.from(e));
            }
            return ImportantDateModel(id: '', label: e.toString(), date: '');
          }).toList();
        } else if (raw is Map) {
          return raw.entries
              .map((e) => ImportantDateModel(
                    id: e.key.toString(),
                    label: e.key.toString(),
                    date: e.value?.toString() ?? '',
                  ))
              .toList();
        }
        return <ImportantDateModel>[];
      }(),
      vacanciesBreakdown: () {
        final raw = map['vacanciesBreakdown'];
        if (raw is List) {
          return raw
              .whereType<Map>()
              .map(
                  (e) => VacancyItemModel.fromMap(Map<String, dynamic>.from(e)))
              .toList();
        }
        return <VacancyItemModel>[];
      }(),
      ageLimits: () {
        final raw =
            map['ageLimits'] ?? map['ageLimit'] ?? map['ageRelaxations'];
        if (raw is List) {
          return raw.map<AgeLimitModel>((e) {
            if (e is Map) {
              return AgeLimitModel.fromMap(Map<String, dynamic>.from(e));
            }
            return AgeLimitModel(category: e.toString());
          }).toList();
        } else if (raw is Map) {
          return <AgeLimitModel>[
            AgeLimitModel.fromMap(Map<String, dynamic>.from(raw))
          ];
        }
        return <AgeLimitModel>[];
      }(),
      applicationFees: () {
        final raw = map['applicationFees'];
        if (raw is List) {
          return raw.map<ApplicationFeeModel>((e) {
            if (e is Map) {
              return ApplicationFeeModel.fromMap(Map<String, dynamic>.from(e));
            }
            return ApplicationFeeModel(category: e.toString(), fee: '0');
          }).toList();
        } else if (raw is Map) {
          return raw.entries
              .map<ApplicationFeeModel>((e) => ApplicationFeeModel(
                    id: e.key.toString(),
                    category: e.key.toString(),
                    fee: e.value?.toString() ?? '0',
                  ))
              .toList();
        }
        return <ApplicationFeeModel>[];
      }(),
      selectionProcess: () {
        final raw = map['selectionProcess'];
        if (raw is List) {
          return raw.asMap().entries.map<SelectionStepModel>((entry) {
            final e = entry.value;
            if (e is Map) {
              return SelectionStepModel.fromMap(Map<String, dynamic>.from(e));
            }
            return SelectionStepModel(
              id: entry.key.toString(),
              stageNumber: entry.key + 1,
              name: e.toString(),
              description: '',
            );
          }).toList();
        }
        return <SelectionStepModel>[];
      }(),
      examPattern: () {
        final raw = map['examPattern'];
        if (raw is List) {
          return raw
              .whereType<Map>()
              .map(
                  (e) => ExamPatternModel.fromMap(Map<String, dynamic>.from(e)))
              .toList();
        }
        return <ExamPatternModel>[];
      }(),
      importantLinks: () {
        final raw = map['importantLinks'];
        if (raw is List) {
          return raw
              .whereType<Map>()
              .map((e) =>
                  ImportantLinkModel.fromMap(Map<String, dynamic>.from(e)))
              .toList();
        }
        return <ImportantLinkModel>[];
      }(),
      faqs: () {
        final raw = map['faqs'];
        if (raw is List) {
          return raw
              .whereType<Map>()
              .map((e) => FAQModel.fromMap(Map<String, dynamic>.from(e)))
              .toList();
        }
        return <FAQModel>[];
      }(),
      sourceOrg: map['sourceOrg']?.toString(),
      sourceUrl: map['sourceUrl']?.toString(),
      lastVerifiedAt: map['lastVerifiedAt']?.toString(),
      status: map['status']?.toString() ?? 'published',
      isPublished: () {
        final st =
            map['status']?.toString().toLowerCase().trim() ?? 'published';
        if (st == 'draft' || st == 'archived' || st == 'scheduled') {
          return false;
        }
        if (map['isPublished'] == false ||
            map['isPublished']?.toString().toLowerCase() == 'false') {
          return false;
        }
        final isPub = map['isPublished'] == true ||
            map['isPublished']?.toString().toLowerCase() == 'true' ||
            st == 'published';
        if (!isPub) return false;

        final pubAt = parseDate(map['publishedAt'] ?? map['publishAt']);
        if (pubAt != null && pubAt.isNotEmpty) {
          final dt = DateTime.tryParse(pubAt);
          if (dt != null && dt.isAfter(DateTime.now())) {
            return false; // Scheduled in the future
          }
        }
        return true;
      }(),
      publishedAt: parseDate(map['publishedAt'] ?? map['publishAt']),
      updatedAt: parseDate(map['updatedAt']),
      views: int.tryParse(map['views']?.toString() ?? '0') ?? 0,
      categoryIds: () {
        final raw = map['categoryIds'];
        if (raw is List) {
          return raw.map((e) => e.toString()).toList();
        } else if (raw is String && raw.isNotEmpty) {
          return [raw];
        }
        return <String>[];
      }(),
      tags: () {
        final raw = map['tags'];
        if (raw is List) {
          return raw.map((e) => e.toString()).toList();
        } else if (raw is String && raw.isNotEmpty) {
          return [raw];
        }
        return <String>[];
      }(),
      showInLiveUpdates:
          map['showInLiveUpdates'] == true || map['isLiveUpdate'] == true,
      showInUserApp: map['showInUserApp'] != false,
      featured: map['featured'] == true,
      urgent: map['urgent'] == true,
      showInLatestJobs: map['showInLatestJobs'] != false,
      showInAndamanSection: map['showInAndamanSection'] == true,
      showInClosingSoon: map['showInClosingSoon'] != false,
      showInSearch: map['showInSearch'] != false,
      allowNotifications: map['allowNotifications'] != false,
      showOnHome: map['showOnHome'] != false,
      companyName: map['companyName']?.toString(),
      island: map['island']?.toString(),
      salaryRange: map['salaryRange']?.toString(),
      experience: map['experience']?.toString(),
      skills: (map['skills'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      employmentType: map['employmentType']?.toString(),
      workingHours: map['workingHours']?.toString(),
      applicationMethod: map['applicationMethod']?.toString(),
      contactEmail: map['contactEmail']?.toString(),
      contactPhone: map['contactPhone']?.toString(),
      whatsappApplyUrl: map['whatsappApplyUrl']?.toString(),
      jobDescription: map['jobDescription']?.toString(),
      requirements: map['requirements']?.toString(),
      isReviewed: map['isReviewed'] == true,
      reviewedAt: parseDate(map['reviewedAt']),
      reviewedBy: map['reviewedBy']?.toString(),
      customSectionHeadings: map['customSectionHeadings'] is Map
          ? (map['customSectionHeadings'] as Map).map(
              (k, v) => MapEntry(k.toString(), v?.toString() ?? ''),
            )
          : null,
      vacancyMode: map['vacancyMode']?.toString(),
      posts: () {
        final raw = map['posts'];
        if (raw is List) {
          return raw
              .whereType<Map>()
              .map((e) => PostItemModel.fromMap(Map<String, dynamic>.from(e)))
              .toList();
        }
        return <PostItemModel>[];
      }(),
      categoryNames: () {
        final raw = map['categoryNames'];
        if (raw is List) {
          return raw.map((e) => e.toString()).toList();
        }
        return <String>[];
      }(),
      howToApplySteps: () {
        final raw = map['howToApplySteps'];
        if (raw is List) {
          return raw.map((e) => e.toString()).toList();
        }
        return <String>[];
      }(),
      qualificationDetails: map['qualificationDetails']?.toString(),
      feePaymentLastDate: parseDate(map['feePaymentLastDate']),
      correctionStartDate: parseDate(map['correctionStartDate']),
      correctionEndDate: parseDate(map['correctionEndDate']),
      recruitmentYear: map['recruitmentYear']?.toString(),
      notificationNumber: map['notificationNumber']?.toString(),
      advtNumber: map['advtNumber']?.toString(),
      recruitmentType: map['recruitmentType']?.toString(),
      officialLanguage: map['officialLanguage']?.toString(),
      eligibilitySummary: map['eligibilitySummary']?.toString(),
      experienceRequired: map['experienceRequired']?.toString(),
      nationality: map['nationality']?.toString(),
      registrationRequirement: map['registrationRequirement']?.toString(),
      otherEligibility: map['otherEligibility']?.toString(),
      defaultMinimumAge: map['defaultMinimumAge']?.toString(),
      defaultMaximumAge: map['defaultMaximumAge']?.toString(),
      ageAsOn: map['ageAsOn']?.toString(),
      payLevel: map['payLevel']?.toString(),
      payScale: map['payScale']?.toString(),
      salaryMin: map['salaryMin']?.toString(),
      salaryMax: map['salaryMax']?.toString(),
      salaryText: map['salaryText']?.toString(),
      applicationMode: map['applicationMode']?.toString(),
      registrationRequired: map['registrationRequired'] == true,
      oneTimeRegistration: map['oneTimeRegistration'] == true,
      applicationInstructions: map['applicationInstructions']?.toString(),
      documents: () {
        final raw = map['documents'];
        if (raw is List) {
          return raw
              .whereType<Map>()
              .map((e) =>
                  DocumentItemModel.fromMap(Map<String, dynamic>.from(e)))
              .toList();
        }
        return <DocumentItemModel>[];
      }(),
      uploadRequirements: map['uploadRequirements'] is Map
          ? UploadRequirementsModel.fromMap(
              Map<String, dynamic>.from(map['uploadRequirements']))
          : null,
      examDetails: map['examDetails'] is Map
          ? ExamDetailsModel.fromMap(
              Map<String, dynamic>.from(map['examDetails']))
          : null,
      syllabusTopics: () {
        final raw = map['syllabusTopics'];
        if (raw is List) {
          return raw
              .whereType<Map>()
              .map((e) =>
                  SyllabusTopicModel.fromMap(Map<String, dynamic>.from(e)))
              .toList();
        }
        return <SyllabusTopicModel>[];
      }(),
      syllabusPdfUrl:
          map['syllabusPdfUrl']?.toString() ?? map['syllabusUrl']?.toString(),
      selectionRules: map['selectionRules'] is Map
          ? SelectionRulesModel.fromMap(
              Map<String, dynamic>.from(map['selectionRules']))
          : null,
      tieBreakingRules: (map['tieBreakingRules'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      appDisplayControls: AppDisplayControlsModel.fromMap(
          map['appDisplayControls'] is Map
              ? Map<String, dynamic>.from(map['appDisplayControls'])
              : null),
      sourceVerification: map['sourceVerification'] is Map
          ? SourceVerificationModel.fromMap(
              Map<String, dynamic>.from(map['sourceVerification']))
          : null,
      parentRecruitmentId: map['parentRecruitmentId']?.toString(),
      parentRecruitmentTitle: map['parentRecruitmentTitle']?.toString(),
      pressNoteUrl: map['pressNoteUrl']?.toString(),
      syllabusUrl: map['syllabusUrl']?.toString(),
      admitCardUrl: map['admitCardUrl']?.toString(),
      resultUrl: map['resultUrl']?.toString(),
      examDate: map['examDate']?.toString(),
      admitCardReleaseDate: map['admitCardReleaseDate']?.toString(),
      reportingTime: map['reportingTime']?.toString(),
      examCenterInfo: map['examCenterInfo']?.toString(),
      resultDate: map['resultDate']?.toString(),
      answerKeyReleaseDate: map['answerKeyReleaseDate']?.toString(),
      objectionStartDate: map['objectionStartDate']?.toString(),
      objectionLastDate: map['objectionLastDate']?.toString(),
      objectionFee: map['objectionFee']?.toString(),
      instructions: map['instructions']?.toString(),
      updateStatus: map['updateStatus']?.toString(),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'contentType': contentType,
        'title': title,
        'slug': slug,
        'excerpt': excerpt,
        'body': body,
        'featuredImageUrl': featuredImageUrl,
        'organization': organization,
        'department': department,
        'jobRole': jobRole,
        'vacancies': vacancies,
        'qualification': qualification,
        'salary': salary,
        'location': location,
        'jobType': jobType,
        if (jobTypeId != null) 'jobTypeId': jobTypeId,
        if (jobTypeName != null) 'jobTypeName': jobTypeName,
        'isReviewed': isReviewed,
        if (reviewedAt != null) 'reviewedAt': reviewedAt,
        if (reviewedBy != null) 'reviewedBy': reviewedBy,
        if (customSectionHeadings != null)
          'customSectionHeadings': customSectionHeadings,
        'showInLiveUpdates': showInLiveUpdates,
        'showInUserApp': showInUserApp,
        'featured': featured,
        'urgent': urgent,
        'showInLatestJobs': showInLatestJobs,
        'showInAndamanSection': showInAndamanSection,
        'showInClosingSoon': showInClosingSoon,
        'showInSearch': showInSearch,
        'allowNotifications': allowNotifications,
        'showOnHome': showOnHome,
        if (companyName != null) 'companyName': companyName,
        if (island != null) 'island': island,
        if (salaryRange != null) 'salaryRange': salaryRange,
        if (experience != null) 'experience': experience,
        if (skills.isNotEmpty) 'skills': skills,
        if (employmentType != null) 'employmentType': employmentType,
        if (workingHours != null) 'workingHours': workingHours,
        if (applicationMethod != null) 'applicationMethod': applicationMethod,
        if (contactEmail != null) 'contactEmail': contactEmail,
        if (contactPhone != null) 'contactPhone': contactPhone,
        if (whatsappApplyUrl != null) 'whatsappApplyUrl': whatsappApplyUrl,
        if (jobDescription != null) 'jobDescription': jobDescription,
        if (requirements != null) 'requirements': requirements,
        'applicationStartDate': applicationStartDate,
        'applicationLastDate': applicationLastDate,
        'statusOverride': statusOverride,
        'officialWebsiteUrl': officialWebsiteUrl,
        'officialNotificationUrl': officialNotificationUrl,
        'applyUrl': applyUrl,
        'importantDates': importantDates.map((e) => e.toMap()).toList(),
        'vacanciesBreakdown': vacanciesBreakdown.map((e) => e.toMap()).toList(),
        'ageLimits': ageLimits.map((e) => e.toMap()).toList(),
        'applicationFees': applicationFees.map((e) => e.toMap()).toList(),
        'selectionProcess': selectionProcess.map((e) => e.toMap()).toList(),
        'examPattern': examPattern.map((e) => e.toMap()).toList(),
        'importantLinks': importantLinks.map((e) => e.toMap()).toList(),
        'faqs': faqs.map((e) => e.toMap()).toList(),
        'sourceOrg': sourceOrg,
        'sourceUrl': sourceUrl,
        'lastVerifiedAt': lastVerifiedAt,
        'status': status,
        'isPublished': isPublished,
        'publishedAt': publishedAt,
        'updatedAt': updatedAt,
        'views': views,
        'categoryIds': categoryIds,
        'tags': tags,
        if (vacancyMode != null) 'vacancyMode': vacancyMode,
        'posts': posts.map((p) => p.toMap()).toList(),
        'categoryNames': categoryNames,
        'howToApplySteps': howToApplySteps,
        if (qualificationDetails != null)
          'qualificationDetails': qualificationDetails,
        if (feePaymentLastDate != null)
          'feePaymentLastDate': feePaymentLastDate,
        if (correctionStartDate != null)
          'correctionStartDate': correctionStartDate,
        if (correctionEndDate != null) 'correctionEndDate': correctionEndDate,
        if (recruitmentYear != null) 'recruitmentYear': recruitmentYear,
        if (notificationNumber != null)
          'notificationNumber': notificationNumber,
        if (advtNumber != null) 'advtNumber': advtNumber,
        if (recruitmentType != null) 'recruitmentType': recruitmentType,
        if (officialLanguage != null) 'officialLanguage': officialLanguage,
        if (eligibilitySummary != null)
          'eligibilitySummary': eligibilitySummary,
        if (experienceRequired != null)
          'experienceRequired': experienceRequired,
        if (nationality != null) 'nationality': nationality,
        if (registrationRequirement != null)
          'registrationRequirement': registrationRequirement,
        if (otherEligibility != null) 'otherEligibility': otherEligibility,
        if (defaultMinimumAge != null) 'defaultMinimumAge': defaultMinimumAge,
        if (defaultMaximumAge != null) 'defaultMaximumAge': defaultMaximumAge,
        if (ageAsOn != null) 'ageAsOn': ageAsOn,
        if (payLevel != null) 'payLevel': payLevel,
        if (payScale != null) 'payScale': payScale,
        if (salaryMin != null) 'salaryMin': salaryMin,
        if (salaryMax != null) 'salaryMax': salaryMax,
        if (salaryText != null) 'salaryText': salaryText,
        if (applicationMode != null) 'applicationMode': applicationMode,
        if (registrationRequired != null)
          'registrationRequired': registrationRequired,
        if (oneTimeRegistration != null)
          'oneTimeRegistration': oneTimeRegistration,
        if (applicationInstructions != null)
          'applicationInstructions': applicationInstructions,
        'documents': documents.map((e) => e.toMap()).toList(),
        if (uploadRequirements != null)
          'uploadRequirements': uploadRequirements!.toMap(),
        if (examDetails != null) 'examDetails': examDetails!.toMap(),
        'syllabusTopics': syllabusTopics.map((e) => e.toMap()).toList(),
        if (syllabusPdfUrl != null) 'syllabusPdfUrl': syllabusPdfUrl,
        if (selectionRules != null) 'selectionRules': selectionRules!.toMap(),
        if (tieBreakingRules.isNotEmpty) 'tieBreakingRules': tieBreakingRules,
        'appDisplayControls': appDisplayControls.toMap(),
        if (sourceVerification != null)
          'sourceVerification': sourceVerification!.toMap(),
        if (parentRecruitmentId != null)
          'parentRecruitmentId': parentRecruitmentId,
        if (parentRecruitmentTitle != null)
          'parentRecruitmentTitle': parentRecruitmentTitle,
        if (pressNoteUrl != null) 'pressNoteUrl': pressNoteUrl,
        if (syllabusUrl != null) 'syllabusUrl': syllabusUrl,
        if (admitCardUrl != null) 'admitCardUrl': admitCardUrl,
        if (resultUrl != null) 'resultUrl': resultUrl,
        if (examDate != null) 'examDate': examDate,
        if (admitCardReleaseDate != null)
          'admitCardReleaseDate': admitCardReleaseDate,
        if (reportingTime != null) 'reportingTime': reportingTime,
        if (examCenterInfo != null) 'examCenterInfo': examCenterInfo,
        if (resultDate != null) 'resultDate': resultDate,
        if (answerKeyReleaseDate != null)
          'answerKeyReleaseDate': answerKeyReleaseDate,
        if (objectionStartDate != null)
          'objectionStartDate': objectionStartDate,
        if (objectionLastDate != null) 'objectionLastDate': objectionLastDate,
        if (objectionFee != null) 'objectionFee': objectionFee,
        if (instructions != null) 'instructions': instructions,
        if (updateStatus != null) 'updateStatus': updateStatus,
      };

  String get categoryDisplay {
    if (contentType == 'andaman_job' ||
        contentType == 'andaman' ||
        categoryIds.contains('andaman-nicobar')) {
      final sub = jobTypeName ??
          ((jobType?.toLowerCase() == 'private') ? 'PRIVATE' : 'GOVT');
      return 'A&N JOB • ${sub.toUpperCase()}';
    }
    if (categoryIds.contains('ssc')) return 'SSC';
    if (categoryIds.contains('railway')) return 'Railway';
    if (categoryIds.contains('banking')) return 'Banking';
    if (categoryIds.contains('police-defence')) return 'Police';
    switch (contentType) {
      case 'government_job':
        return jobTypeName ?? 'Govt Job';
      case 'private_job':
        return jobTypeName ?? 'Private Job';
      case 'admit_card':
        return 'Admit Card';
      case 'result':
        return 'Result';
      case 'answer_key':
        return 'Answer Key';
      case 'exam_date':
        return 'Exam Date';
      case 'syllabus':
        return 'Syllabus';
      case 'govt_update':
      case 'admission':
      case 'scholarship':
        return 'Govt Update';
      case 'article':
        return 'Article';
      default:
        return jobTypeName ?? 'Job Alert';
    }
  }

  bool get isAndamanJob =>
      contentType == 'andaman_job' ||
      contentType == 'andaman' ||
      categoryIds.contains('andaman-nicobar') ||
      categoryIds.contains('andaman_nicobar') ||
      categoryIds.contains('andaman') ||
      tags.any((t) =>
          t.toLowerCase().contains('andaman') ||
          t.toLowerCase().contains('nicobar')) ||
      location.toLowerCase().contains('andaman') ||
      location.toLowerCase().contains('port blair');

  bool get isJob =>
      contentType == 'government_job' ||
      contentType == 'private_job' ||
      contentType == 'andaman_job' ||
      contentType == 'job';

  bool get isPrivateJob =>
      isJob &&
      (contentType == 'private_job' ||
          (jobType?.toLowerCase().contains('private') ?? false));

  bool get isGovernmentJob {
    if (!isJob) {
      return false;
    }
    if (isPrivateJob) {
      return false;
    }
    return true;
  }

  bool isCategoryMatch(String filter) {
    if (filter.isEmpty || filter.toLowerCase() == 'all') {
      return true;
    }
    final f = filter.toLowerCase().trim();
    if (categoryIds.any((c) => c.toLowerCase() == f)) {
      return true;
    }
    if (categoryNames.any((cn) => cn.toLowerCase().contains(f))) {
      return true;
    }
    if (posts.any((p) =>
        (p.categoryId != null && p.categoryId!.toLowerCase() == f) ||
        (p.categoryName != null &&
            p.categoryName!.toLowerCase().contains(f)))) {
      return true;
    }

    if (f == 'ssc') {
      if (categoryIds.any((c) => c.toLowerCase().contains('ssc'))) {
        return true;
      }
      if (tags.any((t) => t.toLowerCase().contains('ssc'))) {
        return true;
      }
      if (organization.toLowerCase().contains('ssc')) {
        return true;
      }
      if (title.toLowerCase().contains('ssc')) {
        return true;
      }
    } else if (f == 'railway' || f == 'railways') {
      if (categoryIds.any((c) => c.toLowerCase().contains('railway'))) {
        return true;
      }
      if (tags.any((t) =>
          t.toLowerCase().contains('railway') ||
          t.toLowerCase().contains('rrb'))) {
        return true;
      }
      if (organization.toLowerCase().contains('railway') ||
          organization.toLowerCase().contains('rrb')) {
        return true;
      }
      if (title.toLowerCase().contains('railway') ||
          title.toLowerCase().contains('rrb')) {
        return true;
      }
    } else if (f == 'banking' || f == 'bank') {
      if (categoryIds.any((c) => c.toLowerCase().contains('bank'))) {
        return true;
      }
      if (tags.any((t) =>
          t.toLowerCase().contains('bank') ||
          t.toLowerCase().contains('ibps') ||
          t.toLowerCase().contains('sbi'))) {
        return true;
      }
      if (organization.toLowerCase().contains('bank') ||
          organization.toLowerCase().contains('ibps') ||
          organization.toLowerCase().contains('sbi')) {
        return true;
      }
      if (title.toLowerCase().contains('bank') ||
          title.toLowerCase().contains('ibps') ||
          title.toLowerCase().contains('sbi')) {
        return true;
      }
    } else if (f == 'police-defence' || f == 'police' || f == 'defence') {
      if (categoryIds.any((c) =>
          c.toLowerCase().contains('police') ||
          c.toLowerCase().contains('defence'))) {
        return true;
      }
      if (tags.any((t) =>
          t.toLowerCase().contains('police') ||
          t.toLowerCase().contains('defence') ||
          t.toLowerCase().contains('army') ||
          t.toLowerCase().contains('navy') ||
          t.toLowerCase().contains('air force'))) {
        return true;
      }
      if (organization.toLowerCase().contains('police') ||
          organization.toLowerCase().contains('defence') ||
          organization.toLowerCase().contains('crpf') ||
          organization.toLowerCase().contains('bsf') ||
          organization.toLowerCase().contains('cisf')) {
        return true;
      }
      if (title.toLowerCase().contains('police') ||
          title.toLowerCase().contains('defence') ||
          title.toLowerCase().contains('constable') ||
          title.toLowerCase().contains('sub inspector') ||
          title.toLowerCase().contains('si ')) {
        return true;
      }
    }

    return tags
            .any((t) => t.toLowerCase() == f || t.toLowerCase().contains(f)) ||
        organization.toLowerCase().contains(f) ||
        title.toLowerCase().contains(f);
  }

  ComputedStatus get computedStatus => StatusEngine.compute(
        contentType: contentType,
        lastDate: lastDateParsed,
        startDate: applicationStartDate != null
            ? DateTime.tryParse(applicationStartDate!)
            : null,
        explicitStatus: statusOverride ?? status,
      );

  String get displayLastDate {
    if (applicationLastDate == null || applicationLastDate!.isEmpty) {
      return 'Check Notice';
    }
    return NormalizationUtils.formatDate(applicationLastDate);
  }

  String get displayPublishedDate {
    if (publishedAt == null || publishedAt!.isEmpty) {
      return 'Recently';
    }
    try {
      final date = DateTime.parse(publishedAt!);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (_) {
      return 'Recently';
    }
  }

  String get relativePublishedDate {
    if (publishedAt == null || publishedAt!.isEmpty) return 'Recently';
    try {
      final date = DateTime.parse(publishedAt!);
      final diff = DateTime.now().difference(date);
      if (diff.inMinutes < 1) return 'Just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays == 1) return 'Yesterday';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      return DateFormat('dd MMM yyyy').format(date);
    } catch (_) {
      return 'Recently';
    }
  }

  String get displayPublishedDateTime {
    if (publishedAt == null || publishedAt!.isEmpty) return 'Recently';
    try {
      final date = DateTime.parse(publishedAt!);
      return DateFormat('dd MMM yyyy, hh:mm a').format(date);
    } catch (_) {
      return 'Recently';
    }
  }

  String get displayUpdatedDateTime {
    final raw = updatedAt ?? publishedAt;
    if (raw == null || raw.isEmpty) return 'Recently';
    try {
      final date = DateTime.parse(raw);
      return DateFormat('dd MMM yyyy, hh:mm a').format(date);
    } catch (_) {
      return 'Recently';
    }
  }

  /// Dynamic NEW badge rule (Specification item 4 & 41)
  /// Active when post was published within the configured days threshold (default: 3 days).
  bool isNew([int days = 3]) {
    if (!isPublished) return false;
    if (publishedAt == null || publishedAt!.isEmpty) return false;
    try {
      final pubDate = DateTime.parse(publishedAt!);
      final cutoff = pubDate.add(Duration(days: days));
      return DateTime.now().isBefore(cutoff);
    } catch (_) {
      return false;
    }
  }
}
