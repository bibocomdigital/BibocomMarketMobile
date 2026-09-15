import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

IconData categoryLucideIcon(String name) {
  final value = name.toLowerCase();
  if (value.contains('électro') ||
      value.contains('electro') ||
      value.contains('tech') ||
      value.contains('phone')) {
    return LucideIcons.smartphone;
  }
  if (value.contains('vêt') ||
      value.contains('vetement') ||
      value.contains('mode') ||
      value.contains('habit')) {
    return LucideIcons.shirt;
  }
  if (value.contains('aliment') || value.contains('food') || value.contains('épic')) {
    return LucideIcons.utensils;
  }
  if (value.contains('beauté') || value.contains('beaut') || value.contains('cosm')) {
    return LucideIcons.sparkles;
  }
  if (value.contains('maison') || value.contains('déco') || value.contains('deco')) {
    return LucideIcons.house;
  }
  if (value.contains('sport')) return LucideIcons.dumbbell;
  if (value.contains('jouet') || value.contains('enfant')) return LucideIcons.baby;
  return LucideIcons.tag;
}
