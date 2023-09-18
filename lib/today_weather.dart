import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:today_weather/bloc/application_cubit.dart';
import 'package:today_weather/bloc/application_state.dart';
import 'package:today_weather/models/forecast_data.dart';
import 'package:today_weather/models/weather_data.dart';
import 'package:today_weather/widgets/current_weather_section.dart';
import 'package:today_weather/widgets/forecast_weather_section.dart';
import 'package:today_weather/widgets/refresh_button.dart';

class TodayWeather extends StatefulWidget {
  const TodayWeather({super.key});

  @override
  State<StatefulWidget> createState() => _TodayWeatherState();
}

class _TodayWeatherState extends State<TodayWeather> {
  // Variables
  bool isLoading = false;

  late ApplicationCubit applicationCubit;

  @override
  void initState() {
    super.initState();
    applicationCubit = context.read<ApplicationCubit>();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await applicationCubit.loadWeather();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ApplicationCubit, ApplicationState>(
      listenWhen: (previous, current) => current.message != previous.message,
      listener: (context, state) {
        if (state.message != null) {
          showDialog(
            context: context,
            barrierDismissible: true,
            builder: (context) => AlertDialog(
              title: Text(state.message!),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.blueGrey,
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                BlocSelector<ApplicationCubit, ApplicationState, WeatherData?>(
                  selector: (state) => state.weatherData,
                  builder: (context, weatherData) => CurrentWeather(
                    weatherData: weatherData,
                  ),
                ),
                RefreshButton(
                  isLoading: isLoading,
                  onPressed: () async {
                    setState(() {
                      isLoading = true;
                    });

                    // data = await TodayWeatherController().loadWeather();
                    // if (data != null && data!['code'] == 200) {
                    //   weatherData = data!['weatherData'];
                    //   forecastData = data!['forecastData'];
                    // }

                    setState(() {
                      isLoading = false;
                    });
                  },
                ),
                // TODO: Refactor this section into widgets
                BlocSelector<ApplicationCubit, ApplicationState, ForecastData?>(
                  selector: (state) => state.forecastData,
                  builder: (context, forecastData) => ForecaseWeaterSection(
                    forecastData: forecastData,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
