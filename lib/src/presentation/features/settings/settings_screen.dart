
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../auth/auth_provider.dart';
import 'tax_settings_provider.dart';
import 'store_settings_provider.dart';
import '../../widgets/top_toast.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final pageBackground = theme.scaffoldBackgroundColor;
    final primaryText = colorScheme.onSurface;
    final mutedText = colorScheme.onSurfaceVariant;
    final sectionTitle = colorScheme.primary;
    final cardBorder = colorScheme.outlineVariant;
    final badgeBg = colorScheme.primaryContainer.withOpacity(0.6);
    final cardColor = colorScheme.surface;
    final dangerBg = colorScheme.errorContainer;
    final dangerText = colorScheme.onErrorContainer;
    final themeMode = ref.watch(themeModeProvider);
    final taxSettings = ref.watch(taxSettingsProvider);
    final storeProfile = ref.watch(storeProfileProvider);
    final isAdmin = ref.watch(isAdminProvider);
    final displayName = ref.watch(userDisplayNameProvider);
    final role = ref.watch(userRoleProvider);
    final isDarkMode = themeMode == ThemeMode.dark;
    final taxSubtitle = taxSettings.enabled
        ? 'Aktif (${_formatTaxRate(taxSettings.rate)}%)'
        : 'Nonaktif (${_formatTaxRate(taxSettings.rate)}%)';
    final storeSubtitle =
        '${storeProfile.name}\n${storeProfile.address}';
    final roleLabel = role == UserRole.admin ? 'Administrator' : 'Kasir';

    return Scaffold(
      backgroundColor: pageBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Akun',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: primaryText,
                ),
              ),
              const SizedBox(height: 20),
              _ProfileCard(
                primaryText: primaryText,
                mutedText: mutedText,
                badgeBg: badgeBg,
                borderColor: cardBorder,
                cardColor: cardColor,
                displayName: displayName,
                roleLabel: roleLabel,
              ),
              const SizedBox(height: 24),
              Text(
                'Pengaturan Umum',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: sectionTitle,
                ),
              ),
              const SizedBox(height: 12),
              _SettingsGroupCard(
                borderColor: cardBorder,
                cardColor: cardColor,
                children: [
                  _SettingsTile(
                    icon: Icons.dark_mode_outlined,
                    title: 'Tema Gelap',
                    primaryText: primaryText,
                    mutedText: mutedText,
                    trailing: Switch.adaptive(
                      value: isDarkMode,
                      activeColor: AppTheme.seedColor,
                      onChanged: (value) {
                        ref
                            .read(themeModeProvider.notifier)
                            .setTheme(value ? ThemeMode.dark : ThemeMode.light);
                      },
                    ),
                  ),
                  _TileDivider(color: cardBorder),
                  _SettingsTile(
                    icon: Icons.storefront_outlined,
                    title: 'Profil Toko',
                    subtitle: storeSubtitle,
                    primaryText: primaryText,
                    mutedText: mutedText,
                    trailing: const Icon(Icons.edit, size: 18),
                    onTap: () =>
                        _showStoreProfileDialog(context, ref, storeProfile),
                  ),
                  _TileDivider(color: cardBorder),
                  _SettingsTile(
                    icon: Icons.percent_rounded,
                    title: 'Pajak Transaksi',
                    subtitle: taxSubtitle,
                    primaryText: primaryText,
                    mutedText: mutedText,
                    trailing: Switch.adaptive(
                      value: taxSettings.enabled,
                      activeColor: AppTheme.seedColor,
                      onChanged: (value) => ref
                          .read(taxSettingsProvider.notifier)
                          .setEnabled(value),
                    ),
                    onTap: () =>
                        _showTaxRateDialog(context, ref, taxSettings.rate),
                  ),
                  _TileDivider(color: cardBorder),
                  _SettingsTile(
                    icon: Icons.language,
                    title: 'Bahasa',
                    subtitle: 'Indonesia',
                    primaryText: primaryText,
                    mutedText: mutedText,
                  ),
                  _TileDivider(color: cardBorder),
                  _SettingsTile(
                    icon: Icons.print_outlined,
                    title: 'Printer Struk',
                    subtitle: 'Terhubung: POS-80C',
                    primaryText: primaryText,
                    mutedText: mutedText,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Keamanan & Lainnya',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: sectionTitle,
                ),
              ),
              const SizedBox(height: 12),
              _SettingsGroupCard(
                borderColor: cardBorder,
                cardColor: cardColor,
                children: [
                  _SettingsTile(
                    icon: Icons.lock_outline_rounded,
                    title: 'Ubah Password',
                    primaryText: primaryText,
                    mutedText: mutedText,
                    onTap: () {},
                  ),
                  if (isAdmin) _TileDivider(color: cardBorder),
                  if (isAdmin)
                    _SettingsTile(
                      icon: Icons.group_outlined,
                      title: 'Kelola Pengguna',
                      primaryText: primaryText,
                      mutedText: mutedText,
                      onTap: () => context.push('/users'),
                    ),
                  if (isAdmin) _TileDivider(color: cardBorder),
                  if (isAdmin)
                    _SettingsTile(
                      icon: Icons.category_outlined,
                      title: 'Kategori Produk',
                      primaryText: primaryText,
                      mutedText: mutedText,
                      onTap: () => context.push('/categories'),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () async {
                  final confirmed = await _showLogoutDialog(context);
                  if (confirmed != true) return;
                  await ref.read(authControllerProvider).signOut();
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: dangerBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Keluar Akun',
                    style: TextStyle(
                      color: dangerText,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'Versi Aplikasi 1.0.2 (Build 45)',
                  style: TextStyle(
                    color: mutedText,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool?> _showLogoutDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        return AlertDialog(
          title: const Text('Keluar Akun'),
          content: const Text('Yakin mau keluar dari akun ini?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.error,
                foregroundColor: colorScheme.onError,
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Keluar'),
            ),
          ],
        );
      },
    );
  }

  String _formatTaxRate(double rate) {
    if (rate % 1 == 0) {
      return rate.toInt().toString();
    }
    return rate.toStringAsFixed(2).replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
  }

  Future<void> _showTaxRateDialog(
    BuildContext context,
    WidgetRef ref,
    double currentRate,
  ) async {
    final controller =
        TextEditingController(text: _formatTaxRate(currentRate));
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Atur Pajak'),
          content: TextField(
            controller: controller,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              hintText: 'Contoh: 10',
              suffixText: '%',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );

    if (result != true) return;
    final parsed = double.tryParse(
      controller.text.trim().replaceAll(',', '.'),
    );
    if (parsed == null) {
      showTopToast(
        context,
        message: 'Nilai pajak tidak valid.',
        type: ToastType.error,
      );
      return;
    }
    await ref.read(taxSettingsProvider.notifier).setRate(parsed);
  }

  Future<void> _showStoreProfileDialog(
    BuildContext context,
    WidgetRef ref,
    StoreProfile profile,
  ) async {
    final nameController = TextEditingController(text: profile.name);
    final addressController = TextEditingController(text: profile.address);
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Profil Toko'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Toko',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(
                  labelText: 'Alamat Toko',
                ),
                maxLines: 2,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );

    if (result != true) return;
    final name = nameController.text.trim();
    final address = addressController.text.trim();
    if (name.isEmpty || address.isEmpty) {
      showTopToast(
        context,
        message: 'Nama dan alamat toko wajib diisi.',
        type: ToastType.error,
      );
      return;
    }
    await ref
        .read(storeProfileProvider.notifier)
        .setProfile(name: name, address: address);
    if (context.mounted) {
      showTopToast(
        context,
        message: 'Profil toko berhasil diperbarui.',
        type: ToastType.success,
      );
    }
  }
}

class _ProfileCard extends StatelessWidget {
  final Color primaryText;
  final Color mutedText;
  final Color badgeBg;
  final Color borderColor;
  final Color cardColor;
  final String displayName;
  final String roleLabel;

  const _ProfileCard({
    required this.primaryText,
    required this.mutedText,
    required this.badgeBg,
    required this.borderColor,
    required this.cardColor,
    required this.displayName,
    required this.roleLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 34,
            backgroundImage: NetworkImage(
              'https://images.unsplash.com/photo-1502685104226-ee32379fefbe?auto=format&fit=crop&w=200&q=60',
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: TextStyle(
                    color: primaryText,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    roleLabel,
                    style: TextStyle(
                      color: primaryText,
                      fontWeight: FontWeight.w600,
                    ),
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

class _SettingsGroupCard extends StatelessWidget {
  final List<Widget> children;
  final Color borderColor;
  final Color cardColor;

  const _SettingsGroupCard({
    required this.children,
    required this.borderColor,
    required this.cardColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color primaryText;
  final Color mutedText;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    required this.primaryText,
    required this.mutedText,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceVariant.withOpacity(0.6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: primaryText),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: primaryText,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        color: mutedText,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}

class _TileDivider extends StatelessWidget {
  final Color color;

  const _TileDivider({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      color: color,
      margin: const EdgeInsets.symmetric(horizontal: 16),
    );
  }
}
