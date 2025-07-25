import 'package:equatable/equatable.dart';
import 'user_model.dart';

class CommentModel extends Equatable {
  final String id;
  final String entryId;
  final String authorId;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final UserModel? author;
  final bool? isEdited;

  const CommentModel({
    required this.id,
    required this.entryId,
    required this.authorId,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.author,
    this.isEdited,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'] as String,
      entryId: json['entry_id'] as String,
      authorId: json['author_id'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      author: json['author'] != null
          ? UserModel.fromJson(json['author'] as Map<String, dynamic>)
          : null,
      isEdited: json['created_at'] != json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'entry_id': entryId,
      'author_id': authorId,
      'content': content,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  CommentModel copyWith({
    String? id,
    String? entryId,
    String? authorId,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
    UserModel? author,
    bool? isEdited,
  }) {
    return CommentModel(
      id: id ?? this.id,
      entryId: entryId ?? this.entryId,
      authorId: authorId ?? this.authorId,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      author: author ?? this.author,
      isEdited: isEdited ?? this.isEdited,
    );
  }

  Duration get timeAgo => DateTime.now().difference(createdAt);

  bool get wasEditedRecently {
    final editTime = updatedAt.difference(createdAt);
    return editTime.inMinutes > 1;
  }

  @override
  List<Object?> get props => [
    id,
    entryId,
    authorId,
    content,
    createdAt,
    updatedAt,
    author,
    isEdited,
  ];
}
