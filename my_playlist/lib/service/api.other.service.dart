import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:my_playlist/models/quote.dart';
import 'package:my_playlist/models/climate.dart';

class ApiService {
  static Future<Quote> fetchQuote() async {
    final url = Uri.parse('https://dummyjson.com/quotes/random');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Quote.fromJson(data);
    } else {
      throw Exception('โหลดคำคมไม่สำเร็จ (${response.statusCode})');
    }
  }

  static Future<Climate> fetchClimate() async {
    final url = Uri.parse(
      'https://api.open-meteo.com/v1/forecast?latitude=13.75&longitude=100.5&current=temperature_2m',
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Climate.fromJson(data);
    } else {
      throw Exception('โหลดคำคมไม่สำเร็จ (${response.statusCode})');
    }
  }
}
