import 'package:flutter/material.dart';

class HabitAssets {
  static const List<String> colors = [
    '#F44336', '#E91E63', '#9C27B0', '#673AB7', '#3F51B5',
    '#2196F3', '#03A9F4', '#00BCD4', '#009688', '#4CAF50',
    '#8BC34A', '#CDDC39', '#FFEB3B', '#FF9800', '#FF5722',
    '#795548', '#607D8B', '#FF8A80'
  ];

  static const Map<String, IconData> icons = {
    'star': Icons.star_rounded,
    'fitness_center': Icons.fitness_center_rounded,
    'directions_run': Icons.directions_run_rounded,
    'directions_bike': Icons.directions_bike_rounded,
    'pool': Icons.pool_rounded,
    'self_improvement': Icons.self_improvement_rounded,
    'monitor_heart': Icons.monitor_heart_rounded,
    'water_drop': Icons.water_drop_rounded,
    'restaurant': Icons.restaurant_rounded,
    'apple': Icons.apple_rounded,
    'book': Icons.menu_book_rounded,
    'edit': Icons.edit_rounded,
    'lightbulb': Icons.lightbulb_rounded,
    'laptop': Icons.laptop_mac_rounded,
    'timer': Icons.timer_rounded,
    'language': Icons.language_rounded,
    'bedtime': Icons.bedtime_rounded,
    'psychology': Icons.psychology_rounded,
    'local_florist': Icons.local_florist_rounded,
    'pets': Icons.pets_rounded,
    'music_note': Icons.music_note_rounded,
    'brush': Icons.brush_rounded,
    'camera': Icons.camera_alt_rounded,
    'home': Icons.home_rounded,
    'cleaning_services': Icons.cleaning_services_rounded,
    'shopping_cart': Icons.shopping_cart_rounded,
    'attach_money': Icons.attach_money_rounded,
    'commute': Icons.directions_bus_rounded,
    'videogame_asset': Icons.videogame_asset_rounded,
    'smoke_free': Icons.smoke_free_rounded,
  };

  static Color hexToColor(String hex) {
    return Color(int.parse(hex.replaceFirst('#', '0xff')));
  }

  static IconData getIconByName(String name) {
    return icons[name] ?? Icons.star_rounded;
  }
}