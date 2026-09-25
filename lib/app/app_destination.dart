import 'package:flutter/material.dart';

enum AppDestination {
  home(
    label: 'Home',
    icon: Icons.home_outlined,
    selectedIcon: Icons.home_outlined,
  ),
  dua(
    label: 'Dua',
    icon: Icons.volunteer_activism_outlined,
    selectedIcon: Icons.volunteer_activism_outlined,
  ),
  quran(
    label: 'Quran',
    icon: Icons.menu_book_outlined,
    selectedIcon: Icons.menu_book_outlined,
  ),
  calendar(
    label: 'Calendar',
    icon: Icons.calendar_month_outlined,
    selectedIcon: Icons.calendar_month_outlined,
  ),
  more(
    label: 'More',
    icon: Icons.grid_view_outlined,
    selectedIcon: Icons.grid_view_outlined,
  );

  const AppDestination({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}
