import 'package:equatable/equatable.dart';
import 'user_model.dart';

class JournalModel extends Equatable {
  final String id;
  final String title;
  final String? description;
  final bool isShared;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final UserModel? creator;
  final List<JournalMember>? members;
  final int? entryCount;
  final DateTime? lastEntryAt;

  const JournalModel({
    required this.id,
    required this.title,
    this.description,
    required this.isShared,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.creator,
    this.members,
    this.entryCount,
    this.lastEntryAt,
  });

  factory JournalModel.fromJson(Map<String, dynamic> json) {
    return JournalModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      isShared: json['is_shared'] as bool,
      createdBy: json['created_by'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      creator: json['creator'] != null
          ? UserModel.fromJson(json['creator'] as Map<String, dynamic>)
          : null,
      members: json['members'] != null
          ? (json['members'] as List)
                .map((m) => JournalMember.fromJson(m as Map<String, dynamic>))
                .toList()
          : null,
      entryCount: json['entry_count'] as int?,
      lastEntryAt: json['last_entry_at'] != null
          ? DateTime.parse(json['last_entry_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'is_shared': isShared,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  JournalModel copyWith({
    String? id,
    String? title,
    String? description,
    bool? isShared,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
    UserModel? creator,
    List<JournalMember>? members,
    int? entryCount,
    DateTime? lastEntryAt,
  }) {
    return JournalModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isShared: isShared ?? this.isShared,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      creator: creator ?? this.creator,
      members: members ?? this.members,
      entryCount: entryCount ?? this.entryCount,
      lastEntryAt: lastEntryAt ?? this.lastEntryAt,
    );
  }

  String get typeText => isShared ? 'Shared Journal' : 'Personal Journal';

  int get memberCount => members?.length ?? 0;

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    isShared,
    createdBy,
    createdAt,
    updatedAt,
    creator,
    members,
    entryCount,
    lastEntryAt,
  ];
}

class JournalMember extends Equatable {
  final String id;
  final String journalId;
  final String userId;
  final JournalMemberRole role;
  final DateTime joinedAt;
  final UserModel? user;

  const JournalMember({
    required this.id,
    required this.journalId,
    required this.userId,
    required this.role,
    required this.joinedAt,
    this.user,
  });

  factory JournalMember.fromJson(Map<String, dynamic> json) {
    return JournalMember(
      id: json['id'] as String,
      journalId: json['journal_id'] as String,
      userId: json['user_id'] as String,
      role: JournalMemberRole.fromString(json['role'] as String),
      joinedAt: DateTime.parse(json['joined_at'] as String),
      user: json['user'] != null
          ? UserModel.fromJson(json['user'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'journal_id': journalId,
      'user_id': userId,
      'role': role.value,
      'joined_at': joinedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, journalId, userId, role, joinedAt, user];
}

enum JournalMemberRole {
  owner('owner'),
  admin('admin'),
  member('member');

  const JournalMemberRole(this.value);

  final String value;

  static JournalMemberRole fromString(String value) {
    return JournalMemberRole.values.firstWhere(
      (role) => role.value == value,
      orElse: () => JournalMemberRole.member,
    );
  }

  bool get canManageMembers => this == owner || this == admin;
  bool get canDeleteJournal => this == owner;
  bool get canEditJournal => this == owner || this == admin;
}
