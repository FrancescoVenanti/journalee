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
      // Use the service method that already works
      final entriesData = await _supabaseService.getJournalEntries('');

      // Find the entry by ID (mock implementation for now)
      // In a real implementation, you'd create a specific service method
      final mockEntry = EntryModel(
        id: entryId,
        journalId: 'journal-1',
        authorId: 'author-1',
        title: 'Sample Entry',
        content: {'ops': []},
        plainText: 'This is a sample entry content.',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
      );

      return mockEntry;
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
      // For now, just return success - implement actual deletion in service later
      await Future.delayed(const Duration(milliseconds: 500));
      // TODO: Implement proper deletion when service method is available
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
      // For now, just return success - implement actual deletion in service later
      await Future.delayed(const Duration(milliseconds: 500));
      // TODO: Implement proper deletion when service method is available
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
      // For now, return mock data - implement actual search when service supports it
      final mockEntries = <EntryModel>[];

      for (int i = 0; i < 3; i++) {
        if (query.toLowerCase().contains('sample') ||
            query.toLowerCase().contains('test')) {
          mockEntries.add(EntryModel(
            id: 'entry-$i',
            journalId: journalId ?? 'journal-1',
            authorId: 'author-1',
            title: 'Search Result $i',
            content: {'ops': []},
            plainText: 'This entry contains the search term: $query',
            createdAt: DateTime.now().subtract(Duration(days: i)),
            updatedAt: DateTime.now().subtract(Duration(days: i)),
          ));
        }
      }

      return mockEntries;
    } catch (e) {
      throw RepositoryException('Failed to search entries: ${e.toString()}');
    }
  }

  Future<List<EntryModel>> getRecentEntries({
    int limit = 10,
    String? journalId,
  }) async {
    try {
      // Return mock recent entries
      final mockEntries = <EntryModel>[];

      for (int i = 0; i < limit && i < 5; i++) {
        mockEntries.add(EntryModel(
          id: 'recent-entry-$i',
          journalId: journalId ?? 'journal-1',
          authorId: 'author-1',
          title: 'Recent Entry ${i + 1}',
          content: {'ops': []},
          plainText:
              'This is a recent entry from ${DateTime.now().subtract(Duration(hours: i)).toString()}',
          createdAt: DateTime.now().subtract(Duration(hours: i)),
          updatedAt: DateTime.now().subtract(Duration(hours: i)),
        ));
      }

      return mockEntries;
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
      // Return mock entries within date range
      final mockEntries = <EntryModel>[];
      final daysDiff = endDate.difference(startDate).inDays;

      for (int i = 0; i <= daysDiff && i < 10; i++) {
        final entryDate = startDate.add(Duration(days: i));
        if (entryDate.isBefore(endDate) ||
            entryDate.isAtSameMomentAs(endDate)) {
          mockEntries.add(EntryModel(
            id: 'date-entry-$i',
            journalId: journalId ?? 'journal-1',
            authorId: 'author-1',
            title: 'Entry from ${entryDate.day}/${entryDate.month}',
            content: {'ops': []},
            plainText: 'This entry was created on ${entryDate.toString()}',
            createdAt: entryDate,
            updatedAt: entryDate,
          ));
        }
      }

      return mockEntries;
    } catch (e) {
      throw RepositoryException(
          'Failed to load entries by date range: ${e.toString()}');
    }
  }

  Future<int> getEntryCount({String? journalId, String? authorId}) async {
    try {
      // Return mock count - implement actual counting when service supports it
      int count = 5; // Default mock count

      if (journalId != null) {
        count = 3; // Mock count for specific journal
      }

      if (authorId != null) {
        count = 7; // Mock count for specific author
      }

      return count;
    } catch (e) {
      throw RepositoryException('Failed to get entry count: ${e.toString()}');
    }
  }

  Future<bool> hasUserAccessToEntry(String entryId) async {
    final userId = _supabaseService.currentUserId;
    if (userId == null) return false;

    try {
      // For now, always return true for authenticated users
      // TODO: Implement proper access checking when service supports it
      return true;
    } catch (e) {
      return false;
    }
  }
}
