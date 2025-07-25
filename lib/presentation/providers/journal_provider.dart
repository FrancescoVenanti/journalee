import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:journalee/presentation/providers/auth_provider.dart';
import '../../data/models/journal_model.dart';
import '../../data/repositories/journal_repository.dart';
import '../../core/exceptions/app_exceptions.dart';

// Journal Repository Provider
final journalRepositoryProvider = Provider<JournalRepository>((ref) {
  return JournalRepository();
});

// User Journals Provider
final userJournalsProvider = FutureProvider<List<JournalModel>>((ref) async {
  final repository = ref.watch(journalRepositoryProvider);
  return repository.getUserJournals();
});

// Shared Journals Provider
final sharedJournalsProvider = FutureProvider<List<JournalModel>>((ref) async {
  final repository = ref.watch(journalRepositoryProvider);
  return repository.getSharedJournals();
});

// Personal Journals Provider
final personalJournalsProvider =
    FutureProvider<List<JournalModel>>((ref) async {
  final repository = ref.watch(journalRepositoryProvider);
  return repository.getPersonalJournals();
});

// Single Journal Provider
final journalProvider =
    FutureProvider.family<JournalModel, String>((ref, journalId) async {
  final repository = ref.watch(journalRepositoryProvider);
  return repository.getJournalById(journalId);
});

// Journal Controller
final journalControllerProvider =
    StateNotifierProvider<JournalController, JournalState>((ref) {
  final repository = ref.watch(journalRepositoryProvider);
  return JournalController(repository, ref);
});

class JournalController extends StateNotifier<JournalState> {
  final JournalRepository _repository;
  final Ref _ref;

  JournalController(this._repository, this._ref)
      : super(const JournalState.initial());

  Future<void> createJournal({
    required String title,
    String? description,
    required bool isShared,
  }) async {
    state = const JournalState.loading();

    try {
      final journal = await _repository.createJournal(
        title: title,
        description: description,
        isShared: isShared,
      );

      state = JournalState.success(journal);

      // Invalidate journals list to refresh
      _ref.invalidate(userJournalsProvider);
      _ref.invalidate(sharedJournalsProvider);
      _ref.invalidate(personalJournalsProvider);
    } on RepositoryException catch (e) {
      state = JournalState.error(e.message);
    } catch (e) {
      state = const JournalState.error('Failed to create journal');
    }
  }

  Future<void> updateJournal({
    required String journalId,
    String? title,
    String? description,
  }) async {
    state = const JournalState.loading();

    try {
      final journal = await _repository.updateJournal(
        journalId: journalId,
        title: title,
        description: description,
      );

      state = JournalState.success(journal);

      // Invalidate related providers
      _ref.invalidate(userJournalsProvider);
      _ref.invalidate(journalProvider(journalId));
    } on RepositoryException catch (e) {
      state = JournalState.error(e.message);
    } catch (e) {
      state = const JournalState.error('Failed to update journal');
    }
  }

  Future<void> deleteJournal(String journalId) async {
    state = const JournalState.loading();

    try {
      await _repository.deleteJournal(journalId);
      state = const JournalState.deleted();

      // Invalidate journals list
      _ref.invalidate(userJournalsProvider);
      _ref.invalidate(sharedJournalsProvider);
      _ref.invalidate(personalJournalsProvider);
    } on RepositoryException catch (e) {
      state = JournalState.error(e.message);
    } catch (e) {
      state = const JournalState.error('Failed to delete journal');
    }
  }

  Future<void> addMember({
    required String journalId,
    required String userEmail,
    String role = 'member',
  }) async {
    state = const JournalState.loading();

    try {
      await _repository.addMemberToJournal(
        journalId: journalId,
        userEmail: userEmail,
        role: role,
      );

      state = const JournalState.memberAdded();

      // Refresh journal data
      _ref.invalidate(journalProvider(journalId));
    } on RepositoryException catch (e) {
      state = JournalState.error(e.message);
    } catch (e) {
      state = const JournalState.error('Failed to add member');
    }
  }

  Future<void> removeMember({
    required String journalId,
    required String userId,
  }) async {
    state = const JournalState.loading();

    try {
      await _repository.removeMemberFromJournal(
        journalId: journalId,
        userId: userId,
      );

      state = const JournalState.memberRemoved();

      // Refresh journal data
      _ref.invalidate(journalProvider(journalId));
    } on RepositoryException catch (e) {
      state = JournalState.error(e.message);
    } catch (e) {
      state = const JournalState.error('Failed to remove member');
    }
  }

  Future<void> updateMemberRole({
    required String journalId,
    required String userId,
    required String role,
  }) async {
    state = const JournalState.loading();

    try {
      await _repository.updateMemberRole(
        journalId: journalId,
        userId: userId,
        role: role,
      );

      state = const JournalState.memberRoleUpdated();

      // Refresh journal data
      _ref.invalidate(journalProvider(journalId));
    } on RepositoryException catch (e) {
      state = JournalState.error(e.message);
    } catch (e) {
      state = const JournalState.error('Failed to update member role');
    }
  }

  void clearState() {
    state = const JournalState.initial();
  }
}

// Journal State Classes
sealed class JournalState {
  const JournalState();

  const factory JournalState.initial() = JournalStateInitial;
  const factory JournalState.loading() = JournalStateLoading;
  const factory JournalState.success(JournalModel journal) =
      JournalStateSuccess;
  const factory JournalState.error(String message) = JournalStateError;
  const factory JournalState.deleted() = JournalStateDeleted;
  const factory JournalState.memberAdded() = JournalStateMemberAdded;
  const factory JournalState.memberRemoved() = JournalStateMemberRemoved;
  const factory JournalState.memberRoleUpdated() =
      JournalStateMemberRoleUpdated;
}

class JournalStateInitial extends JournalState {
  const JournalStateInitial();
}

class JournalStateLoading extends JournalState {
  const JournalStateLoading();
}

class JournalStateSuccess extends JournalState {
  final JournalModel journal;
  const JournalStateSuccess(this.journal);
}

class JournalStateError extends JournalState {
  final String message;
  const JournalStateError(this.message);
}

class JournalStateDeleted extends JournalState {
  const JournalStateDeleted();
}

class JournalStateMemberAdded extends JournalState {
  const JournalStateMemberAdded();
}

class JournalStateMemberRemoved extends JournalState {
  const JournalStateMemberRemoved();
}

class JournalStateMemberRoleUpdated extends JournalState {
  const JournalStateMemberRoleUpdated();
}

// Helper providers
final isLoadingJournalProvider = Provider<bool>((ref) {
  final journalState = ref.watch(journalControllerProvider);
  return journalState is JournalStateLoading;
});

// User role in journal provider
final userRoleInJournalProvider =
    FutureProvider.family<JournalMemberRole?, String>((ref, journalId) async {
  final repository = ref.watch(journalRepositoryProvider);
  final authState = ref.watch(authStateProvider);

  return authState.when(
    data: (user) async {
      if (user == null) return null;
      return repository.getUserRoleInJournal(journalId, user.id);
    },
    loading: () => null,
    error: (_, __) => null,
  );
});
