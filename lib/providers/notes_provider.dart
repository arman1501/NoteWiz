import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/note_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotesProvider extends ChangeNotifier {
  List<NoteModel> _notes = [];
  String _searchQuery = '';
  NoteCategory? _filterCategory;
  bool _isDarkMode = true;
  String _userName = '';
  String _userEmail = '';
  bool _notificationsEnabled = true;
  bool _appLockEnabled = false;
  bool _autoBackupEnabled = true;
  bool _offlineModeEnabled = false;
  bool _isLoading = false;
  bool _isGridView = false;

  final _supabase = Supabase.instance.client;
  final _uuid = Uuid();

  // ─── Getters ───────────────────────────────────────────────────────────────
  List<NoteModel> get allNotes =>
      _notes.where((n) => !n.isDeleted).toList()
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

  List<NoteModel> get favorites =>
      _notes.where((n) => n.isFavorite && !n.isDeleted).toList()
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

  List<NoteModel> get trash =>
      _notes.where((n) => n.isDeleted).toList()
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

  List<NoteModel> get filteredNotes {
    var list = allNotes;
    if (_filterCategory != null) {
      list = list.where((n) => n.category == _filterCategory).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list
          .where((n) =>
              n.title.toLowerCase().contains(q) ||
              n.content.toLowerCase().contains(q) ||
              n.tags.any((t) => t.toLowerCase().contains(q)))
          .toList();
    }
    return list;
  }

  List<NoteModel> searchNotes(String query) {
    if (query.isEmpty) return allNotes;
    final q = query.toLowerCase();
    return allNotes
        .where((n) =>
            n.title.toLowerCase().contains(q) ||
            n.content.toLowerCase().contains(q) ||
            n.tags.any((t) => t.toLowerCase().contains(q)))
        .toList();
  }

  List<NoteModel> getNotesByCategory(NoteCategory cat) =>
      allNotes.where((n) => n.category == cat).toList();

  int get totalNotes => allNotes.length;
  int get totalFavorites => favorites.length;
  int get totalTrash => trash.length;

  String get searchQuery => _searchQuery;
  NoteCategory? get filterCategory => _filterCategory;
  bool get isDarkMode => _isDarkMode;
  bool get isLoading => _isLoading;
  bool get isGridView => _isGridView;

  String get userName {
    if (_userName.isNotEmpty) return _userName;
    final user = _supabase.auth.currentUser;
    return user?.userMetadata?['name']?.toString() ??
        user?.email?.split('@').first ??
        'User';
  }

  String get userEmail {
    if (_userEmail.isNotEmpty) return _userEmail;
    return _supabase.auth.currentUser?.email ?? '';
  }

  bool get notificationsEnabled => _notificationsEnabled;
  bool get appLockEnabled => _appLockEnabled;
  bool get autoBackupEnabled => _autoBackupEnabled;
  bool get offlineModeEnabled => _offlineModeEnabled;

  // ─── Init & Local Storage ──────────────────────────────────────────────────
  Future<void> init() async {
    await _loadPrefs();
    await _loadNotesLocally();

    // Pull latest user info from Supabase session
    final user = _supabase.auth.currentUser;
    if (user != null) {
      _userEmail = user.email ?? _userEmail;
      final name = user.userMetadata?['name']?.toString() ?? '';
      if (name.isNotEmpty) _userName = name;
    }

    await fetchNotes();
  }

  Future<void> _loadNotesLocally() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = _supabase.auth.currentUser?.id ?? 'guest';
      final notesJson = prefs.getString('local_notes_$userId');
      if (notesJson != null) {
        final List<dynamic> decoded = jsonDecode(notesJson);
        _notes = decoded.map((e) => NoteModel.fromMap(e as Map<String, dynamic>)).toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading local notes: $e');
    }
  }

  Future<void> _saveNotesLocally() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = _supabase.auth.currentUser?.id ?? 'guest';
      final List<Map<String, dynamic>> mapList = _notes.map((n) => n.toMap()).toList();
      final jsonStr = jsonEncode(mapList);
      await prefs.setString('local_notes_$userId', jsonStr);
    } catch (e) {
      debugPrint('Error saving local notes: $e');
    }
  }

  Future<void> fetchNotes() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      final data = await _supabase
          .from('notes')
          .select()
          .eq('user_id', user.id)
          .eq('is_deleted', false)
          .order('updated_at', ascending: false);

      final fetchedActiveNotes = (data as List<dynamic>)
          .map((e) => NoteModel.fromMap(e as Map<String, dynamic>))
          .toList();

      final trashData = await _supabase
          .from('notes')
          .select()
          .eq('user_id', user.id)
          .eq('is_deleted', true);

      final fetchedTrashedNotes = (trashData as List<dynamic>)
          .map((e) => NoteModel.fromMap(e as Map<String, dynamic>))
          .toList();

      final allRemoteNotes = [...fetchedActiveNotes, ...fetchedTrashedNotes];
      final localNotesMap = {for (var n in _notes) n.id: n};

      for (var remoteNote in allRemoteNotes) {
        final localNote = localNotesMap[remoteNote.id];
        if (localNote == null) {
          // It's a new note from the server
          localNotesMap[remoteNote.id] = remoteNote;
        } else {
          // Exists locally and remotely, keep the newest one
          if (remoteNote.updatedAt.isAfter(localNote.updatedAt)) {
            localNotesMap[remoteNote.id] = remoteNote;
          }
        }
      }

      _notes = localNotesMap.values.toList();
      await _saveNotesLocally();

      // Fire off background sync for any notes that are local-only or newer locally
      _syncLocalNotesToSupabase(allRemoteNotes, user.id);
    } catch (e) {
      debugPrint('Error fetching notes from Supabase: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _syncLocalNotesToSupabase(List<NoteModel> remoteNotes, String userId) async {
    try {
      final remoteNotesMap = {for (var n in remoteNotes) n.id: n};
      
      for (var localNote in _notes) {
        if (localNote.userId != userId) continue;
        
        final remoteNote = remoteNotesMap[localNote.id];
        if (remoteNote == null || localNote.updatedAt.isAfter(remoteNote.updatedAt)) {
          // Push to Supabase
          await _supabase.from('notes').upsert(localNote.toMap());
        }
      }
    } catch (e) {
      debugPrint('Background sync failed: $e');
    }
  }


  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('darkMode') ?? true;
    _userName = prefs.getString('userName') ?? '';
    _userEmail = prefs.getString('userEmail') ?? '';
    _notificationsEnabled = prefs.getBool('notifications') ?? true;
    _appLockEnabled = prefs.getBool('appLock') ?? false;
    _autoBackupEnabled = prefs.getBool('autoBackup') ?? true;
    _offlineModeEnabled = prefs.getBool('offlineMode') ?? false;
    _isGridView = prefs.getBool('isGridView') ?? false;
  }

  // ─── Note CRUD ─────────────────────────────────────────────────────────────
  Future<void> addNote({
    required String title,
    required String content,
    NoteCategory category = NoteCategory.other,
    List<String> tags = const [],
  }) async {
    final now = DateTime.now();
    final userId = _supabase.auth.currentUser?.id ?? 'guest';
    final newNote = NoteModel(
      id: _uuid.v4(),
      userId: userId,
      title: title.isEmpty ? 'Untitled' : title,
      content: content,
      category: category,
      tags: tags,
      createdAt: now,
      updatedAt: now,
    );

    _notes.insert(0, newNote);
    await _saveNotesLocally();
    notifyListeners();

    final user = _supabase.auth.currentUser;
    if (user != null) {
      try {
        final map = newNote.toMap();
        map['user_id'] = user.id;
        await _supabase.from('notes').insert(map);
      } catch (e) {
        debugPrint('Error adding note to Supabase: $e');
      }
    }
  }

  Future<void> updateNote(NoteModel updated) async {
    final idx = _notes.indexWhere((n) => n.id == updated.id);
    if (idx != -1) {
      final newVersion = updated.copyWith(updatedAt: DateTime.now());
      _notes[idx] = newVersion;
      await _saveNotesLocally();
      notifyListeners();

      final user = _supabase.auth.currentUser;
      if (user != null) {
        try {
          await _supabase
              .from('notes')
              .update(newVersion.toMap())
              .eq('id', newVersion.id);
        } catch (e) {
          debugPrint('Error updating note in Supabase: $e');
        }
      }
    }
  }

  Future<void> toggleFavorite(String id) async {
    final idx = _notes.indexWhere((n) => n.id == id);
    if (idx != -1) {
      final isFav = !_notes[idx].isFavorite;
      _notes[idx] = _notes[idx].copyWith(isFavorite: isFav);
      await _saveNotesLocally();
      notifyListeners();

      final user = _supabase.auth.currentUser;
      if (user != null) {
        try {
          await _supabase
              .from('notes')
              .update({'is_favorite': isFav})
              .eq('id', id);
        } catch (e) {
          debugPrint('Error toggling favourite in Supabase: $e');
        }
      }
    }
  }

  Future<void> moveToTrash(String id) async {
    final idx = _notes.indexWhere((n) => n.id == id);
    if (idx != -1) {
      _notes[idx] = _notes[idx].copyWith(isDeleted: true);
      await _saveNotesLocally();
      notifyListeners();

      final user = _supabase.auth.currentUser;
      if (user != null) {
        try {
          await _supabase
              .from('notes')
              .update({'is_deleted': true})
              .eq('id', id);
        } catch (e) {
          debugPrint('Error trashing note in Supabase: $e');
        }
      }
    }
  }

  Future<void> restoreFromTrash(String id) async {
    final idx = _notes.indexWhere((n) => n.id == id);
    if (idx != -1) {
      _notes[idx] = _notes[idx].copyWith(isDeleted: false);
      await _saveNotesLocally();
      notifyListeners();

      final user = _supabase.auth.currentUser;
      if (user != null) {
        try {
          await _supabase
              .from('notes')
              .update({'is_deleted': false})
              .eq('id', id);
        } catch (e) {
          debugPrint('Error restoring note in Supabase: $e');
        }
      }
    }
  }

  Future<void> deletePermanently(String id) async {
    _notes.removeWhere((n) => n.id == id);
    await _saveNotesLocally();
    notifyListeners();

    final user = _supabase.auth.currentUser;
    if (user != null) {
      try {
        await _supabase.from('notes').delete().eq('id', id);
      } catch (e) {
        debugPrint('Error deleting note from Supabase: $e');
      }
    }
  }

  Future<void> emptyTrash() async {
    final trashedIds = _notes.where((n) => n.isDeleted).map((e) => e.id).toList();
    _notes.removeWhere((n) => n.isDeleted);
    await _saveNotesLocally();
    notifyListeners();

    final user = _supabase.auth.currentUser;
    if (user != null && trashedIds.isNotEmpty) {
      try {
        await _supabase.from('notes').delete().inFilter('id', trashedIds);
      } catch (e) {
        debugPrint('Error emptying trash in Supabase: $e');
      }
    }
  }

  NoteModel? getNoteById(String id) =>
      _notes.where((n) => n.id == id).firstOrNull;

  // ─── Search & Filter ───────────────────────────────────────────────────────
  void setSearchQuery(String q) {
    _searchQuery = q;
    notifyListeners();
  }

  void setFilterCategory(NoteCategory? cat) {
    _filterCategory = cat;
    notifyListeners();
  }

  // ─── Settings ─────────────────────────────────────────────────────────────
  Future<void> toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', _isDarkMode);
    notifyListeners();
  }

  Future<void> setGridView(bool val) async {
    _isGridView = val;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isGridView', val);
    notifyListeners();
  }

  Future<void> setNotifications(bool val) async {
    _notificationsEnabled = val;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications', val);
    notifyListeners();
  }

  Future<void> setAppLock(bool val) async {
    _appLockEnabled = val;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('appLock', val);
    notifyListeners();
  }

  Future<void> setAutoBackup(bool val) async {
    _autoBackupEnabled = val;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('autoBackup', val);
    notifyListeners();
  }

  Future<void> setOfflineMode(bool val) async {
    _offlineModeEnabled = val;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('offlineMode', val);
    notifyListeners();
  }

  /// Updates profile locally AND syncs name to Supabase user metadata.
  Future<void> updateProfile(String name, String email) async {
    _userName = name;
    _userEmail = email;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', name);
    await prefs.setString('userEmail', email);

    try {
      await _supabase.auth.updateUser(
        UserAttributes(data: {'name': name}),
      );
    } catch (e) {
      debugPrint('Error syncing profile to Supabase: $e');
    }

    notifyListeners();
  }

  /// Call this on logout to clear local note cache.
  void clearLocalData() async {
    final userId = _supabase.auth.currentUser?.id ?? 'guest';
    _notes = [];
    _userName = '';
    _userEmail = '';
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('local_notes_$userId');
    notifyListeners();
  }
}
