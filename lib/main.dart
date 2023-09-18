import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:today_weather/bloc/application_cubit.dart';
import 'package:today_weather/today_weather.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<ApplicationCubit>(create: (_) => ApplicationCubit())
      ],
      child: MaterialApp(
        theme: ThemeData(
          useMaterial3: true,
          primarySwatch: Colors.blue,
        ),
        home: const TodayWeather(),
      ),
    ),
  );
}
