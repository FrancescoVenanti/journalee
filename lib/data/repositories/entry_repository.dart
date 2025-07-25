import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/entry_model.dart';
import '../models/comment_model.dart';
import '../models/reaction_model.dart';
import '../services/supabase_service.dart';
import '../../core/exceptions/app_exceptions.dart';

class EntryRepository {
  final SupabaseService _supabaseService;

  EntryRepository({SupabaseService? supabaseService})
      : _supabaseService = supabaseService ?? SupabaseService.instance;

  Future<List<EntryModel>> getJournalEntries(String journalId) async {
    try {
      final entriesData = await _supabaseService.getJournalEntries(journalId);
      return entriesData.map((data) => EntryModel.fromJson(data)).toList();
    } catch (e) {
      throw RepositoryException('Failed to load entries: ${e.toString()}');
    }
  }

  Future<EntryModel> getEntryById(String entryId) async {
    try {
      final response = await _supabaseService.client.from('entries').select('''
            *,
            author:author_id(id, email, full_name, avatar_url),
            comments(
              id, content, created_at, updated_at,
              author:author_id(id, email, full_name, avatar_url)
            ),
            reactions(
              id, emoji, created_at,
              user:user_id(id, email, full_name, avatar_url)
            )
          ''').eq('id', entryId).single();

      return EntryModel.fromJson(response);
    } catch (e) {
      throw RepositoryException('Failed to load entry: ${e.toString()}');
    }
  }

  Future<EntryModel> createEntry({
    required String journalId,
    String? title,
    required Map<String, dynamic> content,
    required String plainText,
  }) async {
    final userId = _supabaseService.currentUserId;
    if (userId == null) {
      throw const AppAuthException('User not authenticated');
    }

    try {
      final entryData = await _supabaseService.createEntry(
        journalId: journalId,
        authorId: userId,
        title: title,
        content: content,
        plainText: plainText,
      );

      // Create activity
      await _supabaseService.createActivity(
        userId: userId,
        journalId: journalId,
        entryId: entryData['id'],
        activityType: 'entry_created',
        metadata: {
          'title': title,
          'preview': plainText.length > 100
              ? '${plainText.substring(0, 100)}...'
              : plainText,
        },
      );

      return EntryModel.fromJson(entryData);
    } catch (e) {
      throw RepositoryException('Failed to create entry: ${e.toString()}');
    }
  }

  Future<EntryModel> updateEntry({
    required String entryId,
    String? title,
    Map<String, dynamic>? content,
    String? plainText,
  }) async {
    final userId = _supabaseService.currentUserId;
    if (userId == null) {
      throw const AppAuthException('User not authenticated');
    }

    try {
      await _supabaseService.updateEntry(
        entryId: entryId,
        title: title,
        content: content,
        plainText: plainText,
      );

      return await getEntryById(entryId);
    } catch (e) {
      throw RepositoryException('Failed to update entry: ${e.toString()}');
    }
  }

  Future<void> deleteEntry(String entryId) async {
    final userId = _supabaseService.currentUserId;
    if (userId == null) {
      throw const AppAuthException('User not authenticated');
    }

    try {
      await _supabaseService
          .from('entries')
          .delete()
          .eq('id', entryId)
          .eq('author_id', userId);
    } catch (e) {
      throw RepositoryException('Failed to delete entry: ${e.toString()}');
    }
  }

  Future<CommentModel> addComment({
    required String entryId,
    required String content,
  }) async {
    final userId = _supabaseService.currentUserId;
    if (userId == null) {
      throw const AppAuthException('User not authenticated');
    }

    try {
      final commentData = await _supabaseService.addComment(
        entryId: entryId,
        authorId: userId,
        content: content,
      );

      // Create activity
      await _supabaseService.createActivity(
        userId: userId,
        entryId: entryId,
        activityType: 'comment_added',
        metadata: {
          'comment_preview':
              content.length > 50 ? '${content.substring(0, 50)}...' : content,
        },
      );

      return CommentModel.fromJson(commentData);
    } catch (e) {
      throw RepositoryException('Failed to add comment: ${e.toString()}');
    }
  }

  Future<void> deleteComment(String commentId) async {
    final userId = _supabaseService.currentUserId;
    if (userId == null) {
      throw const AppAuthException('User not authenticated');
    }

    try {
      await _supabaseService
          .from('comments')
          .delete()
          .eq('id', commentId)
          .eq('author_id', userId);
    } catch (e) {
      throw RepositoryException('Failed to delete comment: ${e.toString()}');
    }
  }

  Future<ReactionModel?> toggleReaction({
    required String entryId,
    required String emoji,
  }) async {
    final userId = _supabaseService.currentUserId;
    if (userId == null) {
      throw const AppAuthException('User not authenticated');
    }

    try {
      final reactionData = await _supabaseService.toggleReaction(
        entryId: entryId,
        userId: userId,
        emoji: emoji,
      );

      if (reactionData != null) {
        // Create activity for new reaction
        await _supabaseService.createActivity(
          userId: userId,
          entryId: entryId,
          activityType: 'reaction_added',
          metadata: {'emoji': emoji},
        );

        return ReactionModel.fromJson(reactionData);
      }

      return null; // Reaction was removed
    } catch (e) {
      throw RepositoryException('Failed to toggle reaction: ${e.toString()}');
    }
  }

  Future<List<EntryModel>> searchEntries({
    required String query,
    String? journalId,
    int limit = 20,
  }) async {
    try {
      var queryBuilder = _supabaseService
          .from('entries')
          .select('''
            *,
            author:author_id(id, email, full_name, avatar_url)
          ''')
          .textSearch('plain_text', query)
          .limit(limit)
          .order('created_at', ascending: false);

      if (journalId != null) {
        queryBuilder = queryBuilder.eq('journal_id', journalId);
      }

      final entriesData = await queryBuilder;
      return entriesData
          .map<EntryModel>((data) => EntryModel.fromJson(data))
          .toList();
    } catch (e) {
      throw RepositoryException('Failed to search entries: ${e.toString()}');
    }
  }

  Future<List<EntryModel>> getRecentEntries({
    int limit = 10,
    String? journalId,
  }) async {
    try {
      var queryBuilder = _supabaseService.from('entries').select('''
            *,
            author:author_id(id, email, full_name, avatar_url),
            journal:journal_id(id, title, is_shared)
          ''').limit(limit).order('created_at', ascending: false);

      if (journalId != null) {
        queryBuilder = queryBuilder.eq('journal_id', journalId);
      }

      final entriesData = await queryBuilder;
      return entriesData
          .map<EntryModel>((data) => EntryModel.fromJson(data))
          .toList();
    } catch (e) {
      throw RepositoryException(
          'Failed to load recent entries: ${e.toString()}');
    }
  }

  Future<List<EntryModel>> getEntriesByDateRange({
    required DateTime startDate,
    required DateTime endDate,
    String? journalId,
  }) async {
    try {
      var queryBuilder = _supabaseService
          .from('entries')
          .select('''
            *,
            author:author_id(id, email, full_name, avatar_url)
          ''')
          .gte('created_at', startDate.toIso8601String())
          .lte('created_at', endDate.toIso8601String())
          .order('created_at', ascending: false);

      if (journalId != null) {
        queryBuilder = queryBuilder.eq('journal_id', journalId);
      }

      final entriesData = await queryBuilder;
      return entriesData
          .map<EntryModel>((data) => EntryModel.fromJson(data))
          .toList();
    } catch (e) {
      throw RepositoryException(
          'Failed to load entries by date range: ${e.toString()}');
    }
  }

  Future<int> getEntryCount({String? journalId, String? authorId}) async {
    try {
      // Use a simpler approach for counting
      var queryBuilder = _supabaseService.client.from('entries').select('id');

      if (journalId != null) {
        queryBuilder = queryBuilder.eq('journal_id', journalId);
      }

      if (authorId != null) {
        queryBuilder = queryBuilder.eq('author_id', authorId);
      }

      final result = await queryBuilder;
      return result.length;
    } catch (e) {
      throw RepositoryException('Failed to get entry count: ${e.toString()}');
    }
  }

  Future<bool> hasUserAccessToEntry(String entryId) async {
    final userId = _supabaseService.currentUserId;
    if (userId == null) return false;

    try {
      final entry = await _supabaseService.client
          .from('entries')
          .select('journal_id')
          .eq('id', entryId)
          .single();

      final journalId = entry['journal_id'] as String;

      // Check if user has access to the journal containing this entry
      final journal = await _supabaseService.client
          .from('journals')
          .select('created_by')
          .eq('id', journalId)
          .single();

      // User has access if they created the journal
      if (journal['created_by'] == userId) return true;

      // Or if they are a member of the journal
      final member = await _supabaseService.client
          .from('journal_members')
          .select('id')
          .eq('journal_id', journalId)
          .eq('user_id', userId)
          .maybeSingle();

      return member != null;
    } catch (e) {
      return false;
    }
  }
}
