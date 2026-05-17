import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/notes_provider.dart';
import '../models/note_model.dart';
import '../theme/app_theme.dart';
import '../widgets/note_card.dart';
import 'note_detail_screen.dart';
import 'edit_note_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _ctrl = TextEditingController();
  String _query = '';
  int _filterIndex = 0; // 0=All, 1=Favorites, 2=Trash
  int _sortIndex = 0; // 0=Modified, 1=Created, 2=A-Z, 3=Z-A
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotesProvider>();

    List<NoteModel> results;
    if (_filterIndex == 1) {
      results = provider.favorites.where((n) =>
        _query.isEmpty ||
        n.title.toLowerCase().contains(_query.toLowerCase()) ||
        n.content.toLowerCase().contains(_query.toLowerCase())).toList();
    } else if (_filterIndex == 2) {
      results = provider.trash.where((n) =>
        _query.isEmpty ||
        n.title.toLowerCase().contains(_query.toLowerCase()) ||
        n.content.toLowerCase().contains(_query.toLowerCase())).toList();
    } else {
      results = provider.searchNotes(_query);
    }

    if (_sortIndex == 1) {
      results.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } else if (_sortIndex == 2) {
      results.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
    } else if (_sortIndex == 3) {
      results.sort((a, b) => b.title.toLowerCase().compareTo(a.title.toLowerCase()));
    }
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Header ────────────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(children: [
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    RichText(text: TextSpan(children: [
                      TextSpan(text: 'Search ', style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                      TextSpan(text: 'Notes', style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.accent)),
                    ])),
                    Text('Find your notes quickly', style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary)),
                  ]),
                ),
                PopupMenuButton<int>(
                  color: AppColors.cardColor,
                  offset: Offset(0, 50),
                  onSelected: (val) => setState(() => _sortIndex = val),
                  itemBuilder: (ctx) => [
                    PopupMenuItem(value: 0, child: Row(children: [Icon(Icons.access_time_rounded, size: 16, color: _sortIndex == 0 ? AppColors.accent : AppColors.textPrimary), SizedBox(width: 10), Text('Date Modified', style: GoogleFonts.poppins(fontSize: 13, color: _sortIndex == 0 ? AppColors.accent : AppColors.textPrimary))])),
                    PopupMenuItem(value: 1, child: Row(children: [Icon(Icons.calendar_today_rounded, size: 16, color: _sortIndex == 1 ? AppColors.accent : AppColors.textPrimary), SizedBox(width: 10), Text('Date Created', style: GoogleFonts.poppins(fontSize: 13, color: _sortIndex == 1 ? AppColors.accent : AppColors.textPrimary))])),
                    PopupMenuItem(value: 2, child: Row(children: [Icon(Icons.sort_by_alpha_rounded, size: 16, color: _sortIndex == 2 ? AppColors.accent : AppColors.textPrimary), SizedBox(width: 10), Text('Title (A-Z)', style: GoogleFonts.poppins(fontSize: 13, color: _sortIndex == 2 ? AppColors.accent : AppColors.textPrimary))])),
                    PopupMenuItem(value: 3, child: Row(children: [Icon(Icons.sort_by_alpha_rounded, size: 16, color: _sortIndex == 3 ? AppColors.accent : AppColors.textPrimary), SizedBox(width: 10), Text('Title (Z-A)', style: GoogleFonts.poppins(fontSize: 13, color: _sortIndex == 3 ? AppColors.accent : AppColors.textPrimary))])),
                  ],
                  child: Container(
                    width: 42, height: 42,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.cardColor,
                      border: Border.all(color: AppColors.accent.withValues(alpha: 0.5)),
                    ),
                    child: Icon(Icons.sort_rounded, color: AppColors.accent, size: 20),
                  ),
                ),
              ]),
            ),
            // ─── Search Field ───────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: TextField(
                controller: _ctrl,
                autofocus: false,
                style: GoogleFonts.poppins(color: AppColors.textPrimary, fontSize: 14),
                onChanged: (v) => setState(() => _query = v),
                decoration: InputDecoration(
                  hintText: 'Search notes by title or content...',
                  prefixIcon: Icon(Icons.search_rounded, color: AppColors.accent, size: 20),
                  suffixIcon: _query.isNotEmpty
                      ? IconButton(
                          icon: Container(
                            width: 22, height: 22,
                            decoration: BoxDecoration(color: AppColors.textHint, shape: BoxShape.circle),
                            child: Icon(Icons.close_rounded, color: AppColors.background, size: 14),
                          ),
                          onPressed: () { _ctrl.clear(); setState(() => _query = ''); },
                        )
                      : null,
                  fillColor: AppColors.cardColor,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: AppColors.accent.withValues(alpha: 0.5)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: AppColors.accent, width: 1.5),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: AppColors.accent.withValues(alpha: 0.4)),
                  ),
                ),
              ),
            ),
            // ─── Filter Chips ───────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(20, 14, 20, 0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: BouncingScrollPhysics(),
                child: Row(children: [
                  _FilterChip(label: 'All Notes', count: provider.totalNotes, icon: Icons.description_outlined,
                      isActive: _filterIndex == 0, onTap: () => setState(() => _filterIndex = 0)),
                  SizedBox(width: 10),
                  _FilterChip(label: 'Favorites', count: provider.totalFavorites, icon: Icons.star_outline_rounded,
                      isActive: _filterIndex == 1, onTap: () => setState(() => _filterIndex = 1)),
                  SizedBox(width: 10),
                  _FilterChip(label: 'Trash', count: provider.totalTrash, icon: Icons.delete_outline_rounded,
                      isActive: _filterIndex == 2, onTap: () => setState(() => _filterIndex = 2)),
                ]),
              ),
            ),
            // ─── Results Header ─────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 4),
              child: Row(children: [
                Text('Search Results', style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                Spacer(),
                Text('${results.length} found', style: GoogleFonts.poppins(fontSize: 13, color: AppColors.accent, fontWeight: FontWeight.w500)),
              ]),
            ),
            // ─── Results List ────────────────────────────────────────────────
            Expanded(
              child: results.isEmpty
                  ? Center(
                      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(Icons.search_off_rounded, color: AppColors.textHint, size: 60),
                        SizedBox(height: 16),
                        Text(_query.isEmpty ? 'Start typing to search' : 'No results found',
                            style: GoogleFonts.poppins(fontSize: 15, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                        if (_query.isNotEmpty)
                          Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: Text('Try different keywords', style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textHint)),
                          ),
                      ]),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.fromLTRB(20, 8, 20, 100),
                      itemCount: results.length,
                      itemBuilder: (ctx, i) {
                        final note = results[i];
                        return NoteCard(
                          id: note.id,
                          title: note.title,
                          preview: note.content,
                          category: note.category.label,
                          categoryColor: note.category.color,
                          categoryIcon: note.category.icon,
                          isFavorite: note.isFavorite,
                          timeAgo: note.timeAgo,
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => NoteDetailScreen(note: note))),
                          onFavoriteToggle: () => provider.toggleFavorite(note.id),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => EditNoteScreen())),
        backgroundColor: AppColors.accent,
        elevation: 12,
        shape: CircleBorder(),
        child: Container(
          decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [BoxShadow(color: AppColors.accent.withValues(alpha: 0.5), blurRadius: 20)]),
          child: Icon(Icons.add_rounded, color: Colors.white, size: 28),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label; final int count; final IconData icon;
  final bool isActive; final VoidCallback onTap;
  const _FilterChip({required this.label, required this.count, required this.icon, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.accent : AppColors.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isActive ? AppColors.accent : AppColors.border),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 15, color: isActive ? Colors.white : AppColors.textSecondary),
          SizedBox(width: 6),
          Text(label, style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: isActive ? Colors.white : AppColors.textSecondary)),
          SizedBox(width: 6),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(color: isActive ? Colors.white.withValues(alpha: 0.25) : AppColors.surfaceColor, borderRadius: BorderRadius.circular(10)),
            child: Text('$count', style: GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.w700, color: isActive ? Colors.white : AppColors.textSecondary)),
          ),
        ]),
      ),
    );
  }
}
