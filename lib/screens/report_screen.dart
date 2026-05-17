import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/notes_provider.dart';
import '../models/note_model.dart';
import '../theme/app_theme.dart';
import 'splash_screen.dart';

class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotesProvider>();
    final notes = provider.allNotes;
    final favorites = provider.favorites;
    final trash = provider.trash;

    // Category breakdown
    final Map<NoteCategory, int> catCount = {};
    for (final n in notes) {
      catCount[n.category] = (catCount[n.category] ?? 0) + 1;
    }

    // Most used category
    NoteCategory? topCat;
    int topCount = 0;
    catCount.forEach((cat, count) {
      if (count > topCount) { topCat = cat; topCount = count; }
    });

    // Notes this week
    final now = DateTime.now();
    final weekAgo = now.subtract(Duration(days: 7));
    final notesThisWeek = notes.where((n) => n.createdAt.isAfter(weekAgo)).length;

    // Total words
    final totalWords = notes.fold<int>(0, (sum, n) => sum + n.wordCount);

    // Favorite percentage
    final favPercent = notes.isEmpty ? 0.0 : (favorites.length / notes.length * 100);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: RichText(
          text: TextSpan(children: [
            TextSpan(text: 'Project ', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            TextSpan(text: 'Report', style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.accent)),
          ]),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.accent.withValues(alpha: 0.4)),
              ),
              child: Text('NoteWiz v1.0', style: GoogleFonts.poppins(fontSize: 11, color: AppColors.accent, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20, 12, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ─── Project Info ───────────────────────────────────────────────
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.accent.withValues(alpha: 0.15), AppColors.cardColor],
                ),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  NoteWizLogo(size: 48),
                  SizedBox(width: 14),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('NoteWiz', style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                    Text('Smart Note-Taking Application', style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary)),
                  ]),
                ]),
                SizedBox(height: 16),
                Divider(color: AppColors.divider),
                SizedBox(height: 12),
                _InfoRow(icon: Icons.phone_android_rounded, label: 'Platform', value: 'Flutter (Android, Web)'),
                SizedBox(height: 8),
                _InfoRow(icon: Icons.storage_rounded, label: 'Backend', value: 'Supabase (PostgreSQL)'),
                SizedBox(height: 8),
                _InfoRow(icon: Icons.lock_outline_rounded, label: 'Auth', value: 'Supabase Auth (Email + Password)'),
                SizedBox(height: 8),
                _InfoRow(icon: Icons.code_rounded, label: 'Language', value: 'Dart 3.x'),
                SizedBox(height: 8),
                _InfoRow(icon: Icons.architecture_rounded, label: 'Architecture', value: 'Provider + ChangeNotifier'),
                SizedBox(height: 8),
                _InfoRow(icon: Icons.design_services_rounded, label: 'UI', value: 'Material 3 + Custom Dark Theme'),
              ]),
            ),
            SizedBox(height: 20),

            // ─── Key Stats ──────────────────────────────────────────────────
            _SectionHeader('📊 Live Statistics'),
            SizedBox(height: 12),
            Row(children: [
              Expanded(child: _BigStatCard(
                icon: Icons.description_rounded,
                value: '${notes.length}',
                label: 'Total Notes',
                color: AppColors.accent,
              )),
              SizedBox(width: 12),
              Expanded(child: _BigStatCard(
                icon: Icons.star_rounded,
                value: '${favorites.length}',
                label: 'Favorites',
                color: Colors.amber,
              )),
            ]),
            SizedBox(height: 12),
            Row(children: [
              Expanded(child: _BigStatCard(
                icon: Icons.delete_rounded,
                value: '${trash.length}',
                label: 'In Trash',
                color: AppColors.error,
              )),
              SizedBox(width: 12),
              Expanded(child: _BigStatCard(
                icon: Icons.date_range_rounded,
                value: '$notesThisWeek',
                label: 'This Week',
                color: AppColors.success,
              )),
            ]),
            SizedBox(height: 12),
            Row(children: [
              Expanded(child: _BigStatCard(
                icon: Icons.text_fields_rounded,
                value: '$totalWords',
                label: 'Total Words',
                color: AppColors.info,
              )),
              SizedBox(width: 12),
              Expanded(child: _BigStatCard(
                icon: Icons.favorite_rounded,
                value: '${favPercent.toStringAsFixed(1)}%',
                label: 'Fav Rate',
                color: Color(0xFFE91E63),
              )),
            ]),
            SizedBox(height: 20),

            // ─── Category Breakdown ─────────────────────────────────────────
            _SectionHeader('📂 Notes by Category'),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: notes.isEmpty
                    ? [Center(child: Text('No notes yet', style: GoogleFonts.poppins(color: AppColors.textHint)))]
                    : NoteCategory.values.map((cat) {
                        final count = catCount[cat] ?? 0;
                        final pct = notes.isEmpty ? 0.0 : count / notes.length;
                        return Padding(
                          padding: EdgeInsets.only(bottom: 10),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Row(children: [
                              Container(
                                width: 28, height: 28,
                                decoration: BoxDecoration(color: cat.color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                                child: Icon(cat.icon, color: cat.color, size: 15),
                              ),
                              SizedBox(width: 10),
                              Expanded(child: Text(cat.label, style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textPrimary, fontWeight: FontWeight.w500))),
                              Text('$count note${count == 1 ? '' : 's'}', style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textHint)),
                            ]),
                            SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: pct,
                                backgroundColor: AppColors.surfaceColor,
                                color: cat.color,
                                minHeight: 6,
                              ),
                            ),
                          ]),
                        );
                      }).toList(),
              ),
            ),
            SizedBox(height: 20),

            // ─── Features ───────────────────────────────────────────────────
            _SectionHeader('✅ Implemented Features'),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(children: [
                _FeatureRow('Splash Screen with animation', done: true),
                _FeatureRow('Email + Password Authentication', done: true),
                _FeatureRow('Signup with email confirmation', done: true),
                _FeatureRow('Forgot Password (email reset)', done: true),
                _FeatureRow('Profile Page with edit support', done: true),
                _FeatureRow('Create / Read notes (Supabase)', done: true),
                _FeatureRow('Update notes with live sync', done: true),
                _FeatureRow('Delete to Trash + Restore', done: true),
                _FeatureRow('Permanent Delete', done: true),
                _FeatureRow('Favorites / Star notes', done: true),
                _FeatureRow('Search by title & content', done: true),
                _FeatureRow('Category filter (7 categories)', done: true),
                _FeatureRow('Dark mode toggle', done: true),
                _FeatureRow('Session auto-expiry redirect', done: true),
                _FeatureRow('Loading shimmer animation', done: true),
                _FeatureRow('Rate limit error handling', done: true),
                _FeatureRow('Android & Web build', done: true),
                _FeatureRow('Project Report Screen', done: true),
              ]),
            ),
            SizedBox(height: 20),

            // ─── Most Used Category ─────────────────────────────────────────
            if (topCat != null) ...[
              _SectionHeader('🏆 Top Category'),
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: topCat!.color.withValues(alpha: 0.4)),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [topCat!.color.withValues(alpha: 0.1), AppColors.cardColor],
                  ),
                ),
                child: Row(children: [
                  Container(
                    width: 52, height: 52,
                    decoration: BoxDecoration(color: topCat!.color, borderRadius: BorderRadius.circular(14)),
                    child: Icon(topCat!.icon, color: Colors.white, size: 26),
                  ),
                  SizedBox(width: 16),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(topCat!.label, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                    Text('$topCount note${topCount == 1 ? '' : 's'} — most used category', style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary)),
                  ]),
                ]),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Widgets ─────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);
  @override
  Widget build(BuildContext context) => Text(text,
      style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary));
}

class _InfoRow extends StatelessWidget {
  final IconData icon; final String label, value;
  const _InfoRow({required this.icon, required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Row(children: [
    Icon(icon, size: 16, color: AppColors.accent),
    SizedBox(width: 10),
    Text('$label: ', style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textHint)),
    Expanded(child: Text(value, style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textPrimary, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis)),
  ]);
}

class _BigStatCard extends StatelessWidget {
  final IconData icon; final String value, label; final Color color;
  const _BigStatCard({required this.icon, required this.value, required this.label, required this.color});
  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.cardColor,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: color.withValues(alpha: 0.3)),
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        width: 36, height: 36,
        decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: color, size: 18),
      ),
      SizedBox(height: 10),
      Text(value, style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
      Text(label, style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary)),
    ]),
  );
}

class _FeatureRow extends StatelessWidget {
  final String feature; final bool done;
  const _FeatureRow(this.feature, {required this.done});
  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(bottom: 8),
    child: Row(children: [
      Container(
        width: 20, height: 20,
        decoration: BoxDecoration(
          color: done ? AppColors.success.withValues(alpha: 0.15) : AppColors.surfaceColor,
          shape: BoxShape.circle,
          border: Border.all(color: done ? AppColors.success : AppColors.border),
        ),
        child: done ? Icon(Icons.check_rounded, size: 13, color: AppColors.success) : null,
      ),
      SizedBox(width: 10),
      Expanded(child: Text(feature, style: GoogleFonts.poppins(fontSize: 13, color: done ? AppColors.textPrimary : AppColors.textHint))),
    ]),
  );
}
