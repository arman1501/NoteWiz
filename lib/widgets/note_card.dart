import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class NoteCard extends StatelessWidget {
  final String id;
  final String title;
  final String preview;
  final String category;
  final Color categoryColor;
  final IconData categoryIcon;
  final bool isFavorite;
  final String timeAgo;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;
  final VoidCallback? onMenuTap;
  final bool isGrid;

  const NoteCard({
    super.key,
    required this.id,
    required this.title,
    required this.preview,
    required this.category,
    required this.categoryColor,
    required this.categoryIcon,
    required this.isFavorite,
    required this.timeAgo,
    required this.onTap,
    required this.onFavoriteToggle,
    this.onMenuTap,
    this.isGrid = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: isGrid ? 0 : 12),
        decoration: BoxDecoration(
          color: AppColors.cardColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: isGrid ? _buildGridLayout() : _buildListLayout(),
        ),
      ),
    );
  }

  Widget _buildListLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icon
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: categoryColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(categoryIcon, color: Colors.white, size: 22),
        ),
        SizedBox(width: 14),
        // Content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 4),
              Text(
                preview,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: categoryColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      category,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: categoryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Spacer(),
                  Icon(Icons.calendar_today_outlined, size: 11, color: AppColors.textHint),
                  SizedBox(width: 4),
                  Text(timeAgo, style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textHint)),
                ],
              ),
            ],
          ),
        ),
        SizedBox(width: 8),
        // Actions
        Column(
          children: [
            GestureDetector(
              onTap: onFavoriteToggle,
              child: Icon(
                isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
                color: isFavorite ? Colors.amber : AppColors.textHint,
                size: 22,
              ),
            ),
            SizedBox(height: 8),
            if (onMenuTap != null)
              GestureDetector(
                onTap: onMenuTap,
                child: Icon(Icons.more_vert_rounded, color: AppColors.textHint, size: 20),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildGridLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: categoryColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(categoryIcon, color: Colors.white, size: 18),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: 6),
            GestureDetector(
              onTap: onFavoriteToggle,
              child: Icon(
                isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
                color: isFavorite ? Colors.amber : AppColors.textHint,
                size: 20,
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        Expanded(
          child: Text(
            preview,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: categoryColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                category,
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: categoryColor,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (onMenuTap != null)
              GestureDetector(
                onTap: onMenuTap,
                child: Icon(Icons.more_vert_rounded, color: AppColors.textHint, size: 18),
              ),
          ],
        ),
      ],
    );
  }
}
