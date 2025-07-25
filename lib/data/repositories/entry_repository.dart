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
      print('📖 [EntryRepository] Getting entries for journal: $journalId');

      final entriesData = await _supabaseService.getJournalEntries(journalId);

      print('📊 [EntryRepository] Found ${entriesData.length} entries');

      final entries =
          entriesData.map((data) => EntryModel.fromJson(data)).toList();

      print(
          '✅ [EntryRepository] Successfully mapped ${entries.length} entries');

      return entries;
    } catch (e, stackTrace) {
      print('❌ [EntryRepository] Failed to load entries: $e');
      print('📍 [EntryRepository] Stack trace: $stackTrace');
      throw RepositoryException('Failed to load entries: ${e.toString()}');
    }
  }

  Future<EntryModel> getEntryById(String entryId) async {
    try {
      print('📖 [EntryRepository] Getting entry by ID: $entryId');

      // For now, return a mock entry since we don't have a specific service method
      // TODO: Implement proper getEntryById in SupabaseService
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

      print('✅ [EntryRepository] Successfully returned mock entry');
      return mockEntry;
    } catch (e, stackTrace) {
      print('❌ [EntryRepository] Failed to load entry: $e');
      print('📍 [EntryRepository] Stack trace: $stackTrace');
      throw RepositoryException('Failed to load entry: ${e.toString()}');
    }
  }

  Future<EntryModel> createEntry({
    required String journalId,
    String? title,
    required Map<String, dynamic> content,
    required String plainText,
  }) async {
    print('📝 [EntryRepository] Creating entry in journal: $journalId');
    print('📝 [EntryRepository] Title: ${title ?? 'No title'}');
    print(
        '📝 [EntryRepository] Content length: ${plainText.length} characters');

    final userId = _supabaseService.currentUserId;
    if (userId == null) {
      print('❌ [EntryRepository] User not authenticated');
      throw const AppAuthException('User not authenticated');
    }

    print('👤 [EntryRepository] Current user ID: $userId');

    try {
      print('🚀 [EntryRepository] Calling SupabaseService.createEntry...');

      final entryData = await _supabaseService.createEntry(
        journalId: journalId,
        authorId: userId,
        title: title,
        content: content,
        plainText: plainText,
      );

      print(
          '✅ [EntryRepository] Entry created successfully: ${entryData['id']}');

      // Create activity
      print('📈 [EntryRepository] Creating activity...');
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

      print('✅ [EntryRepository] Activity created successfully');

      final entry = EntryModel.fromJson(entryData);
      print('✅ [EntryRepository] Entry model created successfully');

      return entry;
    } catch (e, stackTrace) {
      print('❌ [EntryRepository] Failed to create entry: $e');
      print('📍 [EntryRepository] Stack trace: $stackTrace');

      if (e is PostgrestException) {
        print('🔍 [EntryRepository] Postgres error details:');
        print('   - Code: ${e.code}');
        print('   - Message: ${e.message}');
        print('   - Details: ${e.details}');
        print('   - Hint: ${e.hint}');
      }

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
      print('📝 [EntryRepository] Updating entry: $entryId');

      await _supabaseService.updateEntry(
        entryId: entryId,
        title: title,
        content: content,
        plainText: plainText,
      );

      print('✅ [EntryRepository] Entry updated successfully');

      return await getEntryById(entryId);
    } catch (e, stackTrace) {
      print('❌ [EntryRepository] Failed to update entry: $e');
      print('📍 [EntryRepository] Stack trace: $stackTrace');
      throw RepositoryException('Failed to update entry: ${e.toString()}');
    }
  }

  Future<void> deleteEntry(String entryId) async {
    final userId = _supabaseService.currentUserId;
    if (userId == null) {
      throw const AppAuthException('User not authenticated');
    }

    try {
      print('🗑️ [EntryRepository] Deleting entry: $entryId');

      // For now, just return success - implement actual deletion in service later
      await Future.delayed(const Duration(milliseconds: 500));

      print('✅ [EntryRepository] Entry deletion completed (mock)');

      // TODO: Implement proper deletion when service method is available
    } catch (e, stackTrace) {
      print('❌ [EntryRepository] Failed to delete entry: $e');
      print('📍 [EntryRepository] Stack trace: $stackTrace');
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
      print('💬 [EntryRepository] Adding comment to entry: $entryId');

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

      print('✅ [EntryRepository] Comment added successfully');

      return CommentModel.fromJson(commentData);
    } catch (e, stackTrace) {
      print('❌ [EntryRepository] Failed to add comment: $e');
      print('📍 [EntryRepository] Stack trace: $stackTrace');
      throw RepositoryException('Failed to add comment: ${e.toString()}');
    }
  }

  Future<void> deleteComment(String commentId) async {
    final userId = _supabaseService.currentUserId;
    if (userId == null) {
      throw const AppAuthException('User not authenticated');
    }

    try {
      print('🗑️ [EntryRepository] Deleting comment: $commentId');

      // For now, just return success - implement actual deletion in service later
      await Future.delayed(const Duration(milliseconds: 500));

      print('✅ [EntryRepository] Comment deletion completed (mock)');

      // TODO: Implement proper deletion when service method is available
    } catch (e, stackTrace) {
      print('❌ [EntryRepository] Failed to delete comment: $e');
      print('📍 [EntryRepository] Stack trace: $stackTrace');
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
      print('😊 [EntryRepository] Toggling reaction on entry: $entryId');

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

        print('✅ [EntryRepository] Reaction added successfully');
        return ReactionModel.fromJson(reactionData);
      }

      print('✅ [EntryRepository] Reaction removed successfully');
      return null; // Reaction was removed
    } catch (e, stackTrace) {
      print('❌ [EntryRepository] Failed to toggle reaction: $e');
      print('📍 [EntryRepository] Stack trace: $stackTrace');
      throw RepositoryException('Failed to toggle reaction: ${e.toString()}');
    }
  }

  Future<List<EntryModel>> searchEntries({
    required String query,
    String? journalId,
    int limit = 20,
  }) async {
    try {
      print('🔍 [EntryRepository] Searching entries with query: "$query"');

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

      print(
          '✅ [EntryRepository] Search completed, found ${mockEntries.length} results');
      return mockEntries;
    } catch (e, stackTrace) {
      print('❌ [EntryRepository] Failed to search entries: $e');
      print('📍 [EntryRepository] Stack trace: $stackTrace');
      throw RepositoryException('Failed to search entries: ${e.toString()}');
    }
  }

  Future<List<EntryModel>> getRecentEntries({
    int limit = 10,
    String? journalId,
  }) async {
    try {
      print('📖 [EntryRepository] Getting recent entries (limit: $limit)');

      // For now, return mock recent entries
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

      print(
          '✅ [EntryRepository] Retrieved ${mockEntries.length} recent entries');
      return mockEntries;
    } catch (e, stackTrace) {
      print('❌ [EntryRepository] Failed to load recent entries: $e');
      print('📍 [EntryRepository] Stack trace: $stackTrace');
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
      print(
          '📅 [EntryRepository] Getting entries from ${startDate.toString()} to ${endDate.toString()}');

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

      print(
          '✅ [EntryRepository] Retrieved ${mockEntries.length} entries by date range');
      return mockEntries;
    } catch (e, stackTrace) {
      print('❌ [EntryRepository] Failed to load entries by date range: $e');
      print('📍 [EntryRepository] Stack trace: $stackTrace');
      throw RepositoryException(
          'Failed to load entries by date range: ${e.toString()}');
    }
  }

  Future<int> getEntryCount({String? journalId, String? authorId}) async {
    try {
      print(
          '📊 [EntryRepository] Getting entry count for journal: $journalId, author: $authorId');

      // Return mock count - implement actual counting when service supports it
      int count = 5; // Default mock count

      if (journalId != null) {
        count = 3; // Mock count for specific journal
      }

      if (authorId != null) {
        count = 7; // Mock count for specific author
      }

      print('✅ [EntryRepository] Entry count: $count');
      return count;
    } catch (e, stackTrace) {
      print('❌ [EntryRepository] Failed to get entry count: $e');
      print('📍 [EntryRepository] Stack trace: $stackTrace');
      throw RepositoryException('Failed to get entry count: ${e.toString()}');
    }
  }

  Future<bool> hasUserAccessToEntry(String entryId) async {
    final userId = _supabaseService.currentUserId;
    if (userId == null) return false;

    try {
      print('🔒 [EntryRepository] Checking user access to entry: $entryId');

      // For now, always return true for authenticated users
      // TODO: Implement proper access checking when service supports it
      print('✅ [EntryRepository] User has access to entry');
      return true;
    } catch (e) {
      print('❌ [EntryRepository] Failed to check user access: $e');
      return false;
    }
  }
}
