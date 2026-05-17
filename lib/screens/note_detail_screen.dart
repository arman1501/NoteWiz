import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/notes_provider.dart';
import '../models/note_model.dart';
import '../theme/app_theme.dart';
import 'edit_note_screen.dart';

class NoteDetailScreen extends StatelessWidget {
  final NoteModel note;
  const NoteDetailScreen({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotesProvider>();
    final current = provider.getNoteById(note.id) ?? note;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded,
              color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              current.isFavorite
                  ? Icons.star_rounded
                  : Icons.star_border_rounded,
              color:
                  current.isFavorite ? Colors.amber : AppColors.textSecondary,
            ),
            onPressed: () => provider.toggleFavorite(current.id),
          ),
          IconButton(
            icon: Icon(Icons.more_vert_rounded,
                color: AppColors.textSecondary),
            onPressed: () => _showMenu(context, current, provider),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20, 8, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              current.title,
              style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary),
            ),
            SizedBox(height: 8),
            Row(children: [
              Icon(Icons.folder_outlined,
                  size: 14, color: AppColors.textHint),
              SizedBox(width: 4),
              Text(current.category.label,
                  style: GoogleFonts.poppins(
                      fontSize: 12, color: AppColors.textHint)),
              SizedBox(width: 12),
              Icon(Icons.calendar_today_outlined,
                  size: 14, color: AppColors.textHint),
              SizedBox(width: 4),
              Text(
                '${current.updatedAt.day} ${_monthName(current.updatedAt.month)} ${current.updatedAt.year}',
                style: GoogleFonts.poppins(
                    fontSize: 12, color: AppColors.textHint),
              ),
              SizedBox(width: 12),
              Icon(Icons.access_time_rounded,
                  size: 14, color: AppColors.textHint),
              SizedBox(width: 4),
              Text(_formatTime(current.updatedAt),
                  style: GoogleFonts.poppins(
                      fontSize: 12, color: AppColors.textHint)),
            ]),
            SizedBox(height: 16),

            // Tags
            if (current.tags.isNotEmpty) ...[
              Text('TAGS',
                  style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textHint,
                      letterSpacing: 1)),
              SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ...current.tags.map((t) => _TagChip(tag: t)),
                  _AddTagChip(),
                ],
              ),
              SizedBox(height: 16),
            ],

            // Action toolbar
            Container(
              padding: EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _ActionBtn(
                      icon: Icons.share_outlined, label: 'Share', onTap: () {}),
                  _ActionBtn(
                      icon: Icons.file_upload_outlined,
                      label: 'Export',
                      onTap: () {}),
                  _ActionBtn(
                      icon: Icons.push_pin_outlined,
                      label: 'Pin',
                      onTap: () {}),
                  _ActionBtn(
                      icon: Icons.drive_file_move_outline,
                      label: 'Move',
                      onTap: () {}),
                  _ActionBtn(
                    icon: Icons.delete_outline_rounded,
                    label: 'Delete',
                    color: AppColors.error,
                    onTap: () {
                      provider.moveToTrash(current.id);
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),

            // Content card
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Icon(Icons.description_outlined,
                          color: AppColors.accent, size: 18),
                      SizedBox(width: 8),
                      Text('Overview',
                          style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.accent)),
                    ]),
                    Divider(color: AppColors.divider, height: 20),
                    Text(current.content,
                        style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                            height: 1.6)),
                  ]),
            ),
            SizedBox(height: 16),


            // Timestamps
            Row(children: [
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text('Created',
                        style: GoogleFonts.poppins(
                            fontSize: 11, color: AppColors.textHint)),
                    Text(
                      '${current.createdAt.day}/${current.createdAt.month}/${current.createdAt.year}',
                      style: GoogleFonts.poppins(
                          fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ])),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text('Updated',
                        style: GoogleFonts.poppins(
                            fontSize: 11, color: AppColors.textHint)),
                    Text(
                      '${current.updatedAt.day}/${current.updatedAt.month}/${current.updatedAt.year}',
                      style: GoogleFonts.poppins(
                          fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ])),
            ]),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => EditNoteScreen(note: current))),
        backgroundColor: AppColors.accent,
        elevation: 12,
        label: Text('Edit Note',
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600, color: Colors.white)),
        icon: Icon(Icons.edit_outlined, color: Colors.white),
      ),
    );
  }

  void _showMenu(BuildContext context, NoteModel note, NotesProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardColor,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(
            leading:
                Icon(Icons.edit_outlined, color: AppColors.textPrimary),
            title: Text('Edit Note',
                style: GoogleFonts.poppins(color: AppColors.textPrimary)),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => EditNoteScreen(note: note)));
            },
          ),
          ListTile(
            leading:
                Icon(Icons.share_outlined, color: AppColors.textPrimary),
            title: Text('Share',
                style: GoogleFonts.poppins(color: AppColors.textPrimary)),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: Icon(Icons.delete_outline_rounded,
                color: AppColors.error),
            title: Text('Delete',
                style: GoogleFonts.poppins(color: AppColors.error)),
            onTap: () {
              provider.moveToTrash(note.id);
              Navigator.pop(context);
              Navigator.pop(context);
            },
          ),
        ]),
      ),
    );
  }

  String _monthName(int m) => [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec'
      ][m - 1];

  String _formatTime(DateTime d) {
    final h = d.hour > 12
        ? d.hour - 12
        : d.hour == 0
            ? 12
            : d.hour;
    final min = d.minute.toString().padLeft(2, '0');
    final period = d.hour >= 12 ? 'PM' : 'AM';
    return '$h:$min $period';
  }
}

class _TagChip extends StatelessWidget {
  final String tag;
  const _TagChip({required this.tag});
  @override
  Widget build(BuildContext context) {
    final colors = [
      AppColors.accent,
      Color(0xFF2E7D32),
      Color(0xFF1976D2)
    ];
    final color = colors[tag.length % colors.length];
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(tag,
          style: GoogleFonts.poppins(
              fontSize: 12, color: color, fontWeight: FontWeight.w500)),
    );
  }
}

class _AddTagChip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.add_rounded, size: 14, color: AppColors.textHint),
        SizedBox(width: 4),
        Text('Add Tag',
            style:
                GoogleFonts.poppins(fontSize: 12, color: AppColors.textHint)),
      ]),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;
  const _ActionBtn(
      {required this.icon,
      required this.label,
      required this.onTap,
      this.color});
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: color ?? AppColors.textPrimary, size: 22),
          SizedBox(height: 4),
          Text(label,
              style: GoogleFonts.poppins(
                  fontSize: 11, color: color ?? AppColors.textSecondary)),
        ]),
      );
}
