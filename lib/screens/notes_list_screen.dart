import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/notes_provider.dart';
import '../models/note_model.dart';
import '../theme/app_theme.dart';
import '../widgets/note_card.dart';
import 'edit_note_screen.dart';
import 'note_detail_screen.dart';
import 'search_screen.dart';

class NotesListScreen extends StatefulWidget {
  final int initialTab;
  const NotesListScreen({super.key, this.initialTab = 0});
  @override
  State<NotesListScreen> createState() => _NotesListScreenState();
}

class _NotesListScreenState extends State<NotesListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: widget.initialTab);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotesProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(children: [
          RichText(text: TextSpan(children: [
            TextSpan(text: 'Note', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            TextSpan(text: 'Wiz', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.accent)),
          ])),
        ]),
        actions: [
          IconButton(icon: Icon(Icons.search_rounded, color: AppColors.textPrimary), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => SearchScreen()))),
          IconButton(icon: Icon(Icons.notifications_outlined, color: AppColors.textPrimary),
              onPressed: () {}),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(50),
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: AppColors.cardColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(12),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelStyle: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600),
              unselectedLabelStyle: GoogleFonts.poppins(fontSize: 13),
              labelColor: Colors.white,
              unselectedLabelColor: AppColors.textSecondary,
              padding: EdgeInsets.all(4),
              tabs: [
                Tab(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.description_outlined, size: 16),
                  SizedBox(width: 6),
                  Text('All Notes'),
                ])),
                Tab(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.star_outline_rounded, size: 16),
                  SizedBox(width: 6),
                  Text('Favorites'),
                ])),
                Tab(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.delete_outline_rounded, size: 16),
                  SizedBox(width: 6),
                  Text('Trash'),
                ])),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _NotesList(notes: provider.allNotes, emptyMsg: 'No notes yet', showRestore: false),
          _NotesList(notes: provider.favorites, emptyMsg: 'No favorites yet', showRestore: false),
          _NotesList(notes: provider.trash, emptyMsg: 'Trash is empty', showRestore: true),
        ],
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

class _NotesList extends StatelessWidget {
  final List<NoteModel> notes;
  final String emptyMsg;
  final bool showRestore;
  const _NotesList({required this.notes, required this.emptyMsg, required this.showRestore});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<NotesProvider>();
    if (notes.isEmpty) {
      return Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.note_outlined, color: AppColors.textHint, size: 64),
          SizedBox(height: 16),
          Text(emptyMsg, style: GoogleFonts.poppins(fontSize: 15, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
        ]),
      );
    }
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 100),
      itemCount: notes.length,
      itemBuilder: (ctx, i) {
        final note = notes[i];
        return showRestore
            ? _TrashCard(note: note, provider: provider)
            : NoteCard(
                id: note.id,
                title: note.title,
                preview: note.content,
                category: note.category.label,
                categoryColor: note.category.color,
                categoryIcon: note.category.icon,
                isFavorite: note.isFavorite,
                timeAgo: note.timeAgo,
                onTap: () => Navigator.push(ctx, MaterialPageRoute(builder: (_) => NoteDetailScreen(note: note))),
                onFavoriteToggle: () => provider.toggleFavorite(note.id),
                onMenuTap: () => _menu(ctx, note, provider),
              );
      },
    );
  }

  void _menu(BuildContext ctx, NoteModel note, NotesProvider p) {
    showModalBottomSheet(
      context: ctx,
      backgroundColor: AppColors.cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(leading: Icon(Icons.edit_outlined, color: AppColors.textPrimary), title: Text('Edit', style: GoogleFonts.poppins(color: AppColors.textPrimary)),
              onTap: () { Navigator.pop(ctx); Navigator.push(ctx, MaterialPageRoute(builder: (_) => EditNoteScreen(note: note))); }),
          ListTile(leading: Icon(note.isFavorite ? Icons.star_rounded : Icons.star_border_rounded, color: Colors.amber), title: Text(note.isFavorite ? 'Unfavorite' : 'Favorite', style: GoogleFonts.poppins(color: AppColors.textPrimary)),
              onTap: () { p.toggleFavorite(note.id); Navigator.pop(ctx); }),
          ListTile(leading: Icon(Icons.delete_outline_rounded, color: AppColors.error), title: Text('Move to Trash', style: GoogleFonts.poppins(color: AppColors.error)),
              onTap: () { p.moveToTrash(note.id); Navigator.pop(ctx); }),
        ]),
      ),
    );
  }
}

class _TrashCard extends StatelessWidget {
  final NoteModel note; final NotesProvider provider;
  const _TrashCard({required this.note, required this.provider});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: AppColors.cardColor, borderRadius: BorderRadius.circular(18), border: Border.all(color: AppColors.error.withValues(alpha: 0.3))),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        leading: Container(width: 44, height: 44, decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
            child: Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 22)),
        title: Text(note.title, style: GoogleFonts.poppins(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
        subtitle: Text(note.timeAgo, style: GoogleFonts.poppins(color: AppColors.textHint, fontSize: 12)),
        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
          IconButton(icon: Icon(Icons.restore_rounded, color: AppColors.success), onPressed: () => provider.restoreFromTrash(note.id)),
          IconButton(icon: Icon(Icons.delete_forever_rounded, color: AppColors.error), onPressed: () => provider.deletePermanently(note.id)),
        ]),
      ),
    );
  }
}
