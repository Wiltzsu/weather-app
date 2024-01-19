import 'package:flutter/material.dart';
import 'package:weather_app/pages/home.dart';
import 'package:weather_app/pages/search.dart';

void main() => runApp(MaterialApp(
  home: Home(),
  routes: {
    '/home': (context) => Home(),
    '/search': (context) => Search(),
  },
));
