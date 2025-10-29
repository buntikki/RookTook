import 'dart:convert';
import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:rooktook/src/constants.dart';
import 'package:rooktook/src/model/auth/auth_session.dart';
import 'package:rooktook/src/model/auth/bearer.dart';
import 'package:rooktook/src/model/auth/session_storage.dart';
import 'package:rooktook/src/network/http.dart';

final homeProvider = StateNotifierProvider((ref) => HomeProvider());

final fetchHomeBannersProvider = FutureProvider<List<BannerModel>>(
  (ref) => ref.read(homeProvider.notifier).fetchHomeBanners(),
);
final fetchBattleRatingsProvider = FutureProvider<int>((ref) {
  final session = ref.watch(authSessionProvider);
  if (session != null) {
    return ref.read(homeProvider.notifier).fetchBattleRatings(session.user.name);
  } else {
    return 0;
  }
});

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
        Uri.parse(
          releaseMode
              ? 'https://api.rooktook.com/api/v1/events'
              : 'http://dev-api.rooktook.com/api/v1/events',
        ),
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

  Future<int> fetchBattleRatings(String userId) async {
    const storage = SessionStorage();
    final data = await storage.read();
    final headers = {
      'Access-Control-Allow-Origin': '*',
      'Origin': 'https://lichess.dev',
      'Authorization': 'Bearer ${signBearerToken(data!.token)}',
    };

    try {
      final response = await http.get(
        Uri.parse(
          releaseMode
              ? 'https://api.rooktook.com/api/v1/rankings/player/$userId'
              : 'http://dev-api.rooktook.com/api/v1/rankings/player/$userId',
        ),
        headers: headers,
      );
      if (response.statusCode == 200) {
        log(response.body);
        final Map<String, dynamic> decodedResponse =
            jsonDecode(response.body) as Map<String, dynamic>;
        state = state.copyWith(
          ratings: RatingsModel.fromMap(decodedResponse['data'] as Map<String, dynamic>),
        );
        return state.ratings.battleRating;
      }
    } catch (e) {
      log('Error fetching battleRatings: $e');
    }
    return 0;
  }
}

class HomeState {
  final List<BannerModel> banners;
  final int battleRating;
  final RatingsModel ratings;
  HomeState({required this.banners, required this.battleRating, required this.ratings});
  factory HomeState.initial() {
    return HomeState(
      banners: [],
      battleRating: 0,
      ratings: RatingsModel(
        totalTournamentsWon: 0,
        totalTournamentsPlayed: 0,
        winRate: 0,
        currentStreak: 0,
        battleRating: 0,
        maxStreak: 0,
      ),
    );
  }

  HomeState copyWith({List<BannerModel>? banners, int? battleRating, RatingsModel? ratings}) {
    return HomeState(
      banners: banners ?? this.banners,
      battleRating: battleRating ?? this.battleRating,
      ratings: ratings ?? this.ratings,
    );
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
      redirectUrl: (map['redirectUrl'] ?? '') as String,
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

class RatingsModel {
  final int totalTournamentsWon;
  final int totalTournamentsPlayed;
  final int winRate;
  final int currentStreak;
  final int battleRating;
  final int maxStreak;

  RatingsModel({
    required this.totalTournamentsWon,
    required this.totalTournamentsPlayed,
    required this.winRate,
    required this.currentStreak,
    required this.battleRating,
    required this.maxStreak,
  });

  factory RatingsModel.fromMap(Map<String, dynamic> map) {
    return RatingsModel(
      totalTournamentsWon: double.parse(map['totalTournamentsWon'].toString()).toInt(),
      totalTournamentsPlayed: double.parse(map['totalTournamentsPlayed'].toString()).toInt(),
      winRate: double.parse(map['winRate'].toString()).toInt(),
      currentStreak: double.parse(map['currentStreak'].toString()).toInt(),
      battleRating: double.parse(map['battleRating'].toString()).toInt(),
      maxStreak: double.parse(map['maxStreak'].toString()).toInt(),
    );
  }
}
