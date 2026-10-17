
import 'package:flutter/material.dart';

Color getTypeColor(String type) {
  return switch (type) {
    'Pop' => Colors.blue,
    'Rock' => Colors.orange,
    'Metal' => Colors.red,
    'Indie' => Colors.cyan,
    'R&B Soul' => Colors.purple,
    'EDM' => Colors.grey,
    'Jazz' => Colors.amber,
    'Acoustic / Folk' => Colors.green,
    _ => Colors.blue,
  };
}
