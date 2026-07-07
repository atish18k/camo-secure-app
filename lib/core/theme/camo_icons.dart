// ---------------------------------------------------------------------------
// Imports
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// Class
// ---------------------------------------------------------------------------

abstract final class CamoIcons {
  const CamoIcons._();

  // ---------------------------------------------------------------------------
  // Sizes
  // ---------------------------------------------------------------------------

  static const double sm = 18;
  static const double md = 22;
  static const double lg = 28;
  static const double xl = 36;

  // ---------------------------------------------------------------------------
  // Navigation
  // ---------------------------------------------------------------------------

  static const IconData menu = Icons.menu_rounded;
  static const IconData dashboard = Icons.dashboard_rounded;

  // ---------------------------------------------------------------------------
  // Pairing
  // ---------------------------------------------------------------------------

  static const IconData pair = Icons.group_add_rounded;
  static const IconData pending = Icons.inbox_rounded;
  static const IconData pairings = Icons.groups_rounded;
  static const IconData disconnect = Icons.link_off_rounded;

  // ---------------------------------------------------------------------------
  // QR
  // ---------------------------------------------------------------------------

  static const IconData scanQr = Icons.qr_code_scanner_rounded;
  static const IconData qr = Icons.qr_code_2_rounded;

  // ---------------------------------------------------------------------------
  // Workspace
  // ---------------------------------------------------------------------------

  static const IconData encode = Icons.lock_rounded;
  static const IconData decode = Icons.lock_open_rounded;

  static const IconData paste = Icons.content_paste_rounded;
  static const IconData clear = Icons.delete_outline_rounded;
  static const IconData copy = Icons.copy_rounded;
  static const IconData share = Icons.share_rounded;
  static const IconData sent = Icons.send_rounded;

  // ---------------------------------------------------------------------------
  // Authentication
  // ---------------------------------------------------------------------------

  static const IconData email = Icons.email_outlined;
  static const IconData password = Icons.lock_outline_rounded;

  static const IconData visibility = Icons.visibility_rounded;
  static const IconData visibilityOff = Icons.visibility_off_rounded;

  // ---------------------------------------------------------------------------
  // Identity
  // ---------------------------------------------------------------------------

  static const IconData identity = Icons.verified_user_outlined;
  static const IconData profile = Icons.person_rounded;

  static const IconData reveal = Icons.visibility_rounded;
  static const IconData hide = Icons.visibility_off_rounded;

  // ---------------------------------------------------------------------------
  // Security
  // ---------------------------------------------------------------------------

  static const IconData security = Icons.security_rounded;
  static const IconData privacy = Icons.privacy_tip_outlined;

  // ---------------------------------------------------------------------------
  // Settings
  // ---------------------------------------------------------------------------

  static const IconData settings = Icons.settings_rounded;
  static const IconData about = Icons.info_outline_rounded;
  static const IconData logout = Icons.logout_rounded;
}