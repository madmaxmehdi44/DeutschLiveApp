import 'package:flutter/material.dart';

class MainAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MainAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('تلوزیون همـراه '),
      titleTextStyle:
          const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      centerTitle: true,
      backgroundColor: const Color.fromARGB(255, 165, 33, 82),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
