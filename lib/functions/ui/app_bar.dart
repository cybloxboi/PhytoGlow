import 'package:flutter/material.dart';

AppBar getAppBar(String title) {
  return AppBar(
    title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
    elevation: 5,
  );
}
