import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'viewmodels/calculator_viewmodel.dart';
import 'views/home/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CalculatorViewModel()),
      ],
      child: MaterialApp(
        title: 'CalcRate',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.amber,
          brightness: Brightness.dark,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}