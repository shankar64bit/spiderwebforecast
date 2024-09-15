import 'package:flutter/material.dart';

AppbarDesign(String title) {
  return AppBar(
    title: Text(title),
    flexibleSpace: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.deepPurple, Colors.blue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    ),
  );
}

AppbarDesignBackgraound() {
  return Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [Colors.deepPurple, Colors.blue],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
  );
}
