import 'package:flutter/material.dart';

enum NoteCategory { work, personal, ideas, diary, health, shopping, other }

extension NoteCategoryExtension on NoteCategory {
  String get label {
    switch (this) {
      case NoteCategory.work: return 'Work';
      case NoteCategory.personal: return 'Personal';
      case NoteCategory.ideas: return 'Ideas';
      case NoteCategory.diary: return 'Diary';
      case NoteCategory.health: return 'Health';
      case NoteCategory.shopping: return 'Shopping';
      case NoteCategory.other: return 'Other';
    }
  }

  Color get color {
    switch (this) {
      case NoteCategory.work: return Color(0xFF3B5BDB);
      case NoteCategory.personal: return Color(0xFF2E7D32);
      case NoteCategory.ideas: return Color(0xFFE65100);
      case NoteCategory.diary: return Color(0xFF1976D2);
      case NoteCategory.health: return Color(0xFF6A1B9A);
      case NoteCategory.shopping: return Color(0xFF00695C);
      case NoteCategory.other: return Color(0xFF6C63FF);
    }
  }

  IconData get icon {
    switch (this) {
      case NoteCategory.work: return Icons.work_outline_rounded;
      case NoteCategory.personal: return Icons.person_outline_rounded;
      case NoteCategory.ideas: return Icons.lightbulb_outline_rounded;
      case NoteCategory.diary: return Icons.chat_bubble_outline_rounded;
      case NoteCategory.health: return Icons.fitness_center_rounded;
      case NoteCategory.shopping: return Icons.shopping_cart_outlined;
      case NoteCategory.other: return Icons.description_outlined;
    }
  }
}

class NoteModel {
  final String id;
  final String userId;
  String title;
  String content;
  NoteCategory category;
  List<String> tags;
  bool isFavorite;
  bool isDeleted;
  DateTime createdAt;
  DateTime updatedAt;

  NoteModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    this.category = NoteCategory.other,
    this.tags = const [],
    this.isFavorite = false,
    this.isDeleted = false,
    required this.createdAt,
    required this.updatedAt,
  });

  NoteModel copyWith({
    String? title,
    String? content,
    NoteCategory? category,
    List<String>? tags,
    bool? isFavorite,
    bool? isDeleted,
    DateTime? updatedAt,
  }) {
    return NoteModel(
      id: id,
      userId: userId,
      title: title ?? this.title,
      content: content ?? this.content,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      isFavorite: isFavorite ?? this.isFavorite,
      isDeleted: isDeleted ?? this.isDeleted,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Serialise for Supabase — uses snake_case column names.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'content': content,
      'category': category.index,
      'tags': tags.join('|'),
      'is_favorite': isFavorite,
      'is_deleted': isDeleted,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Deserialise from Supabase — handles snake_case and both bool/int types.
  factory NoteModel.fromMap(Map<String, dynamic> map) {
    // Helper: safely parse bool from Supabase (returns bool or int 0/1)
    bool parseBool(dynamic v) =>
        v == true || v == 1 || v?.toString() == 'true';

    // Helper: parse tags from pipe-separated string or null
    List<String> parseTags(dynamic v) {
      if (v == null || v.toString().trim().isEmpty) return [];
      return v.toString().split('|').where((s) => s.isNotEmpty).toList();
    }

    // Helper: parse category index safely
    int parseCat(dynamic v) {
      final idx = int.tryParse(v?.toString() ?? '') ?? 6;
      return idx.clamp(0, NoteCategory.values.length - 1);
    }

    return NoteModel(
      id: map['id']?.toString() ?? '',
      userId: map['user_id']?.toString() ?? '',
      title: map['title']?.toString() ?? 'Untitled',
      content: map['content']?.toString() ?? '',
      category: NoteCategory.values[parseCat(map['category'])],
      tags: parseTags(map['tags']),
      isFavorite: parseBool(map['is_favorite']),
      isDeleted: parseBool(map['is_deleted']),
      createdAt: _parseDate(map['created_at']),
      updatedAt: _parseDate(map['updated_at']),
    );
  }

  static DateTime _parseDate(dynamic v) {
    if (v == null) return DateTime.now();
    try {
      return DateTime.parse(v.toString());
    } catch (_) {
      return DateTime.now();
    }
  }

  String get timeAgo {
    final now = DateTime.now();
    final diff = now.difference(updatedAt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} mins ago';
    if (diff.inHours < 24) return '${diff.inHours} hour${diff.inHours == 1 ? '' : 's'} ago';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return '${updatedAt.day}/${updatedAt.month}/${updatedAt.year}';
  }

  int get wordCount =>
      content.trim().isEmpty ? 0 : content.trim().split(RegExp(r'\s+')).length;
}
