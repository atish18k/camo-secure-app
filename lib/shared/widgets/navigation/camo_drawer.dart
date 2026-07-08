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
  const CamoDrawer({
    super.key,
    required this.onWorkspaceTap,
    required this.onMyIdentityTap,
    required this.onPairingHubTap,
    required this.onEncryptedHistoryTap,
    required this.onDecryptedHistoryTap,
    required this.onSecurityCenterTap,
    required this.onSettingsTap,
    required this.onAboutTap,
    required this.onLogoutTap,
  });

  final VoidCallback onWorkspaceTap;
  final VoidCallback onMyIdentityTap;
  final VoidCallback onPairingHubTap;
  final VoidCallback onEncryptedHistoryTap;
  final VoidCallback onDecryptedHistoryTap;
  final VoidCallback onSecurityCenterTap;
  final VoidCallback onSettingsTap;
  final VoidCallback onAboutTap;
  final VoidCallback onLogoutTap;

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
                  _DrawerSectionTitle(title: 'Main'),
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
                    title: 'Pairing Hub',
                    onTap: onPairingHubTap,
                  ),
                  CamoSpacing.gapSm,
                  _DrawerSectionTitle(title: 'Records'),
                  _DrawerItem(
                    icon: Icons.lock_outline_rounded,
                    title: 'Encrypted History',
                    onTap: onEncryptedHistoryTap,
                  ),
                  _DrawerItem(
                    icon: Icons.lock_open_rounded,
                    title: 'Decrypted History',
                    onTap: onDecryptedHistoryTap,
                  ),
                  CamoSpacing.gapSm,
                  _DrawerSectionTitle(title: 'System'),
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
                    title: 'About CAMO',
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
          Expanded(
            child: Column(
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
                  'v0.16.0 • Privacy Beyond Encryption',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: CamoTypography.label.copyWith(
                    color: CamoColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Private Widgets
// ---------------------------------------------------------------------------

class _DrawerSectionTitle extends StatelessWidget {
  const _DrawerSectionTitle({
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        CamoSpacing.md,
        CamoSpacing.sm,
        CamoSpacing.md,
        CamoSpacing.xs,
      ),
      child: Text(
        title.toUpperCase(),
        style: CamoTypography.label.copyWith(
          color: CamoColors.textSecondary,
          letterSpacing: 1.1,
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.isDestructive = false,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isDestructive;

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