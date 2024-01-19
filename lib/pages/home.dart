import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';


const String apiKey = '5365bcb2d2de8c1a2a310b448e48f72a';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String cityName = "Loading...";
  String weatherDescription = "Loading...";
  String temperature = "Loading...";
  String highLowTemp = "Loading...";

  List<Map<String, String>> forecastData = []; // List to store forecast data

  @override
  void initState() { // This method is called when the state is first created
    super.initState(); // Call the super.initState() method
    fetchWeather(); // Call the fetchWeather() method
    fetchWeatherForecast(); // Call the fetchWeatherForecast() method
  }

  Future<void> fetchWeather() async
  {
    var url = Uri.parse('http://api.openweathermap.org/data/2.5/weather?q=Helsinki&appid=$apiKey'); // Construct the URL
    var response = await http.get(url); // Make the API call

    if (response.statusCode == 200) { // Check if the API call was successful
      var data = json.decode(response.body); // Decode the JSON data

      // Convert temperatures from Kelvin to Celsius
      double tempCelsius = data['main']['temp'] - 273.15;
      double highTempCelsius = data['main']['temp_max'] - 273.15;
      double lowTempCelsius = data['main']['temp_min'] - 273.15;

      setState(() { // Update the state
        cityName = "Helsinki";
        weatherDescription = data['weather'][0]['description'];
        temperature = "${tempCelsius.toStringAsFixed(1)}°C";
        highLowTemp = "H: ${highTempCelsius.toStringAsFixed(1)}°C, L: ${lowTempCelsius.toStringAsFixed(1)}°C";      });
    } else {
      setState(() {
        cityName = 'Failed to load weather data.';
        weatherDescription = '';
        temperature = '';
        highLowTemp = '';
      });
    }
  }

  Future<void> fetchWeatherForecast() async { // This method is called when the state is first created
    var url = Uri.parse('https://api.openweathermap.org/data/2.5/forecast?q=Helsinki&appid=$apiKey');
    var response = await http.get(url); // Make the API call

    if (response.statusCode == 200) { // Check if the API call was successful
      var data = json.decode(response.body); // Decode the JSON data
      List<dynamic> forecastList = data['list'];

      List<Map<String, String>> tempForecastData = []; // Temporary list to store the formatted weather data
      for (var forecast in forecastList) { // Loop through the forecast list
        int timestamp = forecast['dt']; // Extract the timestamp
        DateTime date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000); // Convert the timestamp to a DateTime object

        // Format the date to show the abbreviated weekday and hour
        String formattedDate = DateFormat('E - HH').format(date); // 'E' gives abbreviated weekday, 'HH' gives hour in 24-hour format

        String weatherDescription = forecast['weather'][0]['description']; // Extracting weather description
        String iconCode = forecast['weather'][0]['icon']; // Extracting icon code
        String iconUrl = 'http://openweathermap.org/img/w/$iconCode.png'; // Building the icon URL
        double temp = forecast['main']['temp'] - 273.15; // Extracting temperature

        tempForecastData.add({
          'date': formattedDate, // Now contains the formatted day and hour
          'temp': "${temp.toStringAsFixed(1)}°C",
          'description': weatherDescription,
          'iconUrl': iconUrl // Adding icon URL to the data
        });
      }


      setState(() {
        forecastData = tempForecastData; // Update the state
      });
    } else {
      // Handle the error case
      forecastData = [];
    }
  }


  @override
  Widget build(BuildContext context) {

    // Determine the background image based on weather description
    String? backgroundImage;
    if (weatherDescription.toLowerCase().contains("snow")) {
      backgroundImage = 'lib/assets/snowing.jpg';
    } else if (weatherDescription.toLowerCase().contains("rain")) {
      backgroundImage = 'lib/assets/rain.jpg';
    } else if (weatherDescription.toLowerCase().contains("cloud")) {
      backgroundImage = 'lib/assets/cloudy.jpg';
    } else if (weatherDescription.toLowerCase().contains("clear")) {
      backgroundImage = 'lib/assets/clearsky.jpg';
    } else if (weatherDescription.toLowerCase().contains("thunderstorm")) {
      backgroundImage = 'lib/assets/thunderstorm.jpg';
    } else if (weatherDescription.toLowerCase().contains("mist")) {
      backgroundImage = 'lib/assets/mist.jpg';
    } else {
      backgroundImage = 'lib/assets/clearsky.jpg';
    }

    return Scaffold(
      backgroundColor: Colors.grey[900], // Adding a background color
      body: SafeArea(
        child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [

        const SizedBox(height: 30),

          Container(
            width: double.infinity, // This will make the container take the full width of the screen.
            decoration: BoxDecoration(
              image: backgroundImage != null ? DecorationImage(
                image: AssetImage(backgroundImage),
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.5), // Adjust the opacity
                  BlendMode.darken, // This blend mode will darken the image
                ),
              ) : null,
            ),

            child: Column(
              children: [
                Text(
                  // City Name
                  cityName,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey[200], // Stylish text color
                  ),
                ),

                // Temperature
                Text(
                  temperature,
                  style: const TextStyle(
                    fontSize: 50,
                    fontWeight: FontWeight.w300,
                    color: Colors.deepOrange, // Color for emphasis
                  ),
                ),

                // Weather Description
                Text(
                  weatherDescription,
                  style: const TextStyle(
                    fontSize: 20,
                    fontStyle: FontStyle.italic,
                    color: Colors.blueAccent, // Making it stand out
                  ),
                ),

                // High and Low Temperature
                Text(
                  highLowTemp,
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.orangeAccent, // Subtle color
                  ),
                ),
              ],
            ),
          ),


          const SizedBox(height: 30),

          // Weather Forecast Header
          const Row
            (
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.calendar_today, size: 20, color: Colors.blueGrey), // Matching icon color with text
                SizedBox(width: 8),
                Text(
                  'Weather forecast in Helsinki between 3 hours',
                  style: TextStyle(fontSize: 16, color: Colors.blueGrey), // Consistent color scheme
                ),
              ],
            ),


            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // First Column for Dates
                    Flexible(
                      flex: 1,
                      child: Column(
                        children: forecastData.take(10).map((forecast) => Text(
                            forecast['date'] ?? 'N/A',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.grey[400],
                              shadows: const [
                                Shadow(
                                  offset: Offset(1.0, 1.0),
                                  blurRadius: 3.0,
                                  color: Colors.grey,
                                ),
                              ],
                            )
                        )).toList(),
                      ),
                    ),

                    // Second Column for Temperatures
                    Flexible(
                      flex: 1,
                      child: Column(
                        children: forecastData.take(10).map((forecast) => Text(
                            forecast['temp'] ?? 'N/A',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            )
                        )).toList(),
                      ),
                    ),

                    // Third Column for Descriptions
                    Flexible(
                      flex: 2,
                      child: Column(
                        children: forecastData.take(10).map((forecast) {
                          return forecast['iconUrl'] != null
                              ? Image.network(
                            forecast['iconUrl']!,
                            width: 50, // Set your preferred width
                            height: 29, // Set your preferred height
                            fit: BoxFit.cover, // Use BoxFit to control how the image fits in the box
                          )
                              : const Text('N/A', style: TextStyle(fontSize: 20, color: Colors.grey)); // Fallback if the URL is null
                        }).toList(),
                      ),
                    ),

                  ],
                ),
              ],
            ),


          const SizedBox(height: 20), // Add 10 pixels of height


        // Row 3

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton( // Button to navigate to the search page
                onPressed: () {
                  Navigator.pushNamed(context, '/search');
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: Colors.blueGrey[700], // Foreground color
                  shape: const CircleBorder(), // Circular button
                  padding: const EdgeInsets.all(20), // Padding inside the button
                ),
                child: const Icon(Icons.search),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
                ),
    )
    );
  }
}