import 'package:equatable/equatable.dart';
import 'user_model.dart';

class ReactionModel extends Equatable {
  final String id;
  final String entryId;
  final String userId;
  final String emoji;
  final DateTime createdAt;
  final UserModel? user;

  const ReactionModel({
    required this.id,
    required this.entryId,
    required this.userId,
    required this.emoji,
    required this.createdAt,
    this.user,
  });

  factory ReactionModel.fromJson(Map<String, dynamic> json) {
    return ReactionModel(
      id: json['id'] as String,
      entryId: json['entry_id'] as String,
      userId: json['user_id'] as String,
      emoji: json['emoji'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      user: json['user'] != null
          ? UserModel.fromJson(json['user'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'entry_id': entryId,
      'user_id': userId,
      'emoji': emoji,
      'created_at': createdAt.toIso8601String(),
    };
  }

  ReactionModel copyWith({
    String? id,
    String? entryId,
    String? userId,
    String? emoji,
    DateTime? createdAt,
    UserModel? user,
  }) {
    return ReactionModel(
      id: id ?? this.id,
      entryId: entryId ?? this.entryId,
      userId: userId ?? this.userId,
      emoji: emoji ?? this.emoji,
      createdAt: createdAt ?? this.createdAt,
      user: user ?? this.user,
    );
  }

  @override
  List<Object?> get props => [id, entryId, userId, emoji, createdAt, user];
}

// Common emoji reactions for journal entries
class EmojiReactions {
  static const List<String> common = [
    '❤️', // heart
    '👍', // thumbs up
    '😊', // smiling face
    '🙏', // folded hands
    '💪', // flexed biceps
    '🌟', // star
    '🎉', // party popper
    '😢', // crying face
    '🤗', // hugging face
    '💡', // light bulb
    '🔥', // fire
    '✨', // sparkles
  ];

  static String getDescription(String emoji) {
    const descriptions = {
      '❤️': 'Love',
      '👍': 'Like',
      '😊': 'Happy',
      '🙏': 'Grateful',
      '💪': 'Strong',
      '🌟': 'Amazing',
      '🎉': 'Celebrate',
      '😢': 'Sad',
      '🤗': 'Supportive',
      '💡': 'Insightful',
      '🔥': 'Inspiring',
      '✨': 'Beautiful',
    };
    return descriptions[emoji] ?? emoji;
  }
}
