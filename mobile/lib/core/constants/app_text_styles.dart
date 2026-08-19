import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  // ── Display — Big Shoulders Display ───────────────────────────────────────
  static TextStyle get display => GoogleFonts.bigShouldersDisplay(
        fontSize:   28,
        fontWeight: FontWeight.w800,
        color:      AppColors.textPrimary,
        height:     1.1,
      );

  static TextStyle get h1 => GoogleFonts.bigShouldersDisplay(
        fontSize:   24,
        fontWeight: FontWeight.w700,
        color:      AppColors.textPrimary,
        height:     1.15,
      );

  static TextStyle get h2 => GoogleFonts.bigShouldersDisplay(
        fontSize:   20,
        fontWeight: FontWeight.w700,
        color:      AppColors.textPrimary,
        height:     1.2,
      );

  static TextStyle get h3 => GoogleFonts.inter(
        fontSize:   15,
        fontWeight: FontWeight.w700,
        color:      AppColors.textPrimary,
        height:     1.3,
      );

  // ── Body — Inter ──────────────────────────────────────────────────────────
  static TextStyle get bodyLarge => GoogleFonts.inter(
        fontSize:   15,
        fontWeight: FontWeight.w400,
        color:      AppColors.textPrimary,
        height:     1.5,
      );

  static TextStyle get body => GoogleFonts.inter(
        fontSize:   13,
        fontWeight: FontWeight.w400,
        color:      AppColors.textPrimary,
        height:     1.5,
      );

  static TextStyle get bodySmall => GoogleFonts.inter(
        fontSize:   12,
        fontWeight: FontWeight.w400,
        color:      AppColors.textSecondary,
        height:     1.5,
      );

  // ── Caption ───────────────────────────────────────────────────────────────
  static TextStyle get caption => GoogleFonts.inter(
        fontSize:   11,
        fontWeight: FontWeight.w400,
        color:      AppColors.textSecondary,
        height:     1.4,
      );

  // ── Label mono — IBM Plex Mono ─────────────────────────────────────────────
  static TextStyle get mono => GoogleFonts.ibmPlexMono(
        fontSize:   14,
        fontWeight: FontWeight.w600,
        color:      AppColors.textPrimary,
      );

  static TextStyle get monoSmall => GoogleFonts.ibmPlexMono(
        fontSize:   11,
        fontWeight: FontWeight.w500,
        color:      AppColors.textSecondary,
        letterSpacing: 0.04,
      );

  static TextStyle get monoLabel => GoogleFonts.ibmPlexMono(
        fontSize:   10.5,
        fontWeight: FontWeight.w600,
        color:      AppColors.textSecondary,
        letterSpacing: 0.1,
      );

  // ── Button ────────────────────────────────────────────────────────────────
  static TextStyle get button => GoogleFonts.inter(
        fontSize:   13.5,
        fontWeight: FontWeight.w700,
        color:      AppColors.surface,
        height:     1,
      );
}