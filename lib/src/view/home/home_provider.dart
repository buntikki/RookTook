import 'dart:convert';
import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:rooktook/src/model/auth/bearer.dart';
import 'package:rooktook/src/model/auth/session_storage.dart';
import 'package:rooktook/src/network/http.dart';

final homeProvider = StateNotifierProvider((ref) => HomeProvider());

final fetchHomeBannersProvider = FutureProvider<List<BannerModel>>(
  (ref) => ref.read(homeProvider.notifier).fetchHomeBanners(),
);

class HomeProvider extends StateNotifier<HomeState> {
  HomeProvider() : super(HomeState.initial());

  Future<List<BannerModel>> fetchHomeBanners() async {
    const storage = SessionStorage();
    final data = await storage.read();
    final headers = {
      'Access-Control-Allow-Origin': '*',
      'Origin': 'https://lichess.dev',
      'Authorization': 'Bearer ${signBearerToken(data!.token)}',
    };

    try {
      final response = await http.get(
        Uri.parse('https://api.rooktook.com/api/v1/events'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        log(response.body);
        final Map<String, dynamic> decodedResponse =
            jsonDecode(response.body) as Map<String, dynamic>;
        state = state.copyWith(
          banners: List.from(
            (decodedResponse['data'] as List<dynamic>).map(
              (x) => BannerModel.fromMap(x as Map<String, dynamic>),
            ),
          ),
        );
        return state.banners;
      }
    } catch (e) {
      log('Error fetching tournaments: $e');
    }
    return [];
  }
}

class HomeState {
  final List<BannerModel> banners;
  HomeState({required this.banners});
  factory HomeState.initial() {
    return HomeState(banners: []);
  }

  HomeState copyWith({List<BannerModel>? banners}) {
    return HomeState(banners: banners ?? this.banners);
  }
}

class BannerModel {
  final String id;
  final String imageUrl;
  final String title;
  final String description;
  final String startDate;
  final String endDate;
  final String redirectUrl;
  final BannerEventType eventType;

  BannerModel({
    required this.id,
    required this.imageUrl,
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.redirectUrl,
    required this.eventType,
  });

  factory BannerModel.fromMap(Map<String, dynamic> map) {
    return BannerModel(
      id: map['_id'] as String,
      imageUrl: map['imageUrl'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      startDate: map['startDate'] as String,
      endDate: map['endDate'] as String,
      eventType: nameToEventType(map['eventType'] as String),
      redirectUrl: map['redirectUrl'] as String,
    );
  }
}

enum BannerEventType { tournament, store, wallet, referral, other }

BannerEventType nameToEventType(String type) {
  switch (type) {
    case 'tournament':
      return BannerEventType.tournament;
    case 'store':
      return BannerEventType.store;
    case 'wallet':
      return BannerEventType.wallet;
    case 'referral':
      return BannerEventType.referral;
    default:
      return BannerEventType.other;
  }
}
