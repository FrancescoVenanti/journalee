import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static SupabaseService? _instance;
  static SupabaseService get instance => _instance ??= SupabaseService._();

  SupabaseService._();

  late final SupabaseClient _client;

  SupabaseClient get client => _client;
  User? get currentUser => _client.auth.currentUser;
  String? get currentUserId => currentUser?.id;

  Future<void> initialize({
    required String url,
    required String anonKey,
  }) async {
    print('🚀 [SupabaseService] Initializing with URL: $url');

    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
    );
    _client = Supabase.instance.client;

    print('✅ [SupabaseService] Initialized successfully');
    print(
        '👤 [SupabaseService] Current user: ${currentUser?.email ?? 'Not authenticated'}');
  }

  // Auth Stream
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  // Authentication Methods
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    String? fullName,
  }) async {
    print('📝 [SupabaseService] Signing up user: $email');

    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: fullName != null ? {'full_name': fullName} : null,
    );

    print('✅ [SupabaseService] Sign up completed for: $email');
    return response;
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    print('🔐 [SupabaseService] Signing in user: $email');

    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    print('✅ [SupabaseService] Sign in completed for: $email');
    return response;
  }

  Future<void> signOut() async {
    print('🚪 [SupabaseService] Signing out user');
    await _client.auth.signOut();
    print('✅ [SupabaseService] Sign out completed');
  }

  Future<void> resetPassword(String email) async {
    print('🔄 [SupabaseService] Resetting password for: $email');
    await _client.auth.resetPasswordForEmail(email);
    print('✅ [SupabaseService] Password reset email sent');
  }

  // Database Query Helpers
  SupabaseQueryBuilder from(String table) => _client.from(table);

  // Real-time subscriptions
  RealtimeChannel channel(String name) => _client.channel(name);

  // Storage
  SupabaseStorageClient get storage => _client.storage;

  // User Profile Operations
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    print('👤 [SupabaseService] Getting user profile: $userId');

    final response =
        await _client.from('profiles').select().eq('id', userId).maybeSingle();

    print('✅ [SupabaseService] User profile retrieved');
    return response;
  }

  Future<void> updateUserProfile({
    required String userId,
    String? fullName,
    String? avatarUrl,
  }) async {
    print('✏️ [SupabaseService] Updating user profile: $userId');

    final data = <String, dynamic>{};
    if (fullName != null) data['full_name'] = fullName;
    if (avatarUrl != null) data['avatar_url'] = avatarUrl;
    data['updated_at'] = DateTime.now().toIso8601String();

    await _client.from('profiles').update(data).eq('id', userId);

    print('✅ [SupabaseService] User profile updated');
  }

  // Journal Operations
  Future<List<Map<String, dynamic>>> getUserJournals(String userId) async {
    try {
      print('📚 [SupabaseService] Getting journals for user: $userId');

      // Simplified approach - get user's own journals first
      final ownJournals = await _client.from('journals').select('''
            *,
            creator:created_by(id, email, full_name, avatar_url),
            members:journal_members(
              id, user_id, role, joined_at,
              user:user_id(id, email, full_name, avatar_url)
            )
          ''').eq('created_by', userId).order('updated_at', ascending: false);

      print('📖 [SupabaseService] Found ${ownJournals.length} owned journals');

      // Get journals where user is a member
      final memberJournals = await _client.from('journal_members').select('''
            journal:journal_id(
              *,
              creator:created_by(id, email, full_name, avatar_url),
              members:journal_members(
                id, user_id, role, joined_at,
                user:user_id(id, email, full_name, avatar_url)
              )
            )
          ''').eq('user_id', userId);

      print(
          '👥 [SupabaseService] Found ${memberJournals.length} member journals');

      // Combine both lists
      final allJournals = <Map<String, dynamic>>[];
      allJournals.addAll(ownJournals);

      // Add member journals (extract from nested structure)
      for (final memberData in memberJournals) {
        if (memberData['journal'] != null) {
          allJournals.add(memberData['journal']);
        }
      }

      print('✅ [SupabaseService] Total journals: ${allJournals.length}');
      return allJournals;
    } catch (e, stackTrace) {
      print('❌ [SupabaseService] Error getting user journals: $e');
      print('📍 [SupabaseService] Stack trace: $stackTrace');
      // Return empty list if there's an error
      return [];
    }
  }

  Future<Map<String, dynamic>> createJournal({
    required String title,
    String? description,
    required bool isShared,
    required String createdBy,
  }) async {
    print('📝 [SupabaseService] Creating journal: $title (shared: $isShared)');

    final response = await _client
        .from('journals')
        .insert({
          'title': title,
          'description': description,
          'is_shared': isShared,
          'created_by': createdBy,
        })
        .select()
        .single();

    print('✅ [SupabaseService] Journal created: ${response['id']}');
    return response;
  }

  Future<void> addJournalMember({
    required String journalId,
    required String userId,
    String role = 'member',
  }) async {
    print(
        '👥 [SupabaseService] Adding member to journal $journalId: $userId ($role)');

    await _client.from('journal_members').insert({
      'journal_id': journalId,
      'user_id': userId,
      'role': role,
    });

    print('✅ [SupabaseService] Member added successfully');
  }

  // Entry Operations
  Future<List<Map<String, dynamic>>> getJournalEntries(String journalId) async {
    print('📖 [SupabaseService] Getting entries for journal: $journalId');

    try {
      final response = await _client
          .from('entries')
          .select('''
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
          ''')
          .eq('journal_id', journalId)
          .order('created_at', ascending: false);

      print('✅ [SupabaseService] Retrieved ${response.length} entries');
      return List<Map<String, dynamic>>.from(response);
    } catch (e, stackTrace) {
      print('❌ [SupabaseService] Error getting journal entries: $e');
      print('📍 [SupabaseService] Stack trace: $stackTrace');

      if (e is PostgrestException) {
        print('🔍 [SupabaseService] Postgres error details:');
        print('   - Code: ${e.code}');
        print('   - Message: ${e.message}');
        print('   - Details: ${e.details}');
        print('   - Hint: ${e.hint}');
      }

      rethrow;
    }
  }

  Future<Map<String, dynamic>> createEntry({
    required String journalId,
    required String authorId,
    String? title,
    required Map<String, dynamic> content,
    required String plainText,
  }) async {
    print('📝 [SupabaseService] Creating entry in journal: $journalId');
    print('📝 [SupabaseService] Author: $authorId');
    print('📝 [SupabaseService] Title: ${title ?? 'No title'}');
    print('📝 [SupabaseService] Plain text length: ${plainText.length}');
    print('📝 [SupabaseService] Content: $content');

    try {
      final insertData = {
        'journal_id': journalId,
        'author_id': authorId,
        'title': title,
        'content': content,
        'plain_text': plainText,
      };

      print('🚀 [SupabaseService] Inserting data: $insertData');

      final response =
          await _client.from('entries').insert(insertData).select().single();

      print(
          '✅ [SupabaseService] Entry created successfully: ${response['id']}');
      print('📊 [SupabaseService] Response data: $response');

      return response;
    } catch (e, stackTrace) {
      print('❌ [SupabaseService] Failed to create entry: $e');
      print('📍 [SupabaseService] Stack trace: $stackTrace');

      if (e is PostgrestException) {
        print('🔍 [SupabaseService] Postgres error details:');
        print('   - Code: ${e.code}');
        print('   - Message: ${e.message}');
        print('   - Details: ${e.details}');
        print('   - Hint: ${e.hint}');
      }

      rethrow;
    }
  }

  Future<void> updateEntry({
    required String entryId,
    String? title,
    Map<String, dynamic>? content,
    String? plainText,
  }) async {
    print('✏️ [SupabaseService] Updating entry: $entryId');

    final data = <String, dynamic>{
      'updated_at': DateTime.now().toIso8601String(),
    };

    if (title != null) data['title'] = title;
    if (content != null) data['content'] = content;
    if (plainText != null) data['plain_text'] = plainText;

    await _client.from('entries').update(data).eq('id', entryId);

    print('✅ [SupabaseService] Entry updated successfully');
  }

  // Comment Operations
  Future<Map<String, dynamic>> addComment({
    required String entryId,
    required String authorId,
    required String content,
  }) async {
    print('💬 [SupabaseService] Adding comment to entry: $entryId');

    final response = await _client.from('comments').insert({
      'entry_id': entryId,
      'author_id': authorId,
      'content': content,
    }).select('''
          *,
          author:author_id(id, email, full_name, avatar_url)
        ''').single();

    print('✅ [SupabaseService] Comment added successfully');
    return response;
  }

  // Reaction Operations
  Future<Map<String, dynamic>?> toggleReaction({
    required String entryId,
    required String userId,
    required String emoji,
  }) async {
    print('😊 [SupabaseService] Toggling reaction on entry: $entryId');

    // Check if reaction exists
    final existingReaction = await _client
        .from('reactions')
        .select()
        .eq('entry_id', entryId)
        .eq('user_id', userId)
        .eq('emoji', emoji)
        .maybeSingle();

    if (existingReaction != null) {
      // Remove reaction
      print('🗑️ [SupabaseService] Removing existing reaction');
      await _client.from('reactions').delete().eq('id', existingReaction['id']);
      print('✅ [SupabaseService] Reaction removed');
      return null;
    } else {
      // Add reaction
      print('➕ [SupabaseService] Adding new reaction');
      final response = await _client.from('reactions').insert({
        'entry_id': entryId,
        'user_id': userId,
        'emoji': emoji,
      }).select('''
            *,
            user:user_id(id, email, full_name, avatar_url)
          ''').single();

      print('✅ [SupabaseService] Reaction added successfully');
      return response;
    }
  }

  // Activity Operations
  Future<List<Map<String, dynamic>>> getRecentActivity({
    String? userId,
    int limit = 20,
  }) async {
    try {
      print('📈 [SupabaseService] Getting recent activity (limit: $limit)');

      // Simplified approach without .in_() method
      final response = await _client.from('activities').select('''
            *,
            user:user_id(id, email, full_name, avatar_url),
            journal:journal_id(id, title),
            entry:entry_id(id, title, plain_text)
          ''').order('created_at', ascending: false).limit(limit);

      print('✅ [SupabaseService] Retrieved ${response.length} activities');
      return List<Map<String, dynamic>>.from(response);
    } catch (e, stackTrace) {
      print('❌ [SupabaseService] Error getting recent activity: $e');
      print('📍 [SupabaseService] Stack trace: $stackTrace');
      // Return empty list if there's an error
      return [];
    }
  }

  Future<void> createActivity({
    required String userId,
    String? journalId,
    String? entryId,
    required String activityType,
    Map<String, dynamic>? metadata,
  }) async {
    print('📈 [SupabaseService] Creating activity: $activityType');
    print(
        '📈 [SupabaseService] User: $userId, Journal: $journalId, Entry: $entryId');

    try {
      await _client.from('activities').insert({
        'user_id': userId,
        'journal_id': journalId,
        'entry_id': entryId,
        'activity_type': activityType,
        'metadata': metadata,
      });

      print('✅ [SupabaseService] Activity created successfully');
    } catch (e, stackTrace) {
      print('❌ [SupabaseService] Failed to create activity: $e');
      print('📍 [SupabaseService] Stack trace: $stackTrace');

      if (e is PostgrestException) {
        print('🔍 [SupabaseService] Postgres error details:');
        print('   - Code: ${e.code}');
        print('   - Message: ${e.message}');
        print('   - Details: ${e.details}');
        print('   - Hint: ${e.hint}');
      }

      // Don't throw here since activity creation is not critical
      // The main operation (entry creation) should still succeed
    }
  }

  // Real-time subscriptions
  RealtimeChannel subscribeToJournal(String journalId) {
    print('🔔 [SupabaseService] Subscribing to journal: $journalId');

    return _client.channel('journal_$journalId').onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'entries',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'journal_id',
            value: journalId,
          ),
          callback: (payload) {
            print(
                '🔔 [SupabaseService] Real-time update received for journal: $journalId');
            // Handle real-time updates
          },
        );
  }

  RealtimeChannel subscribeToEntry(String entryId) {
    print('🔔 [SupabaseService] Subscribing to entry: $entryId');

    return _client.channel('entry_$entryId').onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'comments',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'entry_id',
            value: entryId,
          ),
          callback: (payload) {
            print(
                '🔔 [SupabaseService] Real-time update received for entry: $entryId');
            // Handle real-time updates
          },
        );
  }
}
