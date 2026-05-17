import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/notes_provider.dart';
import '../models/note_model.dart';
import '../theme/app_theme.dart';
import 'package:image_picker/image_picker.dart';

class EditNoteScreen extends StatefulWidget {
  final NoteModel? note;
  const EditNoteScreen({super.key, this.note});
  @override
  State<EditNoteScreen> createState() => _EditNoteScreenState();
}

class _EditNoteScreenState extends State<EditNoteScreen> {
  late TextEditingController _titleCtrl;
  late TextEditingController _contentCtrl;
  late NoteCategory _selectedCategory;
  bool _isSaving = false;
  final int _maxTitleLen = 100;
  final List<String> _undoHistory = [];
  List<String> _tags = [];

  bool get _isEditing => widget.note != null;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.note?.title ?? '');
    _contentCtrl = TextEditingController(text: widget.note?.content ?? '');
    _selectedCategory = widget.note?.category ?? NoteCategory.other;
    _tags = List.from(widget.note?.tags ?? []);
    _undoHistory.add(_contentCtrl.text);
    _contentCtrl.addListener(_onContentChanged);
  }

  void _onContentChanged() {
    final current = _contentCtrl.text;
    if (_undoHistory.isEmpty || _undoHistory.last != current) {
      _undoHistory.add(current);
      if (_undoHistory.length > 100) _undoHistory.removeAt(0);
    }
    setState(() {});
  }

  @override
  void dispose() {
    _contentCtrl.removeListener(_onContentChanged);
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  // ── Undo ──────────────────────────────────────────────────────────────────
  void _undo() {
    if (_undoHistory.length <= 1) return;
    _undoHistory.removeLast();
    final prev = _undoHistory.last;
    _contentCtrl.removeListener(_onContentChanged);
    _contentCtrl.value = TextEditingValue(
      text: prev,
      selection: TextSelection.collapsed(offset: prev.length),
    );
    _contentCtrl.addListener(_onContentChanged);
    setState(() {});
  }

  // ── Save ──────────────────────────────────────────────────────────────────
  Future<void> _save() async {
    if (_titleCtrl.text.trim().isEmpty && _contentCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please enter a title or content', style: GoogleFonts.poppins()),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
      return;
    }
    setState(() => _isSaving = true);
    final provider = context.read<NotesProvider>();
    final title = _titleCtrl.text.trim().isEmpty ? 'Untitled' : _titleCtrl.text.trim();
    final content = _contentCtrl.text.trim();
    if (_isEditing) {
      await provider.updateNote(widget.note!.copyWith(
        title: title, content: content,
        category: _selectedCategory, tags: _tags, updatedAt: DateTime.now(),
      ));
    } else {
      await provider.addNote(title: title, content: content,
          category: _selectedCategory, tags: _tags);
    }
    if (mounted) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Note saved!', style: GoogleFonts.poppins()),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
      Navigator.pop(context);
    }
  }

  // ── Text formatting helpers ───────────────────────────────────────────────
  void _wrapSelection(String prefix, [String? suffix]) {
    final s = suffix ?? prefix;
    final ctrl = _contentCtrl;
    final sel = ctrl.selection;
    final text = ctrl.text;
    if (!sel.isValid) return;
    final selected = sel.textInside(text);
    final before = text.substring(0, sel.start);
    final after = text.substring(sel.end);
    final newText = '$before$prefix$selected$s$after';
    final newSel = TextSelection(
      baseOffset: sel.start + prefix.length,
      extentOffset: sel.start + prefix.length + selected.length,
    );
    ctrl.value = TextEditingValue(text: newText, selection: newSel);
  }

  void _prefixLines(String prefix) {
    final ctrl = _contentCtrl;
    final sel = ctrl.selection;
    final text = ctrl.text;
    if (!sel.isValid) return;
    final before = text.substring(0, sel.start);
    final selected = sel.textInside(text);
    final after = text.substring(sel.end);
    final prefixed = selected.split('\n').map((l) => '$prefix$l').join('\n');
    final newText = '$before$prefixed$after';
    ctrl.value = TextEditingValue(
      text: newText,
      selection: TextSelection(baseOffset: sel.start, extentOffset: sel.start + prefixed.length),
    );
  }

  void _toggleCase(bool toUpper) {
    final ctrl = _contentCtrl;
    final sel = ctrl.selection;
    final text = ctrl.text;
    if (!sel.isValid || sel.isCollapsed) return;
    final selected = sel.textInside(text);
    final converted = toUpper ? selected.toUpperCase() : selected.toLowerCase();
    final before = text.substring(0, sel.start);
    final after = text.substring(sel.end);
    ctrl.value = TextEditingValue(
      text: '$before$converted$after',
      selection: sel,
    );
  }

  void _insertChecklist() {
    final ctrl = _contentCtrl;
    final sel = ctrl.selection;
    final text = ctrl.text;
    final pos = sel.isValid ? sel.end : text.length;
    const insert = '\n☐ ';
    final newText = text.substring(0, pos) + insert + text.substring(pos);
    ctrl.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: pos + insert.length),
    );
  }

  // ── Tag dialog ────────────────────────────────────────────────────────────
  void _showTagDialog() {
    final ctrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(builder: (ctx, setS) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Tags', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          SizedBox(height: 12),
          Wrap(spacing: 8, runSpacing: 8, children: _tags.map((t) => Chip(
            label: Text(t, style: GoogleFonts.poppins(fontSize: 12)),
            backgroundColor: AppColors.accent.withValues(alpha: 0.15),
            deleteIconColor: AppColors.accent,
            onDeleted: () { setS(() => _tags.remove(t)); setState(() {}); },
          )).toList()),
          SizedBox(height: 12),
          Row(children: [
            Expanded(child: TextField(
              controller: ctrl,
              style: GoogleFonts.poppins(color: AppColors.textPrimary),
              decoration: InputDecoration(hintText: 'Add tag...', prefixIcon: Icon(Icons.label_outline_rounded, color: AppColors.accent)),
            )),
            SizedBox(width: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              onPressed: () {
                if (ctrl.text.trim().isNotEmpty) {
                  setS(() => _tags.add(ctrl.text.trim()));
                  setState(() {});
                  ctrl.clear();
                }
              },
              child: Icon(Icons.add_rounded, color: Colors.white),
            ),
          ]),
          SizedBox(height: 12),
          SizedBox(width: double.infinity, child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: EdgeInsets.symmetric(vertical: 14)),
            onPressed: () => Navigator.pop(ctx),
            child: Text('Done', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
          )),
        ]),
      )),
    );
  }

  // ── Reminder dialog ───────────────────────────────────────────────────────
  void _showReminderDialog() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(Duration(hours: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(colorScheme: ColorScheme.dark(primary: AppColors.accent, surface: AppColors.cardColor)),
        child: child!,
      ),
    );
    if (picked != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Reminder set for ${picked.day}/${picked.month}/${picked.year}', style: GoogleFonts.poppins()),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
    }
  }

  // ── Image attachment ─────────────────────────────────────────────────────
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      final ctrl = _contentCtrl;
      final text = ctrl.text;
      final sel = ctrl.selection;
      final pos = sel.isValid ? sel.end : text.length;
      final insert = '\n![Image](${pickedFile.path})\n';
      final newText = text.substring(0, pos) + insert + text.substring(pos);
      
      ctrl.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: pos + insert.length),
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Image attached to note', style: GoogleFonts.poppins()),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final wordCount = _contentCtrl.text.trim().isEmpty
        ? 0 : _contentCtrl.text.trim().split(RegExp(r'\s+')).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: RichText(text: TextSpan(children: [
          TextSpan(text: _isEditing ? 'Edit ' : 'New ',
              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          TextSpan(text: 'Note',
              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.accent)),
        ])),
        actions: [
          if (_isEditing)
            IconButton(
              icon: Icon(Icons.delete_outline_rounded, color: AppColors.error),
              onPressed: () { context.read<NotesProvider>().moveToTrash(widget.note!.id); Navigator.pop(context); },
            ),
          IconButton(icon: Icon(Icons.more_vert_rounded, color: AppColors.textSecondary), onPressed: () {}),
        ],
      ),
      body: Column(children: [
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // ── Title ────────────────────────────────────────────────────
              Container(
                decoration: BoxDecoration(color: AppColors.cardColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
                padding: EdgeInsets.all(14),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Title', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.accent)),
                  SizedBox(height: 6),
                  Row(children: [
                    Expanded(child: TextField(
                      controller: _titleCtrl,
                      maxLength: _maxTitleLen,
                      style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: 'Enter note title...',
                        hintStyle: GoogleFonts.poppins(color: AppColors.textHint, fontSize: 16),
                        border: InputBorder.none, isDense: true,
                        contentPadding: EdgeInsets.zero, counterText: '',
                      ),
                    )),
                    Text('${_titleCtrl.text.length}/$_maxTitleLen',
                        style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textHint)),
                  ]),
                ]),
              ),
              SizedBox(height: 10),

              // ── Content ──────────────────────────────────────────────────
              Container(
                decoration: BoxDecoration(color: AppColors.cardColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
                padding: EdgeInsets.all(14),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Content', style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.accent)),
                  SizedBox(height: 6),
                  TextField(
                    controller: _contentCtrl,
                    maxLines: null, minLines: 10,
                    style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textPrimary, height: 1.7),
                    decoration: InputDecoration(
                      hintText: 'Start writing your note...',
                      hintStyle: GoogleFonts.poppins(color: AppColors.textHint, fontSize: 14),
                      border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text('$wordCount words', style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textHint)),
                  ),
                ]),
              ),
              SizedBox(height: 12),

              // ── Formatting toolbar ────────────────────────────────────────
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                decoration: BoxDecoration(color: AppColors.cardColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(children: [
                    _FmtBtn(icon: Icons.format_bold_rounded, tooltip: 'Bold',
                        onTap: () => _wrapSelection('**')),
                    SizedBox(width: 4),
                    _FmtBtn(icon: Icons.format_italic_rounded, tooltip: 'Italic',
                        onTap: () => _wrapSelection('*')),
                    SizedBox(width: 4),
                    _FmtBtn(icon: Icons.format_underline_rounded, tooltip: 'Underline',
                        onTap: () => _wrapSelection('_')),
                    SizedBox(width: 4),
                    _FmtBtn(icon: Icons.format_list_bulleted_rounded, tooltip: 'Bullet list',
                        onTap: () => _prefixLines('• ')),
                    SizedBox(width: 4),
                    _FmtBtn(icon: Icons.format_list_numbered_rounded, tooltip: 'Numbered list',
                        onTap: () => _prefixLines('1. ')),
                    SizedBox(width: 4),
                    _FmtBtn(icon: Icons.check_box_outline_blank_rounded, tooltip: 'Checklist',
                        onTap: _insertChecklist),
                    SizedBox(width: 4),
                    _FmtBtn(icon: Icons.arrow_upward_rounded, tooltip: 'Uppercase',
                        onTap: () => _toggleCase(true)),
                    SizedBox(width: 4),
                    _FmtBtn(icon: Icons.arrow_downward_rounded, tooltip: 'Lowercase',
                        onTap: () => _toggleCase(false)),
                  ]),
                ),
              ),
              SizedBox(height: 10),

              // ── Action bar (Image / Checklist / Reminder / Tag) ───────────
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(color: AppColors.cardColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(children: [
                    _ActionBtn(icon: Icons.image_outlined, label: 'Image',
                        color: _selectedCategory.color, onTap: _pickImage),
                    SizedBox(width: 16),
                    _ActionBtn(icon: Icons.check_box_outlined, label: 'Checklist',
                        color: AppColors.success, onTap: _insertChecklist),
                    SizedBox(width: 16),
                    _ActionBtn(icon: Icons.notifications_outlined, label: 'Reminder',
                        color: AppColors.warning, onTap: _showReminderDialog),
                    SizedBox(width: 16),
                    _ActionBtn(icon: Icons.label_outline_rounded, label: 'Tag',
                        color: AppColors.accent, onTap: _showTagDialog),
                  ]),
                ),
              ),
              SizedBox(height: 12),

              // ── Tags display ──────────────────────────────────────────────
              if (_tags.isNotEmpty) ...[
                Wrap(spacing: 8, runSpacing: 6, children: _tags.map((t) =>
                  GestureDetector(
                    onTap: _showTagDialog,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.accent.withValues(alpha: 0.3)),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.label_rounded, size: 12, color: AppColors.accent),
                        SizedBox(width: 4),
                        Text(t, style: GoogleFonts.poppins(fontSize: 11, color: AppColors.accent, fontWeight: FontWeight.w500)),
                      ]),
                    ),
                  )
                ).toList()),
                SizedBox(height: 12),
              ],

              // ── Category selector ─────────────────────────────────────────
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: NoteCategory.values.map((cat) {
                    final isSelected = _selectedCategory == cat;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedCategory = cat),
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 200),
                        margin: EdgeInsets.only(right: 8),
                        padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? cat.color : AppColors.cardColor,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: isSelected ? cat.color : AppColors.border),
                        ),
                        child: Row(children: [
                          Icon(cat.icon, size: 14, color: isSelected ? Colors.white : cat.color),
                          SizedBox(width: 6),
                          Text(cat.label, style: GoogleFonts.poppins(
                              fontSize: 12, fontWeight: FontWeight.w600,
                              color: isSelected ? Colors.white : AppColors.textSecondary)),
                        ]),
                      ),
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: 8),
            ]),
          ),
        ),

        // ── Bottom action bar ────────────────────────────────────────────────
        Container(
          padding: EdgeInsets.fromLTRB(16, 10, 16, MediaQuery.of(context).padding.bottom + 12),
          decoration: BoxDecoration(
            color: AppColors.cardColor,
            border: Border(top: BorderSide(color: AppColors.border)),
          ),
          child: Row(children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _undoHistory.length > 1 ? _undo : null,
                icon: Icon(Icons.undo_rounded, size: 18,
                    color: _undoHistory.length > 1 ? AppColors.accent : AppColors.textHint),
                label: Text('Undo', style: GoogleFonts.poppins(
                    color: _undoHistory.length > 1 ? AppColors.accent : AppColors.textHint,
                    fontWeight: FontWeight.w600)),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  side: BorderSide(color: _undoHistory.length > 1 ? AppColors.accent : AppColors.textHint),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _save,
                icon: _isSaving
                    ? SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Icon(Icons.check_rounded, size: 18, color: Colors.white),
                label: Text('Save Note', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 8,
                  shadowColor: AppColors.accent.withValues(alpha: 0.5),
                ),
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}

// ─── Format button ─────────────────────────────────────────────────────────
class _FmtBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;
  const _FmtBtn({required this.icon, required this.onTap, this.tooltip = ''});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: AppColors.surfaceColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: AppColors.textSecondary),
        ),
      ),
    );
  }
}


// ─── Action button (Image / Checklist / Reminder / Tag) ─────────────────────
class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionBtn({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, color: color, size: 20),
        SizedBox(width: 6),
        Text(label, style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary)),
      ]),
    );
  }
}
