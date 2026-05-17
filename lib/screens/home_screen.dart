import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/notes_provider.dart';
import '../models/note_model.dart';
import '../theme/app_theme.dart';
import '../widgets/note_card.dart';
import 'edit_note_screen.dart';
import 'note_detail_screen.dart';
import 'notes_list_screen.dart';
import 'report_screen.dart';
class HomeScreen extends StatelessWidget {
  final VoidCallback? onSearchTap;
  const HomeScreen({super.key, this.onSearchTap});

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good Morning';
    if (h < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotesProvider>();
    final notes = provider.filteredNotes;
    final isLoading = provider.isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ─── Header ──────────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(children: [
                              TextSpan(
                                text: '${_greeting()}, ',
                                style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                              ),
                              TextSpan(
                                text: provider.userName.split(' ').first,
                                style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.accent),
                              ),
                              TextSpan(text: ''),
                            ]),
                          ),
                          Text('Ready to capture your ideas?',
                              style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    // Pro badge
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.cardColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.accent.withValues(alpha: 0.4)),
                      ),
                      child: Row(children: [
                        Icon(Icons.workspace_premium_rounded, color: Colors.amber, size: 16),
                        SizedBox(width: 4),
                        Text('Pro', style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                      ]),
                    ),
                    SizedBox(width: 10),
                    Stack(children: [
                      GestureDetector(
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('No new notifications', style: GoogleFonts.poppins(color: Colors.white, fontSize: 13)),
                            backgroundColor: AppColors.accent,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            margin: EdgeInsets.all(20),
                            duration: Duration(seconds: 2),
                          ));
                        },
                        child: Container(
                          width: 40, height: 40,
                          decoration: BoxDecoration(color: AppColors.cardColor, shape: BoxShape.circle, border: Border.all(color: AppColors.border)),
                          child: Icon(Icons.notifications_outlined, color: AppColors.textSecondary, size: 20),
                        ),
                      ),
                      Positioned(top: 6, right: 6, child: Container(width: 8, height: 8, decoration: BoxDecoration(color: AppColors.accent, shape: BoxShape.circle))),
                    ]),
                  ],
                ),
              ),
            ),

            // ─── Search Bar ──────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: GestureDetector(
                  onTap: () {
                    if (onSearchTap != null) onSearchTap!();
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.accent.withValues(alpha: 0.4)),
                    ),
                    child: Row(children: [
                      Icon(Icons.search_rounded, color: AppColors.textHint, size: 20),
                      SizedBox(width: 12),
                      Expanded(child: Text('Search notes by title or content...', style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textHint))),
                      Icon(Icons.tune_rounded, color: AppColors.accent, size: 20),
                    ]),
                  ),
                ),
              ),
            ),

            // ─── Stats Row ───────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Row(children: [
                  _StatCard(icon: Icons.description_outlined, count: provider.totalNotes, label: 'Notes', color: AppColors.accent, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => NotesListScreen(initialTab: 0)))),
                  SizedBox(width: 10),
                  _StatCard(icon: Icons.star_outline_rounded, count: provider.totalFavorites, label: 'Favorites', color: Colors.amber, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => NotesListScreen(initialTab: 1)))),
                  SizedBox(width: 10),
                  _StatCard(icon: Icons.delete_outline_rounded, count: provider.totalTrash, label: 'Trash', color: AppColors.error, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => NotesListScreen(initialTab: 2)))),
                  SizedBox(width: 10),
                  _StatCard(icon: Icons.calendar_today_outlined, count: provider.allNotes.isEmpty ? 1 : DateTime.now().difference(provider.allNotes.last.createdAt).inDays + 1, label: 'Days Active', color: AppColors.info, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ReportScreen()))),
                ]),
              ),
            ),

            // ─── Category Tabs ───────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
                child: _CategoryTabs(),
              ),
            ),

            // ─── Recent Notes Header ─────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Row(children: [
                  Text('Recent Notes', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                  Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => NotesListScreen())),
                    child: Row(children: [
                      Text('View All', style: GoogleFonts.poppins(fontSize: 13, color: AppColors.accent, fontWeight: FontWeight.w500)),
                      Icon(Icons.chevron_right_rounded, color: AppColors.accent, size: 18),
                    ]),
                  ),
                  SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => provider.setGridView(false),
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 200),
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: !provider.isGridView ? AppColors.accent.withValues(alpha: 0.15) : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(Icons.view_list_rounded, color: !provider.isGridView ? AppColors.accent : AppColors.textHint, size: 20),
                    ),
                  ),
                  SizedBox(width: 4),
                  GestureDetector(
                    onTap: () => provider.setGridView(true),
                    child: AnimatedContainer(
                      duration: Duration(milliseconds: 200),
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: provider.isGridView ? AppColors.accent.withValues(alpha: 0.15) : Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(Icons.grid_view_rounded, color: provider.isGridView ? AppColors.accent : AppColors.textHint, size: 20),
                    ),
                  ),
                ]),
              ),
            ),

            // ─── Notes List ──────────────────────────────────────────────────
            SliverPadding(
              padding: EdgeInsets.fromLTRB(20, 12, 20, 100),
              sliver: isLoading
                  ? SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (_, __) => _ShimmerCard(),
                        childCount: 4,
                      ),
                    )
                  : notes.isEmpty
                      ? SliverToBoxAdapter(child: _EmptyState())
                      : provider.isGridView
                          ? SliverGrid(
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: 12,
                                crossAxisSpacing: 12,
                                childAspectRatio: 0.82,
                              ),
                              delegate: SliverChildBuilderDelegate(
                                (ctx, i) {
                                  final note = notes[i];
                                  return NoteCard(
                                    id: note.id,
                                    title: note.title,
                                    preview: note.content,
                                    category: note.category.label,
                                    categoryColor: note.category.color,
                                    categoryIcon: note.category.icon,
                                    isFavorite: note.isFavorite,
                                    timeAgo: note.timeAgo,
                                    isGrid: true,
                                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => NoteDetailScreen(note: note))),
                                    onFavoriteToggle: () => provider.toggleFavorite(note.id),
                                    onMenuTap: () => _showNoteMenu(context, note, provider),
                                  );
                                },
                                childCount: notes.length,
                              ),
                            )
                          : SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (ctx, i) {
                                  final note = notes[i];
                                  return NoteCard(
                                    id: note.id,
                                    title: note.title,
                                    preview: note.content,
                                    category: note.category.label,
                                    categoryColor: note.category.color,
                                    categoryIcon: note.category.icon,
                                    isFavorite: note.isFavorite,
                                    timeAgo: note.timeAgo,
                                    isGrid: false,
                                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => NoteDetailScreen(note: note))),
                                    onFavoriteToggle: () => provider.toggleFavorite(note.id),
                                    onMenuTap: () => _showNoteMenu(context, note, provider),
                                  );
                                },
                                childCount: notes.length,
                              ),
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
          width: 56, height: 56,
          decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [BoxShadow(color: AppColors.accent.withValues(alpha: 0.5), blurRadius: 20, spreadRadius: 2)]),
          child: Icon(Icons.add_rounded, color: Colors.white, size: 28),
        ),
      ),
    );
  }

  void _showNoteMenu(BuildContext context, NoteModel note, NotesProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2))),
          SizedBox(height: 20),
          _MenuTile(icon: Icons.edit_outlined, label: 'Edit Note', onTap: () { Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (_) => EditNoteScreen(note: note))); }),
          _MenuTile(icon: note.isFavorite ? Icons.star_rounded : Icons.star_outline_rounded, label: note.isFavorite ? 'Remove Favorite' : 'Add Favorite', color: Colors.amber, onTap: () { provider.toggleFavorite(note.id); Navigator.pop(context); }),
          _MenuTile(icon: Icons.delete_outline_rounded, label: 'Move to Trash', color: AppColors.error, onTap: () { provider.moveToTrash(note.id); Navigator.pop(context); }),
        ]),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon; final int count; final String label; final Color color; final VoidCallback? onTap;
  const _StatCard({required this.icon, required this.count, required this.label, required this.color, this.onTap});
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(12),
        decoration: BoxDecoration(color: AppColors.cardColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Icon(icon, color: color, size: 20),
            Icon(Icons.chevron_right_rounded, color: AppColors.textHint, size: 14),
          ]),
          SizedBox(height: 8),
          Text('$count', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          Text(label, style: GoogleFonts.poppins(fontSize: 10, color: color, fontWeight: FontWeight.w500)),
        ]),
        ),
      ),
    );
  }
}

class _CategoryTabs extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotesProvider>();
    final currentCat = provider.filterCategory;
    
    final tabs = [
      {'label': 'All Notes', 'count': provider.totalNotes, 'category': null},
      {'label': 'Work', 'count': provider.getNotesByCategory(NoteCategory.work).length, 'category': NoteCategory.work},
      {'label': 'Personal', 'count': provider.getNotesByCategory(NoteCategory.personal).length, 'category': NoteCategory.personal},
      {'label': 'Ideas', 'count': provider.getNotesByCategory(NoteCategory.ideas).length, 'category': NoteCategory.ideas},
      {'label': 'Diary', 'count': provider.getNotesByCategory(NoteCategory.diary).length, 'category': NoteCategory.diary},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: tabs.map((tab) {
          final cat = tab['category'] as NoteCategory?;
          final active = currentCat == cat;
          return GestureDetector(
            onTap: () => provider.setFilterCategory(cat),
            child: AnimatedContainer(
              duration: Duration(milliseconds: 220),
              margin: EdgeInsets.only(right: 10),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 9),
              decoration: BoxDecoration(
                color: active ? AppColors.accent : AppColors.cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: active ? AppColors.accent : AppColors.border),
              ),
              child: Row(children: [
                Text(tab['label'] as String, style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: active ? Colors.white : AppColors.textSecondary)),
                SizedBox(width: 6),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(color: active ? Colors.white.withValues(alpha: 0.2) : AppColors.surfaceColor, borderRadius: BorderRadius.circular(10)),
                  child: Text('${tab['count']}', style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: active ? Colors.white : AppColors.textSecondary)),
                ),
              ]),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 60),
        child: Column(children: [
          Icon(Icons.note_add_outlined, color: AppColors.textHint, size: 64),
          SizedBox(height: 16),
          Text('No notes yet', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
          SizedBox(height: 8),
          Text('Tap + to create your first note', style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textHint)),
        ]),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon; final String label; final VoidCallback onTap; final Color? color;
  const _MenuTile({required this.icon, required this.label, required this.onTap, this.color});
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: color ?? AppColors.textPrimary, size: 22),
      title: Text(label, style: GoogleFonts.poppins(fontSize: 14, color: color ?? AppColors.textPrimary)),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}

/// Animated shimmer card shown while notes load
class _ShimmerCard extends StatefulWidget {
  const _ShimmerCard();
  @override
  State<_ShimmerCard> createState() => _ShimmerCardState();
}

class _ShimmerCardState extends State<_ShimmerCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) {
        final opacity = 0.3 + (_anim.value * 0.4);
        return Container(
          margin: EdgeInsets.only(bottom: 12),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cardColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                color: AppColors.surfaceColor.withValues(alpha: opacity),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                  height: 14, width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceColor.withValues(alpha: opacity),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  height: 12, width: 200,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceColor.withValues(alpha: opacity * 0.7),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                SizedBox(height: 8),
                Container(
                  height: 12, width: 120,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceColor.withValues(alpha: opacity * 0.5),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ]),
            ),
          ]),
        );
      },
    );
  }
}

