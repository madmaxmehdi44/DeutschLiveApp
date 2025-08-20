// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

/// یک BottomAppBar با نشانگر متحرک زیر آیتم انتخاب‌شده
class AnimatedBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<NavBarItem> items;

  const AnimatedBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.of(context).size.width;
    final itemCount = items.length;
    final itemWidth = width / itemCount;

    return BottomAppBar(
      color: theme.bottomAppBarTheme.color,
      elevation: 0,
      child: SizedBox(
        height: 75,
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            // نشانگر متحرک
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              left: currentIndex * itemWidth,
              child: Container(
                width: itemWidth,
                height: 4,
                color: theme.colorScheme.secondary,
              ),
            ),

            // آیکون‌ها و برچسب‌ها
            Row(
              children: items.asMap().entries.map((entry) {
                final idx = entry.key;
                final item = entry.value;
                final isSelected = idx == currentIndex;

                return Expanded(
                  child: InkWell(
                    onTap: () => onTap(idx),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          item.icon,
                          size: isSelected ? 28 : 24,
                          color: isSelected
                              ? theme.colorScheme.secondary
                              : theme.disabledColor,
                        ),
                        const SizedBox(height: 60),
                        Text(
                          item.label,
                          style: TextStyle(
                            height: 100.0,
                            fontSize: isSelected ? 14 : 12,
                            color: isSelected
                                ? theme.colorScheme.secondary
                                : theme.disabledColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

/// مدل ساده برای تعریف آیتم‌های ناوبری
class NavBarItem {
  final IconData icon;
  final String label;
  const NavBarItem({required this.icon, required this.label});
}
