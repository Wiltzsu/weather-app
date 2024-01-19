import 'package:http/http.dart' as http;
import 'dart:convert';

const String apiKey = 'YOUR_API_KEY'; // Replace with your actual API key

Future<String> fetchDailyForecast() async {
  var url = Uri.parse('https://api.openweathermap.org/data/2.5/onecall?lat=60.1699&lon=24.9384&exclude=current,minutely,hourly&appid=$apiKey');
  var response = await http.get(url);

  if (response.statusCode == 200) {
    var data = json.decode(response.body);

    // Extract daily forecast data
    List<dynamic> dailyForecasts = data['daily'];

    // Display the daily forecast for the next 7 days
    String forecastText = '';
    for (var forecast in dailyForecasts) {
      int timestamp = forecast['dt'];
      DateTime date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
      String weatherDescription = forecast['weather'][0]['description'];
      double maxTemp = forecast['temp']['max'] - 273.15; // Convert to Celsius
      double minTemp = forecast['temp']['min'] - 273.15; // Convert to Celsius

      forecastText += "${date.toLocal()} - $weatherDescription, Max: ${maxTemp.toStringAsFixed(1)}°C, Min: ${minTemp.toStringAsFixed(1)}°C\n";
    }

    return forecastText;
  } else {
    return 'Failed to load daily forecast.';
  }
}
