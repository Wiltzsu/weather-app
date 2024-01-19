import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

const String apiKey = '5365bcb2d2de8c1a2a310b448e48f72a';

class WeatherData {
  final String date;
  final String temperature;
  final String description;
  final String windSpeed;
  final String iconUrl;

  WeatherData({required this.date, required this.temperature, required this.description, required this.iconUrl, required this.windSpeed});
}


class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  final TextEditingController _searchController = TextEditingController();
  List<WeatherData> searchResults = []; // Updated to store WeatherData objects


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white), // Custom color for the AppBar icons
        title: const Text('City Weather Search', style: TextStyle(color: Colors.white, letterSpacing: 2.0)),
        backgroundColor: Colors.blueGrey[900], // Custom color for the AppBar
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Enter city name',
                  border: OutlineInputBorder( // Adding border
                    borderRadius: BorderRadius.circular(20),
                  ),
                  filled: true, // Enable filling color
                  fillColor: Colors.white,
                  suffixIcon: IconButton(
                    onPressed: () {
                      searchCity(_searchController.text);
                    },
                    icon: const Icon(Icons.search, color: Colors.blueGrey),

                  ),
                ),
              ),
            ),

            ListView.builder(
              padding: const EdgeInsets.all(8),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: searchResults.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.blueGrey[900], // Your desired color
                      borderRadius: BorderRadius.circular(5), // Adjust the radius here
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                            child: Padding( // Add padding here
                              padding: const EdgeInsets.only(left: 36), // Left padding
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    searchResults[index].date,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.lightBlueAccent, // Changed color
                                      shadows: [
                                        Shadow(
                                          offset: Offset(1.0, 1.0),
                                          blurRadius: 3.0,
                                          color: Colors.grey,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 4), // Adjusted spacing
                                  Text(
                                    searchResults[index].temperature,
                                    style: const TextStyle(
                                      fontSize: 20, // Slightly larger font size
                                      fontWeight: FontWeight.w500, // Medium weight
                                      color: Colors.orangeAccent, // Changed color
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    searchResults[index].windSpeed,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.normal,
                                      color: Colors.white60, // Lighter shade of white
                                    ),
                                  ),

                                ],
                              ),
                            ),
                          ),
                          Image.network(
                            searchResults[index].iconUrl,
                            width: 90,
                            height: 70,
                            fit: BoxFit.contain, // Adjust the fit to control the scaling of the image

                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            )

          ],
        ),
      ),
    );
  }




  void searchCity(String cityName) async {
    var url = Uri.parse('https://api.openweathermap.org/data/2.5/forecast?q=$cityName&appid=$apiKey');
    var response = await http.get(url);

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      List<dynamic> forecastList = data['list'];

      List<WeatherData> tempForecastData = [];

      for (var forecast in forecastList.take(30)) {
        int timestamp = forecast['dt'];
        DateTime date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
        String formattedDate = DateFormat('EEEEEEE, HH:mm').format(date); // e.g., Mon, 14:00

        // Get the weather description
        String weatherDescription = forecast['weather'][0]['description'];

        double tempCelsius = forecast['main']['temp'] - 273.15;

        // Extracting wind speed
        double windSpeed = forecast['wind']['speed'];

        // Extracting the icon code and constructing the URL
        String iconCode = forecast['weather'][0]['icon'];
        String iconUrl = 'http://openweathermap.org/img/wn/$iconCode.png';

        String temperature = "${tempCelsius.toStringAsFixed(1)}°C";
        String windSpeedString = "${windSpeed.toStringAsFixed(1)} m/s";


        // Add the formatted weather data to the list
        tempForecastData.add(WeatherData(
            date: formattedDate,
            temperature: temperature,
            windSpeed: windSpeedString,
            description: weatherDescription,
            iconUrl: iconUrl  // Setting the icon URL
        ));
      }

      setState(() {
        searchResults = tempForecastData;
      });
    } else {
      // Handle error or no data scenario
      setState(() {
        searchResults = [WeatherData(date: "", temperature: "", windSpeed: "", description: 'No data found for "$cityName"', iconUrl: "")];
      });
    }
  }



  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
