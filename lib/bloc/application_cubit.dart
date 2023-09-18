import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:location/location.dart';
import 'package:today_weather/bloc/application_state.dart';
import 'package:today_weather/models/forecast_data.dart';
import 'package:today_weather/models/weather_data.dart';

class ApplicationCubit extends Cubit<ApplicationState> {
  ApplicationCubit() : super(const ApplicationState());

  void reset() {
    emit(const ApplicationState());
  }

  bool? _isServiceNotEnabled;
  PermissionStatus? _permissionGranted;
  LocationData? _locationData;

  Location location = Location();
  Dio dio = Dio();

  String? message;

  Future<void> loadWeather() async {
    String apiKey = dotenv.env["API_KEY"]!;

    try {
      _isServiceNotEnabled = await location.serviceEnabled();
      if (!_isServiceNotEnabled!) {
        _isServiceNotEnabled = await location.requestService();
        if (!_isServiceNotEnabled!) {
          return;
        }
      }

      _permissionGranted = await location.hasPermission();
      if (_permissionGranted == PermissionStatus.denied) {
        _permissionGranted = await location.requestPermission();
        if (_permissionGranted != PermissionStatus.granted) {
          return;
        }
      }

      _locationData = await location.getLocation();

      final double? lat = _locationData!.latitude;
      final double? lon = _locationData!.longitude;

      WeatherData? weatherData = await _fetchAndSetWeatherData(apiKey, lat, lon);
      ForecastData? forecastData = await _fetchAndSetForcastingData(apiKey, lat, lon);

      emit(
        state.copyWith(
          weatherData: weatherData,
          forecastData: forecastData,
          message: "Done!",
        ),
      );
    } on PlatformException catch (e, _) {
      if (e.code == 'PERMISSION_DENIED') {
        message = 'Permission denied';
      } else if (e.code == 'PERMISSION_DENIED_NEVER_ASK') {
        message = 'Permission denied - please ask the user to enable it from the app settings';
      }

      _locationData = null;
    }
  }

  Future<WeatherData?> _fetchAndSetWeatherData(
    String apiKey,
    double? lat,
    double? lon,
  ) async {
    final weatherResponse = await dio.get(
      'https://api.openweathermap.org/data/2.5/weather?appid=$apiKey&lat=${lat.toString()}&lon=${lon.toString()}',
    );
    if (weatherResponse.statusCode == 200) {
      return WeatherData.fromJson(weatherResponse.data);
    } else {
      return null;
    }
  }

  Future<ForecastData?> _fetchAndSetForcastingData(
    String apiKey,
    double? lat,
    double? lon,
  ) async {
    final forecastResponse = await dio.get(
      'https://api.openweathermap.org/data/2.5/forecast?appid=$apiKey&lat=${lat?.toString()}&lon=${lon?.toString()}',
    );
    if (forecastResponse.statusCode == 200) {
      return ForecastData.fromJson(forecastResponse.data);
    } else {
      return null;
    }
  }
}
