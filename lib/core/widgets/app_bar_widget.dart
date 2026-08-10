import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class HematYukAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? avatarUrl;
  final List<Widget>? actions;
  final bool showBack;
  final VoidCallback? onAvatarTap;

  const HematYukAppBar({
    super.key,
    required this.title,
    this.avatarUrl,
    this.actions,
    this.showBack = false,
    this.onAvatarTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: showBack,
      leading: showBack
          ? IconButton(
              icon: const Icon(Icons.arrow_back_rounded,
                  color: AppColors.textPrimary),
              onPressed: () => Navigator.of(context).pop(),
            )
          : Padding(
              padding: const EdgeInsets.only(left: 16),
              child: _buildLogo(),
            ),
      title: Text(title, style: AppTextStyles.headingLarge),
      titleSpacing: showBack ? 0 : 8,
      actions: [
        if (avatarUrl != null || onAvatarTap != null)
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: onAvatarTap,
              child: _buildAvatar(),
            ),
          )
        else if (actions != null)
          ...actions!,
      ],
    );
  }

  Widget _buildLogo() {
    return Image.asset(
      'assets/images/logo.png',
      width: 36,
      height: 36,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) => Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.navy,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.account_balance_wallet_rounded,
            color: Colors.white, size: 18),
      ),
    );
  }

  Widget _buildAvatar() {
    return CircleAvatar(
      radius: 20,
      backgroundColor: AppColors.chipBackground,
      backgroundImage:
          avatarUrl != null ? NetworkImage(avatarUrl!) : null,
      child: avatarUrl == null
          ? const Icon(Icons.person_rounded,
              color: AppColors.textSecondary, size: 22)
          : null,
    );
  }
}
