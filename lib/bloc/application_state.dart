import 'package:equatable/equatable.dart';
import 'package:today_weather/models/forecast_data.dart';
import 'package:today_weather/models/weather_data.dart';

class ApplicationState extends Equatable {
  final WeatherData? weatherData;
  final ForecastData? forecastData;
  final String? message;

  const ApplicationState({
    this.weatherData,
    this.forecastData,
    this.message,
  });

  ApplicationState copyWith({
    WeatherData? weatherData,
    ForecastData? forecastData,
    String? message,
  }) {
    return ApplicationState(
      weatherData: weatherData ?? this.weatherData,
      forecastData: forecastData ?? this.forecastData,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [
        weatherData,
        forecastData,
        message,
      ];
}
