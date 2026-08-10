import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_bar_widget.dart';
import '../../data/models/category_model.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/transaction_repository.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  String? _localPhotoPath;

  @override
  void initState() {
    super.initState();
    _loadPhoto();
  }

  Future<void> _loadPhoto() async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString('user_photo_path');
    if (path != null && File(path).existsSync()) {
      setState(() => _localPhotoPath = path);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const HematYukAppBar(title: 'Profil'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 100),
        child: Column(
          children: [
            _buildProfileHeader(
              user?.displayName ?? 'User',
              user?.email ?? '',
            ),
            const SizedBox(height: 24),
            _buildMenuSection(context, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(String name, String email) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Stack(
            children: [
              GestureDetector(
                onTap: _pickPhoto,
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    shape: BoxShape.circle,
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x330E6B4F),
                        blurRadius: 16,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: _localPhotoPath != null
                      ? ClipOval(
                          child: Image.file(
                            File(_localPhotoPath!),
                            fit: BoxFit.cover,
                            width: 90,
                            height: 90,
                          ),
                        )
                      : const Icon(Icons.person_rounded, color: Colors.white, size: 48),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _pickPhoto,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryDark,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 14),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(name, style: AppTextStyles.headingMedium),
          const SizedBox(height: 4),
          Text(email, style: AppTextStyles.bodySmall),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () => _showEditProfile(context, ref),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primaryDark,
              side: const BorderSide(color: AppColors.primaryDark),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
            ),
            child: Text('Edit Profil', style: AppTextStyles.labelMedium),
          ),
        ],
      ),
    );
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (picked != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_photo_path', picked.path);
      setState(() => _localPhotoPath = picked.path);
    }
  }

  Widget _buildMenuSection(BuildContext context, WidgetRef ref) {
    final menuItems = [
      _MenuItem(
        icon: Icons.person_outline_rounded,
        label: 'Edit Profil',
        onTap: () => _showEditProfile(context, ref),
      ),
      _MenuItem(
        icon: Icons.category_rounded,
        label: 'Kategori Kustom',
        onTap: () => _showCustomCategories(context),
      ),
      _MenuItem(
        icon: Icons.download_rounded,
        label: 'Ekspor Data',
        subtitle: 'Export ke CSV',
        onTap: () => _showExportDialog(context, ref),
      ),
      _MenuItem(
        icon: Icons.notifications_rounded,
        label: 'Pengaturan Notifikasi',
        onTap: () => _showNotificationSettings(context),
      ),
      _MenuItem(
        icon: Icons.fingerprint_rounded,
        label: 'Keamanan',
        subtitle: 'PIN Aplikasi',
        onTap: () => _showPinSecurity(context),
      ),
      _MenuItem(
        icon: Icons.help_outline_rounded,
        label: 'Bantuan & Tentang',
        onTap: () => _showAbout(context),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Text('Pengaturan', style: AppTextStyles.headingSmall),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.divider),
          ),
          child: Column(
            children: [
              ...menuItems.asMap().entries.map((e) {
                final isLast = e.key == menuItems.length - 1;
                return Column(
                  children: [
                    _buildMenuItem(e.value),
                    if (!isLast)
                      const Divider(height: 1, indent: 60, color: AppColors.divider),
                  ],
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Logout button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    title: Text('Keluar', style: AppTextStyles.headingSmall),
                    content: Text('Apakah kamu yakin ingin keluar?', style: AppTextStyles.bodyMedium),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: Text('Batal',
                            style: AppTextStyles.labelMedium.copyWith(color: AppColors.textSecondary)),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: Text('Keluar',
                            style: AppTextStyles.labelMedium.copyWith(color: AppColors.expense)),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  ref.read(currentUserProvider.notifier).setUser(null);
                  if (context.mounted) context.go('/login');
                }
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.expense,
                side: const BorderSide(color: AppColors.expense),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
              ),
              icon: const Icon(Icons.logout_rounded, size: 20),
              label: Text('Keluar', style: AppTextStyles.labelMedium),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem(_MenuItem item) {
    return ListTile(
      onTap: item.onTap,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.incomeBg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(item.icon, color: AppColors.primaryDark, size: 20),
      ),
      title: Text(item.label, style: AppTextStyles.labelMedium),
      subtitle: item.subtitle != null ? Text(item.subtitle!, style: AppTextStyles.bodySmall) : null,
      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.navInactive, size: 20),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  // ---- EDIT PROFIL ----
  void _showEditProfile(BuildContext context, WidgetRef ref) {
    final user = ref.read(currentUserProvider);
    final nameCtrl = TextEditingController(text: user?.displayName ?? '');
    final emailCtrl = TextEditingController(text: user?.email ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(28),
              topRight: Radius.circular(28),
            ),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('Edit Profil', style: AppTextStyles.headingSmall),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(ctx),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text('Nama', style: AppTextStyles.labelMedium),
              const SizedBox(height: 8),
              TextFormField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  hintText: 'Nama lengkap kamu',
                  prefixIcon: Icon(Icons.person_outline_rounded, color: AppColors.textSecondary),
                ),
              ),
              const SizedBox(height: 16),
              Text('Email', style: AppTextStyles.labelMedium),
              const SizedBox(height: 8),
              TextFormField(
                controller: emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  hintText: 'email@kamu.com',
                  prefixIcon: Icon(Icons.email_outlined, color: AppColors.textSecondary),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () async {
                    final newName = nameCtrl.text.trim();
                    final newEmail = emailCtrl.text.trim();
                    if (newName.isEmpty || newEmail.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Nama dan Email tidak boleh kosong!',
                              style: AppTextStyles.bodyMedium.copyWith(color: Colors.white)),
                          backgroundColor: AppColors.expense,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      return;
                    }
                    await ref.read(currentUserProvider.notifier).updateProfile(
                          displayName: newName,
                          email: newEmail,
                        );
                    if (ctx.mounted) Navigator.pop(ctx);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Profil berhasil diperbarui!',
                              style: AppTextStyles.bodyMedium.copyWith(color: Colors.white)),
                          backgroundColor: AppColors.primaryDark,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      );
                    }
                  },
                  child: Text('Simpan', style: AppTextStyles.headingSmall.copyWith(color: Colors.white)),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  // ---- KATEGORI KUSTOM ----
  void _showCustomCategories(BuildContext context) {
    // Icon list for custom categories
    final List<IconData> icons = [
      Icons.star_rounded, Icons.bolt_rounded, Icons.pets_rounded,
      Icons.home_rounded, Icons.fitness_center_rounded, Icons.sports_soccer_rounded,
      Icons.music_note_rounded, Icons.palette_rounded,
    ];
    final List<Color> colors = [
      const Color(0xFF9C27B0), const Color(0xFF2196F3), const Color(0xFF795548),
      const Color(0xFF607D8B), const Color(0xFFE91E63), const Color(0xFF4CAF50),
      const Color(0xFFFF9800), const Color(0xFF00BCD4),
    ];

    final nameCtrl = TextEditingController();
    int selectedIcon = 0;
    int selectedColor = 0;
    String selectedType = 'expense';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(28),
                topRight: Radius.circular(28),
              ),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Kategori Kustom', style: AppTextStyles.headingSmall),
                    const Spacer(),
                    IconButton(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close_rounded)),
                  ],
                ),
                // Existing custom categories
                if (CategoryModel.customCategories.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text('Kategori Kamu:', style: AppTextStyles.labelMedium),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: CategoryModel.customCategories.map((c) => Chip(
                      avatar: Icon(c.icon, color: c.color, size: 16),
                      label: Text(c.name, style: AppTextStyles.labelSmall),
                      backgroundColor: c.bgColor,
                    )).toList(),
                  ),
                  const Divider(height: 24),
                ],
                Text('Tambah Kategori Baru', style: AppTextStyles.labelMedium),
                const SizedBox(height: 12),
                TextFormField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(hintText: 'Nama kategori...'),
                ),
                const SizedBox(height: 16),
                Text('Jenis:', style: AppTextStyles.bodySmall),
                const SizedBox(height: 8),
                Row(
                  children: ['expense', 'income'].map((t) {
                    final isActive = selectedType == t;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setModalState(() => selectedType = t),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: isActive ? AppColors.primaryDark : AppColors.cardBackground,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            t == 'expense' ? 'Pengeluaran' : 'Pemasukan',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: isActive ? Colors.white : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                Text('Pilih Ikon:', style: AppTextStyles.bodySmall),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  children: List.generate(icons.length, (i) {
                    final isSelected = selectedIcon == i;
                    return GestureDetector(
                      onTap: () => setModalState(() => selectedIcon = i),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: isSelected ? colors[selectedColor] : AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(icons[i],
                            color: isSelected ? Colors.white : AppColors.textSecondary, size: 22),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 16),
                Text('Pilih Warna:', style: AppTextStyles.bodySmall),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  children: List.generate(colors.length, (i) {
                    final isSelected = selectedColor == i;
                    return GestureDetector(
                      onTap: () => setModalState(() => selectedColor = i),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: colors[i],
                          shape: BoxShape.circle,
                          border: isSelected ? Border.all(color: AppColors.textPrimary, width: 2) : null,
                        ),
                        child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 18) : null,
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      if (nameCtrl.text.trim().isEmpty) return;
                      final id = 'custom_${DateTime.now().millisecondsSinceEpoch}';
                      CategoryModel.addCustomCategory(CategoryModel(
                        id: id,
                        name: nameCtrl.text.trim(),
                        icon: icons[selectedIcon],
                        color: colors[selectedColor],
                        bgColor: colors[selectedColor].withOpacity(0.15),
                        type: selectedType,
                      ));
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Kategori "${nameCtrl.text.trim()}" ditambahkan!',
                              style: AppTextStyles.bodyMedium.copyWith(color: Colors.white)),
                          backgroundColor: AppColors.primaryDark,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      );
                    },
                    child: Text('Tambah Kategori',
                        style: AppTextStyles.headingSmall.copyWith(color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---- EKSPOR DATA ----
  void _showExportDialog(BuildContext context, WidgetRef ref) {
    final repo = ref.read(transactionRepositoryProvider);
    final user = ref.read(currentUserProvider);
    final transactions = repo.getAll(user?.uid ?? 'mock_user');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: AppColors.incomeBg, borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.download_rounded, color: AppColors.primaryDark, size: 20),
            ),
            const SizedBox(width: 12),
            Text('Ekspor Data', style: AppTextStyles.headingSmall),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total transaksi: ${transactions.length}', style: AppTextStyles.bodyMedium),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Preview CSV:', style: AppTextStyles.labelSmall.copyWith(color: AppColors.textSecondary)),
                  const SizedBox(height: 6),
                  Text(
                    'Tanggal,Jenis,Kategori,Jumlah,Keterangan\n${transactions.take(3).map((t) {
                      final cat = CategoryModel.findById(t.categoryId);
                      return '${t.date.toString().substring(0, 10)},${t.isIncome ? "Pemasukan" : "Pengeluaran"},${cat.name},${t.amount.toInt()},${t.note}';
                    }).join('\n')}...',
                    style: AppTextStyles.bodySmall.copyWith(fontFamily: 'monospace', fontSize: 10),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Tutup', style: AppTextStyles.labelMedium.copyWith(color: AppColors.textSecondary)),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.pop(ctx);
              await _exportCsv(context, transactions);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryDark,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.file_download_rounded, color: Colors.white, size: 18),
            label: Text('Ekspor CSV', style: AppTextStyles.labelMedium.copyWith(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _exportCsv(BuildContext context, List transactions) async {
    try {
      final buffer = StringBuffer();
      buffer.writeln('ID,Tanggal,Jenis,Kategori,Jumlah (IDR),Keterangan');
      for (final t in transactions) {
        final cat = CategoryModel.findById(t.categoryId);
        final dateStr = t.date.toIso8601String().substring(0, 10);
        final typeStr = t.isIncome ? 'Pemasukan' : 'Pengeluaran';
        final amountStr = t.amount.toStringAsFixed(0);
        final noteStr = '"${t.note.replaceAll('"', '""')}"';
        buffer.writeln('${t.id},$dateStr,$typeStr,${cat.name},$amountStr,$noteStr');
      }

      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/laporan_hematyuk_${DateTime.now().millisecondsSinceEpoch}.csv');
      await file.writeAsString(buffer.toString());

      await Share.shareXFiles([XFile(file.path)], text: 'Laporan Keuangan HematYuk Finance');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text('Data berhasil diekspor! (${transactions.length} transaksi)',
                    style: AppTextStyles.bodyMedium.copyWith(color: Colors.white)),
              ],
            ),
            backgroundColor: AppColors.primaryDark,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengekspor data: $e'),
            backgroundColor: AppColors.expense,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // ---- NOTIFIKASI ----
  void _showNotificationSettings(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    bool dailyReminder = prefs.getBool('notif_daily_enabled') ?? true;
    final int hour = prefs.getInt('notif_hour') ?? 20;
    final int minute = prefs.getInt('notif_minute') ?? 0;
    TimeOfDay reminderTime = TimeOfDay(hour: hour, minute: minute);

    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(topLeft: Radius.circular(28), topRight: Radius.circular(28)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('Notifikasi', style: AppTextStyles.headingSmall),
                  const Spacer(),
                  IconButton(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close_rounded)),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(color: AppColors.incomeBg, borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.notifications_rounded, color: AppColors.primaryDark, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Pengingat Harian', style: AppTextStyles.labelMedium),
                          Text('Ingatkan untuk catat keuangan', style: AppTextStyles.bodySmall),
                        ],
                      ),
                    ),
                    Switch(
                      value: dailyReminder,
                      onChanged: (v) => setModalState(() => dailyReminder = v),
                      activeColor: AppColors.primaryDark,
                    ),
                  ],
                ),
              ),
              if (dailyReminder) ...[
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () async {
                    final picked = await showTimePicker(context: ctx, initialTime: reminderTime);
                    if (picked != null) setModalState(() => reminderTime = picked);
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(color: AppColors.incomeBg, borderRadius: BorderRadius.circular(12)),
                          child: const Icon(Icons.access_time_rounded, color: AppColors.primaryDark, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Waktu Pengingat', style: AppTextStyles.labelMedium),
                              Text('Setiap hari pada jam ini', style: AppTextStyles.bodySmall),
                            ],
                          ),
                        ),
                        Text(
                          '${reminderTime.hour.toString().padLeft(2, '0')}:${reminderTime.minute.toString().padLeft(2, '0')}',
                          style: AppTextStyles.headingSmall.copyWith(color: AppColors.primaryDark),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setBool('notif_daily_enabled', dailyReminder);
                    await prefs.setInt('notif_hour', reminderTime.hour);
                    await prefs.setInt('notif_minute', reminderTime.minute);

                    if (ctx.mounted) Navigator.pop(ctx);
                    if (!context.mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          dailyReminder
                              ? 'Pengingat aktif pukul ${reminderTime.hour.toString().padLeft(2, '0')}:${reminderTime.minute.toString().padLeft(2, '0')}'
                              : 'Pengingat dinonaktifkan',
                          style: AppTextStyles.bodyMedium.copyWith(color: Colors.white),
                        ),
                        backgroundColor: AppColors.primaryDark,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    );
                  },
                  child: Text('Simpan', style: AppTextStyles.headingSmall.copyWith(color: Colors.white)),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  // ---- KEAMANAN PIN ----
  void _showPinSecurity(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final String? currentPin = prefs.getString('app_pin');

    final pinCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    bool obscure1 = true;
    bool obscure2 = true;

    if (!context.mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: StatefulBuilder(
          builder: (ctx, setModalState) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(28), topRight: Radius.circular(28)),
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Keamanan PIN', style: AppTextStyles.headingSmall),
                    const Spacer(),
                    IconButton(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close_rounded)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  currentPin != null && currentPin.isNotEmpty
                      ? 'PIN keamanan saat ini aktif. Masukkan PIN baru untuk mengubah.'
                      : 'Lindungi aplikasi dengan PIN 4 digit.',
                  style: AppTextStyles.bodySmall,
                ),
                const SizedBox(height: 20),
                Text('PIN Baru (4 Digit)', style: AppTextStyles.labelMedium),
                const SizedBox(height: 8),
                TextFormField(
                  controller: pinCtrl,
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  obscureText: obscure1,
                  decoration: InputDecoration(
                    hintText: '••••',
                    prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.textSecondary),
                    suffixIcon: IconButton(
                      icon: Icon(obscure1 ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                          color: AppColors.textSecondary),
                      onPressed: () => setModalState(() => obscure1 = !obscure1),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text('Konfirmasi PIN Baru', style: AppTextStyles.labelMedium),
                const SizedBox(height: 8),
                TextFormField(
                  controller: confirmCtrl,
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  obscureText: obscure2,
                  decoration: InputDecoration(
                    hintText: '••••',
                    prefixIcon: const Icon(Icons.lock_rounded, color: AppColors.textSecondary),
                    suffixIcon: IconButton(
                      icon: Icon(obscure2 ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                          color: AppColors.textSecondary),
                      onPressed: () => setModalState(() => obscure2 = !obscure2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      if (pinCtrl.text.length != 4) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('PIN harus 4 digit!',
                                style: AppTextStyles.bodyMedium.copyWith(color: Colors.white)),
                            backgroundColor: AppColors.expense,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                        return;
                      }
                      if (pinCtrl.text != confirmCtrl.text) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('PIN tidak cocok!',
                                style: AppTextStyles.bodyMedium.copyWith(color: Colors.white)),
                            backgroundColor: AppColors.expense,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                        return;
                      }
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setString('app_pin', pinCtrl.text);
                      if (ctx.mounted) Navigator.pop(ctx);
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(children: [
                            const Icon(Icons.lock_rounded, color: Colors.white, size: 18),
                            const SizedBox(width: 8),
                            Text('PIN berhasil disimpan!',
                                style: AppTextStyles.bodyMedium.copyWith(color: Colors.white)),
                          ]),
                          backgroundColor: AppColors.primaryDark,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryDark,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                    ),
                    icon: const Icon(Icons.fingerprint_rounded, color: Colors.white),
                    label: Text('Simpan PIN', style: AppTextStyles.headingSmall.copyWith(color: Colors.white)),
                  ),
                ),
                if (currentPin != null && currentPin.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.remove('app_pin');
                        if (ctx.mounted) Navigator.pop(ctx);
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('PIN telah dihapus/dinonaktifkan.',
                                style: AppTextStyles.bodyMedium.copyWith(color: Colors.white)),
                            backgroundColor: AppColors.expense,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.expense,
                        side: const BorderSide(color: AppColors.expense),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                      ),
                      icon: const Icon(Icons.lock_open_rounded, size: 18),
                      label: Text('Hapus / Matikan PIN', style: AppTextStyles.labelMedium),
                    ),
                  ),
                ],
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---- BANTUAN & TENTANG ----
  void _showAbout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                'assets/images/logo.png',
                width: 48,
                height: 48,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 26),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('HematYuk', style: AppTextStyles.headingSmall.copyWith(color: AppColors.primaryDark)),
                Text('Finance v1.0.0', style: AppTextStyles.bodySmall),
              ],
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Divider(),
            _AboutRow(icon: Icons.school_rounded, label: 'Mata Kuliah', value: 'Pemrograman Mobile'),
            _AboutRow(icon: Icons.person_rounded, label: 'Dikembangkan oleh', value: 'Mahasiswa'),
            _AboutRow(icon: Icons.code_rounded, label: 'Framework', value: 'Flutter 3.22'),
            _AboutRow(icon: Icons.storage_rounded, label: 'Penyimpanan', value: 'SharedPreferences'),
            _AboutRow(icon: Icons.palette_rounded, label: 'State Management', value: 'Riverpod'),
            const Divider(),
            const SizedBox(height: 8),
            Text(
              'Aplikasi pengelola keuangan harian personal berbasis Flutter. Fitur: Tambah/Edit/Hapus Transaksi, Laporan, Anggaran, dan Riwayat Keuangan.',
              style: AppTextStyles.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryDark,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text('Tutup', style: AppTextStyles.labelMedium.copyWith(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _AboutRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _AboutRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryDark, size: 18),
          const SizedBox(width: 10),
          Text(label, style: AppTextStyles.bodySmall),
          const Spacer(),
          Text(value,
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.primaryDark,
                fontWeight: FontWeight.w600,
              )),
        ],
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final String? subtitle;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    this.subtitle,
    required this.onTap,
  });
}
