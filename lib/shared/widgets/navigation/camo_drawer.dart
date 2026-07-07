// ---------------------------------------------------------------------------
// Imports
// ---------------------------------------------------------------------------

import 'package:flutter/material.dart';

import '../../../core/theme/camo_colors.dart';
import '../../../core/theme/camo_icons.dart';
import '../../../core/theme/camo_spacing.dart';
import '../../../core/theme/camo_typography.dart';

// ---------------------------------------------------------------------------
// Widget
// ---------------------------------------------------------------------------

class CamoDrawer extends StatelessWidget {
  // ---------------------------------------------------------------------------
  // Constructor
  // ---------------------------------------------------------------------------

  const CamoDrawer({
    super.key,
    required this.onWorkspaceTap,
    required this.onMyIdentityTap,
    required this.onMyPairingsTap,
    required this.onSecurityCenterTap,
    required this.onSettingsTap,
    required this.onAboutTap,
    required this.onLogoutTap,
  });

  // ---------------------------------------------------------------------------
  // Properties
  // ---------------------------------------------------------------------------

  final VoidCallback onWorkspaceTap;
  final VoidCallback onMyIdentityTap;
  final VoidCallback onMyPairingsTap;
  final VoidCallback onSecurityCenterTap;
  final VoidCallback onSettingsTap;
  final VoidCallback onAboutTap;
  final VoidCallback onLogoutTap;

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: CamoColors.surface,
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            CamoSpacing.gapMd,
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _DrawerItem(
                    icon: CamoIcons.dashboard,
                    title: 'Workspace',
                    onTap: onWorkspaceTap,
                  ),
                  _DrawerItem(
                    icon: CamoIcons.identity,
                    title: 'My Identity',
                    onTap: onMyIdentityTap,
                  ),
                  _DrawerItem(
                    icon: CamoIcons.pairings,
                    title: 'My Pairings',
                    onTap: onMyPairingsTap,
                  ),
                  _DrawerItem(
                    icon: CamoIcons.security,
                    title: 'Security Center',
                    onTap: onSecurityCenterTap,
                  ),
                  _DrawerItem(
                    icon: CamoIcons.settings,
                    title: 'Settings',
                    onTap: onSettingsTap,
                  ),
                  _DrawerItem(
                    icon: CamoIcons.about,
                    title: 'About',
                    onTap: onAboutTap,
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            _DrawerItem(
              icon: CamoIcons.logout,
              title: 'Logout',
              onTap: onLogoutTap,
              isDestructive: true,
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Widgets
  // ---------------------------------------------------------------------------

  Widget _buildHeader() {
    return Padding(
      padding: CamoSpacing.card,
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: CamoColors.background,
            child: Icon(
              CamoIcons.identity,
              color: CamoColors.primary,
            ),
          ),
          CamoSpacing.gapHorizontalMd,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'CAMO',
                style: CamoTypography.appTitle.copyWith(
                  color: CamoColors.textPrimary,
                  letterSpacing: 1.2,
                ),
              ),
              Text(
                'Privacy Beyond Encryption',
                style: CamoTypography.label.copyWith(
                  color: CamoColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Private Widget
// ---------------------------------------------------------------------------

class _DrawerItem extends StatelessWidget {
  // ---------------------------------------------------------------------------
  // Constructor
  // ---------------------------------------------------------------------------

  const _DrawerItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.isDestructive = false,
  });

  // ---------------------------------------------------------------------------
  // Properties
  // ---------------------------------------------------------------------------

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isDestructive;

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final Color color =
        isDestructive ? CamoColors.error : CamoColors.textPrimary;

    return ListTile(
      leading: Icon(
        icon,
        color: color,
      ),
      title: Text(
        title,
        style: CamoTypography.bodyStrong.copyWith(
          color: color,
        ),
      ),
      onTap: onTap,
    );
  }
}