import 'package:flutter/material.dart';
import 'ar_engine.dart';

class ARFilterConstants {
  static const List<ARFilter> filters = [
    ARFilter(id: 'none', name: 'Original', icon: '✨', type: FilterType.makeup),
    ARFilter(id: 'classic_red', name: 'Classic Red', icon: '💄', type: FilterType.makeup, primaryColor: Colors.red),
    ARFilter(id: 'nude_glow', name: 'Nude Glow', icon: '🧴', type: FilterType.makeup, primaryColor: Color(0xFFD4A5A5)),
    ARFilter(id: 'pink_blush', name: 'Pink Blush', icon: '🌸', type: FilterType.makeup, primaryColor: Colors.pinkAccent),
    ARFilter(id: 'winged_eyes', name: 'Winged Eyes', icon: '👁️', type: FilterType.makeup, primaryColor: Colors.black87),
    ARFilter(id: 'blonde_hair', name: 'Blonde', icon: '👱‍♀️', type: FilterType.hair, primaryColor: Color(0xFFFAF0BE)),
    ARFilter(id: 'brunette_hair', name: 'Brunette', icon: '👩🏻', type: FilterType.hair, primaryColor: Color(0xFF3B2F2F)),
    ARFilter(id: 'curly_hair', name: 'Curly', icon: '👩🏾‍🦱', type: FilterType.hair, primaryColor: Color(0xFF4B3621)),
    ARFilter(id: 'shades', name: 'Aviators', icon: '🕶️', type: FilterType.accessory, primaryColor: Colors.black),

    // Professional Looks (Composition of multiple effects)
    ARFilter(id: 'look_glam', name: 'Glam Night', icon: '🌟', type: FilterType.look, composition: {
      'lips': Colors.red, 'liner': Colors.black, 'blush': Colors.pinkAccent, 'hair': Color(0xFF3B2F2F)
    }),
    ARFilter(id: 'look_office', name: 'Office Chic', icon: '💼', type: FilterType.look, composition: {
      'lips': Color(0xFFD4A5A5), 'liner': Colors.black87, 'blush': Color(0xFFE5BABA), 'hair': Color(0xFF4B3621)
    }),
    ARFilter(id: 'look_sunset', name: 'Sunset Glow', icon: '🌇', type: FilterType.look, composition: {
      'lips': Colors.orangeAccent, 'liner': Colors.brown, 'blush': Colors.orange, 'hair': Color(0xFFFAF0BE)
    }),
  ];
}
