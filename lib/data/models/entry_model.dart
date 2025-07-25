import 'package:equatable/equatable.dart';
import 'user_model.dart';
import 'comment_model.dart';
import 'reaction_model.dart';

class EntryModel extends Equatable {
  final String id;
  final String journalId;
  final String authorId;
  final String? title;
  final Map<String, dynamic> content; // Rich text content as Delta
  final String plainText; // Plain text for search and preview
  final DateTime createdAt;
  final DateTime updatedAt;
  final UserModel? author;
  final List<CommentModel>? comments;
  final List<ReactionModel>? reactions;
  final bool? isEdited;

  const EntryModel({
    required this.id,
    required this.journalId,
    required this.authorId,
    this.title,
    required this.content,
    required this.plainText,
    required this.createdAt,
    required this.updatedAt,
    this.author,
    this.comments,
    this.reactions,
    this.isEdited,
  });

  factory EntryModel.fromJson(Map<String, dynamic> json) {
    return EntryModel(
      id: json['id'] as String,
      journalId: json['journal_id'] as String,
      authorId: json['author_id'] as String,
      title: json['title'] as String?,
      content: json['content'] as Map<String, dynamic>,
      plainText: json['plain_text'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      author: json['author'] != null
          ? UserModel.fromJson(json['author'] as Map<String, dynamic>)
          : null,
      comments: json['comments'] != null
          ? (json['comments'] as List)
                .map((c) => CommentModel.fromJson(c as Map<String, dynamic>))
                .toList()
          : null,
      reactions: json['reactions'] != null
          ? (json['reactions'] as List)
                .map((r) => ReactionModel.fromJson(r as Map<String, dynamic>))
                .toList()
          : null,
      isEdited: json['created_at'] != json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'journal_id': journalId,
      'author_id': authorId,
      'title': title,
      'content': content,
      'plain_text': plainText,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  EntryModel copyWith({
    String? id,
    String? journalId,
    String? authorId,
    String? title,
    Map<String, dynamic>? content,
    String? plainText,
    DateTime? createdAt,
    DateTime? updatedAt,
    UserModel? author,
    List<CommentModel>? comments,
    List<ReactionModel>? reactions,
    bool? isEdited,
  }) {
    return EntryModel(
      id: id ?? this.id,
      journalId: journalId ?? this.journalId,
      authorId: authorId ?? this.authorId,
      title: title ?? this.title,
      content: content ?? this.content,
      plainText: plainText ?? this.plainText,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      author: author ?? this.author,
      comments: comments ?? this.comments,
      reactions: reactions ?? this.reactions,
      isEdited: isEdited ?? this.isEdited,
    );
  }

  String get preview {
    if (plainText.length <= 150) return plainText;
    return '${plainText.substring(0, 150)}...';
  }

  int get commentCount => comments?.length ?? 0;

  int get reactionCount => reactions?.length ?? 0;

  Map<String, int> get reactionCounts {
    final counts = <String, int>{};
    if (reactions != null) {
      for (final reaction in reactions!) {
        counts[reaction.emoji] = (counts[reaction.emoji] ?? 0) + 1;
      }
    }
    return counts;
  }

  List<String> get uniqueReactions {
    if (reactions == null) return [];
    return reactions!.map((r) => r.emoji).toSet().toList();
  }

  bool hasUserReacted(String userId, String emoji) {
    if (reactions == null) return false;
    return reactions!.any((r) => r.userId == userId && r.emoji == emoji);
  }

  Duration get timeAgo => DateTime.now().difference(createdAt);

  bool get wasEditedRecently {
    final editTime = updatedAt.difference(createdAt);
    return editTime.inMinutes >
        1; // Consider edited if updated more than 1 minute after creation
  }

  @override
  List<Object?> get props => [
    id,
    journalId,
    authorId,
    title,
    content,
    plainText,
    createdAt,
    updatedAt,
    author,
    comments,
    reactions,
    isEdited,
  ];
}
