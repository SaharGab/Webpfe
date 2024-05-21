import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RecommendationService {
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>> getUserPreferences(String userId) async {
    DocumentSnapshot snapshot =
        await _firestore.collection('Users').doc(userId).get();
    if (snapshot.exists) {
      var data = snapshot.data() as Map<String, dynamic>;
      return data['questionnaire'] ?? {};
    } else {
      debugPrint("No user document found for userId: $userId");
      return {};
    }
  }

  Future<List<DocumentSnapshot>> getRecommendedEvents(
      Map<String, dynamic> preferences) async {
    List<String> categories = determineCategories(preferences);
    QuerySnapshot query = await _firestore
        .collection('events')
        .where('categoryEvent', whereIn: categories)
        .get();

    return query.docs;
  }

  Future<List<DocumentSnapshot>> getRecommendedTouristSites(
      Map<String, dynamic> preferences) async {
    List<String> subcategories = determineActivityCategories(preferences);
    QuerySnapshot query = await _firestore
        .collection('touristSites')
        .where('category', isEqualTo: 'Activities')
        .where('subcategory', whereIn: subcategories)
        .get();

    return query.docs;
  }

  List<String> determineActivityCategories(Map<String, dynamic> preferences) {
    List<String> subcategories = [];
    const Map<String, String> travelTypeToActivitySubcategory = {
      'Adventure Seeker': 'Entertainment',
      'Relaxation Enthusiast': 'Relaxation',
      'Cultural Explorer': 'Cultural',
      'Nature Lover': 'Entertainment',
      'other': 'Entertainment'
    };

    const Map<String, String> activityPreferenceToSubcategory = {
      'Beach Relaxation': 'Relaxation',
      'Sightseeing': 'Cultural',
      'Shopping': 'Entertainment',
      'Hiking': 'Entertainment'
    };

    if (preferences.containsKey('q1')) {
      String travelType = preferences['q1'];
      subcategories
          .add(travelTypeToActivitySubcategory[travelType] ?? 'Entertainment');
    }

    if (preferences.containsKey('q2')) {
      String activityPreference = preferences['q2'];
      subcategories.add(activityPreferenceToSubcategory[activityPreference] ??
          'Entertainment');
    }

    subcategories = subcategories.toSet().toList();
    debugPrint("Mapped activity subcategories: $subcategories");
    return subcategories;
  }

  List<String> determineCategories(Map<String, dynamic> preferences) {
    List<String> categories = [];
    const Map<String, List<String>> travelTypeToCategories = {
      'Adventure Seeker': [
        'Sporting Events - Tournaments',
        'Educational and Environmental Activities - Wildlife Tours'
      ],
      'Relaxation Enthusiast': [
        'Food and Beverage Events - Wine Tastings',
        'Family-Friendly Events - Carnivals'
      ],
      'Cultural Explorer': [
        'Cultural Events - Music Festivals',
        'Cultural Events - Theater Productions'
      ],
      'Nature Lover': [
        'Educational and Environmental Activities - Wildlife Tours'
      ],
      'other': ['Fairs - Craft Fairs', 'Fairs - Trade Fairs']
    };

    if (preferences.containsKey('q1')) {
      String travelType = preferences['q1'];
      categories.addAll(travelTypeToCategories[travelType] ?? []);
    }

    if (preferences.containsKey('q3') &&
        preferences['q3'] is Map<String, dynamic>) {
      Map<String, dynamic> nightlifePreferences = preferences['q3'];
      if (nightlifePreferences['Lounge cafes'] == true) {
        categories.add('Nightlife and Entertainment - DJ Nights');
      }
      if (nightlifePreferences['Themed nightclubs'] == true) {
        categories.add('Nightlife and Entertainment - Themed Parties');
      }
      if (nightlifePreferences['Beach bars'] == true) {
        categories.add('Nightlife and Entertainment - DJ Nights');
      }
      if (nightlifePreferences['Live music restaurants'] == true) {
        categories.add('Nightlife and Entertainment - DJ Nights');
      }
      if (nightlifePreferences['Unique spots'] == true) {
        categories.add('Nightlife and Entertainment - Themed Parties');
      }
    }

    debugPrint("Mapped categories: $categories");
    return categories;
  }

  Future<void> sendNotification(
      String userId, String title, String body) async {
    DocumentSnapshot userSnapshot =
        await _firestore.collection('Users').doc(userId).get();
    if (userSnapshot.exists) {
      String? token = userSnapshot['fcmToken'];
      if (token != null) {
        await _sendFCMMessage(token, title, body);
      }
    }
  }

  Future<void> _sendFCMMessage(String token, String title, String body) async {
    const String serverKey =
        'AIzaSyBw8FKaHnTt_JMrh3mW909I1_EytxLfFi0'; // Remplacez par votre clé de serveur Firebase
    final Uri uri = Uri.parse('https://fcm.googleapis.com/fcm/send');

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'key=$serverKey',
      },
      body: jsonEncode({
        'to': token,
        'notification': {
          'title': title,
          'body': body,
        },
        'data': {
          'click_action': 'FLUTTER_NOTIFICATION_CLICK',
          'message': body,
        },
      }),
    );

    if (response.statusCode != 200) {
      debugPrint('Failed to send FCM message: ${response.statusCode}');
    }
  }
}
