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
    await Supabase.initialize(
      url: url,
      anonKey: anonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
    );
    _client = Supabase.instance.client;
  }

  // Auth Stream
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  // Authentication Methods
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    String? fullName,
  }) async {
    return await _client.auth.signUp(
      email: email,
      password: password,
      data: fullName != null ? {'full_name': fullName} : null,
    );
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    await _client.auth.resetPasswordForEmail(email);
  }

  // Database Query Helpers
  SupabaseQueryBuilder from(String table) => _client.from(table);

  // Real-time subscriptions
  RealtimeChannel channel(String name) => _client.channel(name);

  // Storage
  SupabaseStorageClient get storage => _client.storage;

  // User Profile Operations
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    final response =
        await _client.from('profiles').select().eq('id', userId).maybeSingle();
    return response;
  }

  Future<void> updateUserProfile({
    required String userId,
    String? fullName,
    String? avatarUrl,
  }) async {
    final data = <String, dynamic>{};
    if (fullName != null) data['full_name'] = fullName;
    if (avatarUrl != null) data['avatar_url'] = avatarUrl;
    data['updated_at'] = DateTime.now().toIso8601String();

    await _client.from('profiles').update(data).eq('id', userId);
  }

  // Journal Operations
  Future<List<Map<String, dynamic>>> getUserJournals(String userId) async {
    try {
      // Simplified approach - get user's own journals first
      final ownJournals = await _client.from('journals').select('''
            *,
            creator:created_by(id, email, full_name, avatar_url),
            members:journal_members(
              id, user_id, role, joined_at,
              user:user_id(id, email, full_name, avatar_url)
            )
          ''').eq('created_by', userId).order('updated_at', ascending: false);

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

      // Combine both lists
      final allJournals = <Map<String, dynamic>>[];
      allJournals.addAll(ownJournals);

      // Add member journals (extract from nested structure)
      for (final memberData in memberJournals) {
        if (memberData['journal'] != null) {
          allJournals.add(memberData['journal']);
        }
      }

      return allJournals;
    } catch (e) {
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

    return response;
  }

  Future<void> addJournalMember({
    required String journalId,
    required String userId,
    String role = 'member',
  }) async {
    await _client.from('journal_members').insert({
      'journal_id': journalId,
      'user_id': userId,
      'role': role,
    });
  }

  // Entry Operations
  Future<List<Map<String, dynamic>>> getJournalEntries(String journalId) async {
    final response = await _client.from('entries').select('''
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
        ''').eq('journal_id', journalId).order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  Future<Map<String, dynamic>> createEntry({
    required String journalId,
    required String authorId,
    String? title,
    required Map<String, dynamic> content,
    required String plainText,
  }) async {
    final response = await _client
        .from('entries')
        .insert({
          'journal_id': journalId,
          'author_id': authorId,
          'title': title,
          'content': content,
          'plain_text': plainText,
        })
        .select()
        .single();

    return response;
  }

  Future<void> updateEntry({
    required String entryId,
    String? title,
    Map<String, dynamic>? content,
    String? plainText,
  }) async {
    final data = <String, dynamic>{
      'updated_at': DateTime.now().toIso8601String(),
    };

    if (title != null) data['title'] = title;
    if (content != null) data['content'] = content;
    if (plainText != null) data['plain_text'] = plainText;

    await _client.from('entries').update(data).eq('id', entryId);
  }

  // Comment Operations
  Future<Map<String, dynamic>> addComment({
    required String entryId,
    required String authorId,
    required String content,
  }) async {
    final response = await _client.from('comments').insert({
      'entry_id': entryId,
      'author_id': authorId,
      'content': content,
    }).select('''
          *,
          author:author_id(id, email, full_name, avatar_url)
        ''').single();

    return response;
  }

  // Reaction Operations
  Future<Map<String, dynamic>?> toggleReaction({
    required String entryId,
    required String userId,
    required String emoji,
  }) async {
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
      await _client.from('reactions').delete().eq('id', existingReaction['id']);
      return null;
    } else {
      // Add reaction
      final response = await _client.from('reactions').insert({
        'entry_id': entryId,
        'user_id': userId,
        'emoji': emoji,
      }).select('''
            *,
            user:user_id(id, email, full_name, avatar_url)
          ''').single();

      return response;
    }
  }

  // Activity Operations
  Future<List<Map<String, dynamic>>> getRecentActivity({
    String? userId,
    int limit = 20,
  }) async {
    try {
      // Simplified approach without .in_() method
      final response = await _client.from('activities').select('''
            *,
            user:user_id(id, email, full_name, avatar_url),
            journal:journal_id(id, title),
            entry:entry_id(id, title, plain_text)
          ''').order('created_at', ascending: false).limit(limit);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
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
    await _client.from('activities').insert({
      'user_id': userId,
      'journal_id': journalId,
      'entry_id': entryId,
      'activity_type': activityType,
      'metadata': metadata,
    });
  }

  // Real-time subscriptions
  RealtimeChannel subscribeToJournal(String journalId) {
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
            // Handle real-time updates
          },
        );
  }

  RealtimeChannel subscribeToEntry(String entryId) {
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
            // Handle real-time updates
          },
        );
  }
}
