import 'package:flutter/material.dart';
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
    try {
      debugPrint('🔧 [SupabaseService] Initializing with URL: $url');
      debugPrint('🔧 [SupabaseService] Anon key length: ${anonKey.length}');

      await Supabase.initialize(
        url: url,
        anonKey: anonKey,
        authOptions: const FlutterAuthClientOptions(
          authFlowType: AuthFlowType.pkce,
        ),
      );
      _client = Supabase.instance.client;

      debugPrint('✅ [SupabaseService] Successfully initialized');
    } catch (e, stackTrace) {
      debugPrint('❌ [SupabaseService] Initialization failed: $e');
      debugPrint('📍 [SupabaseService] Stack trace: $stackTrace');
      rethrow;
    }
  }

  // Auth Stream
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  // Authentication Methods
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    String? fullName,
  }) async {
    try {
      debugPrint('🔐 [SupabaseService] Attempting sign up for email: $email');
      debugPrint('🔐 [SupabaseService] Full name: ${fullName ?? 'null'}');

      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: fullName != null ? {'full_name': fullName} : null,
      );

      debugPrint('🔐 [SupabaseService] Sign up response:');
      debugPrint('   - User ID: ${response.user?.id}');
      debugPrint('   - User email: ${response.user?.email}');
      debugPrint(
          '   - Session: ${response.session != null ? 'exists' : 'null'}');

      if (response.user != null) {
        debugPrint('✅ [SupabaseService] Sign up successful');
      } else {
        debugPrint('⚠️ [SupabaseService] Sign up completed but user is null');
      }

      return response;
    } catch (e, stackTrace) {
      debugPrint('❌ [SupabaseService] Sign up failed: $e');
      debugPrint('📍 [SupabaseService] Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      debugPrint('🔐 [SupabaseService] Attempting sign in for email: $email');

      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      debugPrint('🔐 [SupabaseService] Sign in response:');
      debugPrint('   - User ID: ${response.user?.id}');
      debugPrint('   - User email: ${response.user?.email}');
      debugPrint(
          '   - Session: ${response.session != null ? 'exists' : 'null'}');

      if (response.user != null) {
        debugPrint('✅ [SupabaseService] Sign in successful');
      } else {
        debugPrint('⚠️ [SupabaseService] Sign in completed but user is null');
      }

      return response;
    } catch (e, stackTrace) {
      debugPrint('❌ [SupabaseService] Sign in failed: $e');
      debugPrint('📍 [SupabaseService] Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      debugPrint('🔐 [SupabaseService] Attempting sign out');
      await _client.auth.signOut();
      debugPrint('✅ [SupabaseService] Sign out successful');
    } catch (e, stackTrace) {
      debugPrint('❌ [SupabaseService] Sign out failed: $e');
      debugPrint('📍 [SupabaseService] Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      debugPrint('🔐 [SupabaseService] Attempting password reset for: $email');
      await _client.auth.resetPasswordForEmail(email);
      debugPrint('✅ [SupabaseService] Password reset email sent');
    } catch (e, stackTrace) {
      debugPrint('❌ [SupabaseService] Password reset failed: $e');
      debugPrint('📍 [SupabaseService] Stack trace: $stackTrace');
      rethrow;
    }
  }

  // Database Query Helpers
  SupabaseQueryBuilder from(String table) {
    debugPrint('🗄️ [SupabaseService] Creating query for table: $table');
    return _client.from(table);
  }

  // Real-time subscriptions
  RealtimeChannel channel(String name) => _client.channel(name);

  // Storage
  SupabaseStorageClient get storage => _client.storage;

  // User Profile Operations
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      debugPrint('👤 [SupabaseService] Fetching profile for user: $userId');

      final response = await _client
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      debugPrint(
          '👤 [SupabaseService] Profile query response: ${response != null ? 'found' : 'null'}');
      if (response != null) {
        debugPrint('   - Email: ${response['email']}');
        debugPrint('   - Full name: ${response['full_name']}');
        debugPrint('   - Created at: ${response['created_at']}');
      }

      return response;
    } catch (e, stackTrace) {
      debugPrint('❌ [SupabaseService] Get user profile failed: $e');
      debugPrint('📍 [SupabaseService] Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<void> updateUserProfile({
    required String userId,
    String? fullName,
    String? avatarUrl,
  }) async {
    try {
      debugPrint('👤 [SupabaseService] Updating profile for user: $userId');
      debugPrint('   - Full name: ${fullName ?? 'unchanged'}');
      debugPrint('   - Avatar URL: ${avatarUrl ?? 'unchanged'}');

      final data = <String, dynamic>{};
      if (fullName != null) data['full_name'] = fullName;
      if (avatarUrl != null) data['avatar_url'] = avatarUrl;
      data['updated_at'] = DateTime.now().toIso8601String();

      await _client.from('profiles').update(data).eq('id', userId);
      debugPrint('✅ [SupabaseService] Profile updated successfully');
    } catch (e, stackTrace) {
      debugPrint('❌ [SupabaseService] Update user profile failed: $e');
      debugPrint('📍 [SupabaseService] Stack trace: $stackTrace');
      rethrow;
    }
  }

  // Journal Operations
  Future<List<Map<String, dynamic>>> getUserJournals(String userId) async {
    try {
      debugPrint('📚 [SupabaseService] Fetching journals for user: $userId');

      // Get user's own journals
      final ownJournals = await _client.from('journals').select('''
            *,
            creator:created_by(id, email, full_name, avatar_url),
            members:journal_members(
              id, user_id, role, joined_at,
              user:user_id(id, email, full_name, avatar_url)
            )
          ''').eq('created_by', userId).order('updated_at', ascending: false);

      debugPrint(
          '📚 [SupabaseService] Found ${ownJournals.length} owned journals');

      // Debug: Print the first journal data to see what we're getting
      if (ownJournals.isNotEmpty) {
        debugPrint('📚 [SupabaseService] First journal data structure:');
        debugPrint('📚 [SupabaseService] ${ownJournals.first}');
      }

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

      debugPrint(
          '📚 [SupabaseService] Found ${memberJournals.length} member journals');

      // Combine both lists
      final allJournals = <Map<String, dynamic>>[];
      allJournals.addAll(ownJournals);

      // Add member journals (extract from nested structure)
      for (final memberData in memberJournals) {
        if (memberData['journal'] != null) {
          allJournals.add(memberData['journal']);
        }
      }

      debugPrint('📚 [SupabaseService] Total journals: ${allJournals.length}');
      return allJournals;
    } catch (e, stackTrace) {
      debugPrint('❌ [SupabaseService] Get user journals failed: $e');
      debugPrint('📍 [SupabaseService] Stack trace: $stackTrace');
      return [];
    }
  }

  Future<Map<String, dynamic>> createJournal({
    required String title,
    String? description,
    required bool isShared,
    required String createdBy,
  }) async {
    try {
      debugPrint('📚 [SupabaseService] Creating journal:');
      debugPrint('   - Title: $title');
      debugPrint('   - Description: ${description ?? 'null'}');
      debugPrint('   - Is shared: $isShared');
      debugPrint('   - Created by: $createdBy');

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

      debugPrint(
          '✅ [SupabaseService] Journal created with ID: ${response['id']}');
      return response;
    } catch (e, stackTrace) {
      debugPrint('❌ [SupabaseService] Create journal failed: $e');
      debugPrint('📍 [SupabaseService] Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<void> addJournalMember({
    required String journalId,
    required String userId,
    String role = 'member',
  }) async {
    try {
      debugPrint('👥 [SupabaseService] Adding member to journal:');
      debugPrint('   - Journal ID: $journalId');
      debugPrint('   - User ID: $userId');
      debugPrint('   - Role: $role');

      await _client.from('journal_members').insert({
        'journal_id': journalId,
        'user_id': userId,
        'role': role,
      });

      debugPrint('✅ [SupabaseService] Journal member added successfully');
    } catch (e, stackTrace) {
      debugPrint('❌ [SupabaseService] Add journal member failed: $e');
      debugPrint('📍 [SupabaseService] Stack trace: $stackTrace');
      rethrow;
    }
  }

  // Entry Operations
  Future<List<Map<String, dynamic>>> getJournalEntries(String journalId) async {
    try {
      debugPrint(
          '📝 [SupabaseService] Fetching entries for journal: $journalId');

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

      debugPrint('📝 [SupabaseService] Found ${response.length} entries');
      return List<Map<String, dynamic>>.from(response);
    } catch (e, stackTrace) {
      debugPrint('❌ [SupabaseService] Get journal entries failed: $e');
      debugPrint('📍 [SupabaseService] Stack trace: $stackTrace');
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
    try {
      debugPrint('📝 [SupabaseService] Creating entry:');
      debugPrint('   - Journal ID: $journalId');
      debugPrint('   - Author ID: $authorId');
      debugPrint('   - Title: ${title ?? 'null'}');
      debugPrint('   - Plain text length: ${plainText.length}');

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

      debugPrint(
          '✅ [SupabaseService] Entry created with ID: ${response['id']}');
      return response;
    } catch (e, stackTrace) {
      debugPrint('❌ [SupabaseService] Create entry failed: $e');
      debugPrint('📍 [SupabaseService] Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<void> updateEntry({
    required String entryId,
    String? title,
    Map<String, dynamic>? content,
    String? plainText,
  }) async {
    try {
      debugPrint('📝 [SupabaseService] Updating entry: $entryId');

      final data = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (title != null) data['title'] = title;
      if (content != null) data['content'] = content;
      if (plainText != null) data['plain_text'] = plainText;

      await _client.from('entries').update(data).eq('id', entryId);
      debugPrint('✅ [SupabaseService] Entry updated successfully');
    } catch (e, stackTrace) {
      debugPrint('❌ [SupabaseService] Update entry failed: $e');
      debugPrint('📍 [SupabaseService] Stack trace: $stackTrace');
      rethrow;
    }
  }

  // Comment Operations
  Future<Map<String, dynamic>> addComment({
    required String entryId,
    required String authorId,
    required String content,
  }) async {
    try {
      debugPrint('💬 [SupabaseService] Adding comment:');
      debugPrint('   - Entry ID: $entryId');
      debugPrint('   - Author ID: $authorId');
      debugPrint('   - Content length: ${content.length}');

      final response = await _client.from('comments').insert({
        'entry_id': entryId,
        'author_id': authorId,
        'content': content,
      }).select('''
          *,
          author:author_id(id, email, full_name, avatar_url)
        ''').single();

      debugPrint(
          '✅ [SupabaseService] Comment added with ID: ${response['id']}');
      return response;
    } catch (e, stackTrace) {
      debugPrint('❌ [SupabaseService] Add comment failed: $e');
      debugPrint('📍 [SupabaseService] Stack trace: $stackTrace');
      rethrow;
    }
  }

  // Reaction Operations
  Future<Map<String, dynamic>?> toggleReaction({
    required String entryId,
    required String userId,
    required String emoji,
  }) async {
    try {
      debugPrint('👍 [SupabaseService] Toggling reaction:');
      debugPrint('   - Entry ID: $entryId');
      debugPrint('   - User ID: $userId');
      debugPrint('   - Emoji: $emoji');

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
        await _client
            .from('reactions')
            .delete()
            .eq('id', existingReaction['id']);
        debugPrint('✅ [SupabaseService] Reaction removed');
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

        debugPrint(
            '✅ [SupabaseService] Reaction added with ID: ${response['id']}');
        return response;
      }
    } catch (e, stackTrace) {
      debugPrint('❌ [SupabaseService] Toggle reaction failed: $e');
      debugPrint('📍 [SupabaseService] Stack trace: $stackTrace');
      rethrow;
    }
  }

  // Activity Operations
  Future<List<Map<String, dynamic>>> getRecentActivity({
    String? userId,
    int limit = 20,
  }) async {
    try {
      debugPrint(
          '📊 [SupabaseService] Fetching recent activity (limit: $limit)');

      final response = await _client.from('activities').select('''
            *,
            user:user_id(id, email, full_name, avatar_url),
            journal:journal_id(id, title),
            entry:entry_id(id, title, plain_text)
          ''').order('created_at', ascending: false).limit(limit);

      debugPrint('📊 [SupabaseService] Found ${response.length} activities');
      return List<Map<String, dynamic>>.from(response);
    } catch (e, stackTrace) {
      debugPrint('❌ [SupabaseService] Get recent activity failed: $e');
      debugPrint('📍 [SupabaseService] Stack trace: $stackTrace');
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
    try {
      debugPrint('📊 [SupabaseService] Creating activity:');
      debugPrint('   - User ID: $userId');
      debugPrint('   - Journal ID: ${journalId ?? 'null'}');
      debugPrint('   - Entry ID: ${entryId ?? 'null'}');
      debugPrint('   - Type: $activityType');

      await _client.from('activities').insert({
        'user_id': userId,
        'journal_id': journalId,
        'entry_id': entryId,
        'activity_type': activityType,
        'metadata': metadata,
      });

      debugPrint('✅ [SupabaseService] Activity created successfully');
    } catch (e, stackTrace) {
      debugPrint('❌ [SupabaseService] Create activity failed: $e');
      debugPrint('📍 [SupabaseService] Stack trace: $stackTrace');
      rethrow;
    }
  }

  // Real-time subscriptions
  RealtimeChannel subscribeToJournal(String journalId) {
    debugPrint('📡 [SupabaseService] Subscribing to journal: $journalId');
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
            debugPrint(
                '📡 [SupabaseService] Journal update received: ${payload.eventType}');
          },
        );
  }

  RealtimeChannel subscribeToEntry(String entryId) {
    debugPrint('📡 [SupabaseService] Subscribing to entry: $entryId');
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
            debugPrint(
                '📡 [SupabaseService] Entry update received: ${payload.eventType}');
          },
        );
  }
}
