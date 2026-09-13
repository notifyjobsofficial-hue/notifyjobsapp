import 'package:intl/intl.dart';

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

/// Structured sub-item for Age Limits
class AgeLimitModel {
  final String id;
  final String category;
  final String relaxationYears;
  final String? maxAge;

  const AgeLimitModel({
    this.id = '',
    this.category = '',
    this.relaxationYears = '',
    this.maxAge,
  });

  String get minAge => '18';

  factory AgeLimitModel.fromMap(Map<String, dynamic> map) {
    return AgeLimitModel(
      id: map['id']?.toString() ?? '',
      category: map['category']?.toString() ?? '',
      relaxationYears: map['relaxationYears']?.toString() ?? '',
      maxAge: map['maxAge']?.toString(),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'category': category,
        'relaxationYears': relaxationYears,
        if (maxAge != null) 'maxAge': maxAge,
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
  final String subject;
  final String questions;
  final String marks;
  final String? duration;

  const ExamPatternModel({
    required this.id,
    required this.subject,
    required this.questions,
    required this.marks,
    this.duration,
  });

  factory ExamPatternModel.fromMap(Map<String, dynamic> map) {
    return ExamPatternModel(
      id: map['id']?.toString() ?? '',
      subject: map['subject']?.toString() ?? '',
      questions: map['questions']?.toString() ?? '',
      marks: map['marks']?.toString() ?? '',
      duration: map['duration']?.toString(),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'subject': subject,
        'questions': questions,
        'marks': marks,
        if (duration != null) 'duration': duration,
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
  });

  /// JSON Deserializer for unit testing and mock data
  factory ContentModel.fromJson(String id, Map<String, dynamic> json) =>
      ContentModel.fromMap(json, id);

  String get categoryName => categoryDisplay;
  String get category => contentType;
  int get totalVacancies =>
      int.tryParse(vacancies.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
  DateTime? get lastDateParsed => applicationLastDate != null
      ? DateTime.tryParse(applicationLastDate!)
      : null;
  String? get advtNo => sourceOrg;

  /// Safe Factory with Fallbacks (Specification 123)
  factory ContentModel.fromMap(Map<String, dynamic> map, String docId) {
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
      vacancies: map['totalVacancies'] != null
          ? map['totalVacancies'].toString()
          : (map['vacancies']?.toString() ?? ''),
      qualification: map['qualification'] is List
          ? (map['qualification'] as List).map((e) => e.toString()).join(', ')
          : (map['qualification']?.toString() ?? ''),
      salary: map['salary']?.toString() ??
          map['salaryPayScale']?.toString() ??
          '',
      location: map['location']?.toString() ?? 'All India',
      jobType: map['jobType']?.toString(),
      applicationStartDate: map['applicationStartDate']?.toString(),
      applicationLastDate: map['applicationLastDate']?.toString() ??
          map['lastDateToApply']?.toString(),
      statusOverride: map['statusOverride']?.toString(),
      officialWebsiteUrl: map['officialWebsiteUrl']?.toString(),
      officialNotificationUrl: map['officialNotificationUrl']?.toString(),
      applyUrl: map['applyUrl']?.toString(),
      importantDates: () {
        final raw = map['importantDates'];
        if (raw is List) {
          return raw.map((e) {
            if (e is Map<String, dynamic>) {
              return ImportantDateModel.fromMap(e);
            }
            if (e is Map) {
              return ImportantDateModel.fromMap(
                  Map<String, dynamic>.from(e));
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
      vacanciesBreakdown: (map['vacanciesBreakdown'] as List<dynamic>?)
              ?.map((e) => VacancyItemModel.fromMap(
                  e is Map<String, dynamic>
                      ? e
                      : Map<String, dynamic>.from(e as Map)))
              .toList() ??
          [],
      ageLimits: () {
        final raw = map['ageLimits'] ?? map['ageLimit'];
        if (raw is List) {
          return raw.map<AgeLimitModel>((e) {
            if (e is Map<String, dynamic>) {
              return AgeLimitModel.fromMap(e);
            }
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
            if (e is Map<String, dynamic>) {
              return ApplicationFeeModel.fromMap(e);
            }
            if (e is Map) {
              return ApplicationFeeModel.fromMap(
                  Map<String, dynamic>.from(e));
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
            if (e is Map<String, dynamic>) {
              return SelectionStepModel.fromMap(e);
            }
            if (e is Map) {
              return SelectionStepModel.fromMap(
                  Map<String, dynamic>.from(e));
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
      examPattern: (map['examPattern'] as List<dynamic>?)
              ?.map((e) => ExamPatternModel.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      importantLinks: (map['importantLinks'] as List<dynamic>?)
              ?.map(
                  (e) => ImportantLinkModel.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      faqs: (map['faqs'] as List<dynamic>?)
              ?.map((e) => FAQModel.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      sourceOrg: map['sourceOrg']?.toString(),
      sourceUrl: map['sourceUrl']?.toString(),
      lastVerifiedAt: map['lastVerifiedAt']?.toString(),
      status: map['status']?.toString() ?? 'published',
      isPublished: map['isPublished'] == true,
      publishedAt: map['publishedAt']?.toString(),
      updatedAt: map['updatedAt']?.toString(),
      views: int.tryParse(map['views']?.toString() ?? '0') ?? 0,
      categoryIds: (map['categoryIds'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      tags:
          (map['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
              [],
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
      };

  String get categoryDisplay {
    if (categoryIds.contains('andaman-nicobar')) return 'A&N Jobs';
    if (categoryIds.contains('ssc')) return 'SSC';
    if (categoryIds.contains('railway')) return 'Railway';
    if (categoryIds.contains('banking')) return 'Banking';
    if (categoryIds.contains('police-defence')) return 'Police';
    switch (contentType) {
      case 'government_job':
        return 'Govt Job';
      case 'admit_card':
        return 'Admit Card';
      case 'result':
        return 'Result';
      case 'answer_key':
        return 'Answer Key';
      case 'syllabus':
        return 'Syllabus';
      case 'article':
        return 'Article';
      default:
        return 'Job Alert';
    }
  }

  String get displayLastDate {
    if (applicationLastDate == null || applicationLastDate!.isEmpty) {
      return 'Check Notice';
    }
    try {
      final date = DateTime.parse(applicationLastDate!);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (_) {
      return applicationLastDate!;
    }
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
}
