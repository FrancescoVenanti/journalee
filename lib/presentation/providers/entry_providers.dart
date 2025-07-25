import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/entry_model.dart';
import '../../data/models/comment_model.dart';
import '../../data/models/reaction_model.dart';
import '../../data/repositories/entry_repository.dart';
import '../../core/exceptions/app_exceptions.dart';

// Entry Repository Provider
final entryRepositoryProvider = Provider<EntryRepository>((ref) {
  return EntryRepository();
});

// Journal Entries Provider - REAL DATA ONLY
final journalEntriesProvider =
    FutureProvider.family<List<EntryModel>, String>((ref, journalId) async {
  final repository = ref.watch(entryRepositoryProvider);
  return repository.getJournalEntries(journalId);
});

// Single Entry Provider - REAL DATA ONLY
final entryProvider =
    FutureProvider.family<EntryModel, String>((ref, entryId) async {
  final repository = ref.watch(entryRepositoryProvider);
  return repository.getEntryById(entryId);
});

// Recent Entries Provider - REAL DATA ONLY (NO MOCK DATA)
final recentEntriesProvider = FutureProvider<List<EntryModel>>((ref) async {
  try {
    final repository = ref.watch(entryRepositoryProvider);

    // Get ALL user's journals first
    final userJournals = await ref.watch(userJournalsProvider.future);

    if (userJournals.isEmpty) {
      print(
          '📖 [RecentEntriesProvider] No journals found, returning empty list');
      return [];
    }

    // Get entries from all journals and combine them
    final allEntries = <EntryModel>[];

    for (final journal in userJournals) {
      try {
        final journalEntries = await repository.getJournalEntries(journal.id);
        allEntries.addAll(journalEntries);
      } catch (e) {
        print(
            '⚠️ [RecentEntriesProvider] Failed to get entries for journal ${journal.id}: $e');
        // Continue with other journals even if one fails
      }
    }

    // Sort by creation date (newest first) and take the 10 most recent
    allEntries.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final recentEntries = allEntries.take(10).toList();

    print(
        '📖 [RecentEntriesProvider] Found ${recentEntries.length} recent entries');
    return recentEntries;
  } catch (e, stackTrace) {
    print('❌ [RecentEntriesProvider] Error getting recent entries: $e');
    print('📍 [RecentEntriesProvider] Stack trace: $stackTrace');
    return []; // Return empty list instead of fake data
  }
});

// Entry Controller
final entryControllerProvider =
    StateNotifierProvider<EntryController, EntryState>((ref) {
  final repository = ref.watch(entryRepositoryProvider);
  return EntryController(repository, ref);
});

class EntryController extends StateNotifier<EntryState> {
  final EntryRepository _repository;
  final Ref _ref;

  EntryController(this._repository, this._ref)
      : super(const EntryState.initial());

  Future<void> createEntry({
    required String journalId,
    String? title,
    required Map<String, dynamic> content,
    required String plainText,
  }) async {
    state = const EntryState.loading();

    try {
      final entry = await _repository.createEntry(
        journalId: journalId,
        title: title,
        content: content,
        plainText: plainText,
      );

      state = EntryState.success(entry);

      // Invalidate related providers to refresh the UI
      _ref.invalidate(journalEntriesProvider(journalId));
      _ref.invalidate(recentEntriesProvider);
      _ref.invalidate(userJournalsProvider); // Refresh to update entry counts
    } on RepositoryException catch (e) {
      state = EntryState.error(e.message);
    } catch (e) {
      state = const EntryState.error('Failed to create entry');
    }
  }

  Future<void> updateEntry({
    required String entryId,
    String? title,
    Map<String, dynamic>? content,
    String? plainText,
  }) async {
    state = const EntryState.loading();

    try {
      final entry = await _repository.updateEntry(
        entryId: entryId,
        title: title,
        content: content,
        plainText: plainText,
      );

      state = EntryState.success(entry);

      // Invalidate related providers
      _ref.invalidate(entryProvider(entryId));
      _ref.invalidate(recentEntriesProvider);
    } on RepositoryException catch (e) {
      state = EntryState.error(e.message);
    } catch (e) {
      state = const EntryState.error('Failed to update entry');
    }
  }

  Future<void> deleteEntry(String entryId) async {
    state = const EntryState.loading();

    try {
      await _repository.deleteEntry(entryId);
      state = const EntryState.deleted();

      // Invalidate related providers
      _ref.invalidate(entryProvider(entryId));
      _ref.invalidate(recentEntriesProvider);
    } on RepositoryException catch (e) {
      state = EntryState.error(e.message);
    } catch (e) {
      state = const EntryState.error('Failed to delete entry');
    }
  }

  Future<void> addComment({
    required String entryId,
    required String content,
  }) async {
    state = const EntryState.loading();

    try {
      final comment = await _repository.addComment(
        entryId: entryId,
        content: content,
      );

      state = EntryState.commentAdded(comment);

      // Refresh entry data
      _ref.invalidate(entryProvider(entryId));
    } on RepositoryException catch (e) {
      state = EntryState.error(e.message);
    } catch (e) {
      state = const EntryState.error('Failed to add comment');
    }
  }

  Future<void> toggleReaction({
    required String entryId,
    required String emoji,
  }) async {
    try {
      final reaction = await _repository.toggleReaction(
        entryId: entryId,
        emoji: emoji,
      );

      if (reaction != null) {
        state = EntryState.reactionAdded(reaction);
      } else {
        state = const EntryState.reactionRemoved();
      }

      // Refresh entry data
      _ref.invalidate(entryProvider(entryId));
    } on RepositoryException catch (e) {
      state = EntryState.error(e.message);
    } catch (e) {
      state = const EntryState.error('Failed to toggle reaction');
    }
  }

  void clearState() {
    state = const EntryState.initial();
  }
}

// Entry State Classes
sealed class EntryState {
  const EntryState();

  const factory EntryState.initial() = EntryStateInitial;
  const factory EntryState.loading() = EntryStateLoading;
  const factory EntryState.success(EntryModel entry) = EntryStateSuccess;
  const factory EntryState.error(String message) = EntryStateError;
  const factory EntryState.deleted() = EntryStateDeleted;
  const factory EntryState.commentAdded(CommentModel comment) =
      EntryStateCommentAdded;
  const factory EntryState.reactionAdded(ReactionModel reaction) =
      EntryStateReactionAdded;
  const factory EntryState.reactionRemoved() = EntryStateReactionRemoved;
}

class EntryStateInitial extends EntryState {
  const EntryStateInitial();
}

class EntryStateLoading extends EntryState {
  const EntryStateLoading();
}

class EntryStateSuccess extends EntryState {
  final EntryModel entry;
  const EntryStateSuccess(this.entry);
}

class EntryStateError extends EntryState {
  final String message;
  const EntryStateError(this.message);
}

class EntryStateDeleted extends EntryState {
  const EntryStateDeleted();
}

class EntryStateCommentAdded extends EntryState {
  final CommentModel comment;
  const EntryStateCommentAdded(this.comment);
}

class EntryStateReactionAdded extends EntryState {
  final ReactionModel reaction;
  const EntryStateReactionAdded(this.reaction);
}

class EntryStateReactionRemoved extends EntryState {
  const EntryStateReactionRemoved();
}

// Helper providers
final isLoadingEntryProvider = Provider<bool>((ref) {
  final entryState = ref.watch(entryControllerProvider);
  return entryState is EntryStateLoading;
});

// Search entries provider - REAL DATA ONLY
final searchEntriesProvider =
    FutureProvider.family<List<EntryModel>, String>((ref, query) async {
  if (query.trim().isEmpty) return [];

  try {
    final repository = ref.watch(entryRepositoryProvider);
    return repository.searchEntries(query: query);
  } catch (e) {
    print('❌ [SearchEntriesProvider] Error searching entries: $e');
    return []; // Return empty list instead of fake data
  }
});

// Entry count provider - REAL DATA ONLY
final entryCountProvider =
    FutureProvider.family<int, String?>((ref, journalId) async {
  try {
    final repository = ref.watch(entryRepositoryProvider);
    return repository.getEntryCount(journalId: journalId);
  } catch (e) {
    print('❌ [EntryCountProvider] Error getting entry count: $e');
    return 0; // Return 0 instead of fake data
  }
});
