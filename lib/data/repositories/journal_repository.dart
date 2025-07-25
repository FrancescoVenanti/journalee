import '../models/journal_model.dart';
import '../services/supabase_service.dart';
import '../../core/exceptions/app_exceptions.dart';

class JournalRepository {
  final SupabaseService _supabaseService;

  JournalRepository({SupabaseService? supabaseService})
      : _supabaseService = supabaseService ?? SupabaseService.instance;

  Future<List<JournalModel>> getUserJournals() async {
    final userId = _supabaseService.currentUserId;
    if (userId == null) {
      throw const AppAuthException('User not authenticated');
    }

    try {
      final journalsData = await _supabaseService.getUserJournals(userId);
      return journalsData.map((data) => JournalModel.fromJson(data)).toList();
    } catch (e) {
      throw RepositoryException('Failed to load journals: ${e.toString()}');
    }
  }

  Future<JournalModel> createJournal({
    required String title,
    String? description,
    required bool isShared,
  }) async {
    final userId = _supabaseService.currentUserId;
    if (userId == null) {
      throw const AppAuthException('User not authenticated');
    }

    try {
      final journalData = await _supabaseService.createJournal(
        title: title,
        description: description,
        isShared: isShared,
        createdBy: userId,
      );

      // If it's a shared journal, add the creator as a member with owner role
      if (isShared) {
        await _supabaseService.addJournalMember(
          journalId: journalData['id'],
          userId: userId,
          role: 'owner',
        );
      }

      // Create activity
      await _supabaseService.createActivity(
        userId: userId,
        journalId: journalData['id'],
        activityType: 'journal_created',
        metadata: {'title': title},
      );

      return JournalModel.fromJson(journalData);
    } catch (e) {
      throw RepositoryException('Failed to create journal: ${e.toString()}');
    }
  }

  Future<JournalModel> getJournalById(String journalId) async {
    try {
      final journalData = await _supabaseService.from('journals').select('''
            *,
            creator:created_by(id, email, full_name, avatar_url),
            members:journal_members(
              id, user_id, role, joined_at,
              user:user_id(id, email, full_name, avatar_url)
            )
          ''').eq('id', journalId).single();

      return JournalModel.fromJson(journalData);
    } catch (e) {
      throw RepositoryException('Failed to load journal: ${e.toString()}');
    }
  }

  Future<JournalModel> updateJournal({
    required String journalId,
    String? title,
    String? description,
  }) async {
    final userId = _supabaseService.currentUserId;
    if (userId == null) {
      throw const AppAuthException('User not authenticated');
    }

    try {
      final updateData = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (title != null) updateData['title'] = title;
      if (description != null) updateData['description'] = description;

      await _supabaseService
          .from('journals')
          .update(updateData)
          .eq('id', journalId);

      return await getJournalById(journalId);
    } catch (e) {
      throw RepositoryException('Failed to update journal: ${e.toString()}');
    }
  }

  Future<void> deleteJournal(String journalId) async {
    final userId = _supabaseService.currentUserId;
    if (userId == null) {
      throw const AppAuthException('User not authenticated');
    }

    try {
      await _supabaseService
          .from('journals')
          .delete()
          .eq('id', journalId)
          .eq('created_by', userId); // Ensure only owner can delete
    } catch (e) {
      throw RepositoryException('Failed to delete journal: ${e.toString()}');
    }
  }

  Future<void> addMemberToJournal({
    required String journalId,
    required String userEmail,
    String role = 'member',
  }) async {
    final currentUserId = _supabaseService.currentUserId;
    if (currentUserId == null) {
      throw const AppAuthException('User not authenticated');
    }

    try {
      // First, find the user by email
      final userData = await _supabaseService
          .from('profiles')
          .select('id')
          .eq('email', userEmail)
          .maybeSingle();

      if (userData == null) {
        throw RepositoryException('User with email $userEmail not found');
      }

      final userId = userData['id'] as String;

      // Check if user is already a member
      final existingMember = await _supabaseService
          .from('journal_members')
          .select()
          .eq('journal_id', journalId)
          .eq('user_id', userId)
          .maybeSingle();

      if (existingMember != null) {
        throw RepositoryException('User is already a member of this journal');
      }

      // Add the member
      await _supabaseService.addJournalMember(
        journalId: journalId,
        userId: userId,
        role: role,
      );

      // Create activity
      await _supabaseService.createActivity(
        userId: currentUserId,
        journalId: journalId,
        activityType: 'member_added',
        metadata: {'added_user_email': userEmail},
      );
    } catch (e) {
      if (e is RepositoryException) rethrow;
      throw RepositoryException('Failed to add member: ${e.toString()}');
    }
  }

  Future<void> removeMemberFromJournal({
    required String journalId,
    required String userId,
  }) async {
    final currentUserId = _supabaseService.currentUserId;
    if (currentUserId == null) {
      throw const AppAuthException('User not authenticated');
    }

    try {
      await _supabaseService
          .from('journal_members')
          .delete()
          .eq('journal_id', journalId)
          .eq('user_id', userId);
    } catch (e) {
      throw RepositoryException('Failed to remove member: ${e.toString()}');
    }
  }

  Future<void> updateMemberRole({
    required String journalId,
    required String userId,
    required String role,
  }) async {
    final currentUserId = _supabaseService.currentUserId;
    if (currentUserId == null) {
      throw const AppAuthException('User not authenticated');
    }

    try {
      await _supabaseService
          .from('journal_members')
          .update({'role': role})
          .eq('journal_id', journalId)
          .eq('user_id', userId);
    } catch (e) {
      throw RepositoryException(
          'Failed to update member role: ${e.toString()}');
    }
  }

  Future<List<JournalModel>> getSharedJournals() async {
    final journals = await getUserJournals();
    return journals.where((journal) => journal.isShared).toList();
  }

  Future<List<JournalModel>> getPersonalJournals() async {
    final journals = await getUserJournals();
    return journals.where((journal) => !journal.isShared).toList();
  }

  Future<bool> isUserMemberOfJournal(String journalId, String userId) async {
    try {
      final member = await _supabaseService
          .from('journal_members')
          .select()
          .eq('journal_id', journalId)
          .eq('user_id', userId)
          .maybeSingle();

      return member != null;
    } catch (e) {
      return false;
    }
  }

  Future<JournalMemberRole?> getUserRoleInJournal(
      String journalId, String userId) async {
    try {
      // Check if user is the owner
      final journal = await _supabaseService
          .from('journals')
          .select('created_by')
          .eq('id', journalId)
          .single();

      if (journal['created_by'] == userId) {
        return JournalMemberRole.owner;
      }

      // Check member role
      final member = await _supabaseService
          .from('journal_members')
          .select('role')
          .eq('journal_id', journalId)
          .eq('user_id', userId)
          .maybeSingle();

      if (member != null) {
        return JournalMemberRole.fromString(member['role']);
      }

      return null;
    } catch (e) {
      return null;
    }
  }
}
