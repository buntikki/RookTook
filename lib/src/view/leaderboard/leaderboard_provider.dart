import 'dart:convert';
import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:rooktook/src/constants.dart';
import 'package:rooktook/src/model/auth/bearer.dart';
import 'package:rooktook/src/model/auth/session_storage.dart';

final leaderboardProvider = StateNotifierProvider<LeaderboardProvider, LeaderboardState>((ref) {
  return LeaderboardProvider();
});

final fetchLeaderboardUsersProvider = FutureProvider<List<LeaderboardUser>>((ref) async {
  final leaderboardNotifier = ref.read(leaderboardProvider.notifier);
  return await leaderboardNotifier.fetchLeaderboard();
});

class LeaderboardProvider extends StateNotifier<LeaderboardState> {
  LeaderboardProvider() : super(LeaderboardState(users: []));

  Future<List<LeaderboardUser>> fetchLeaderboard() async {
    const storage = SessionStorage();

    final data = await storage.read();
    final headers = {
      'Access-Control-Allow-Origin': '*',
      'Origin': 'https://lichess.dev',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${signBearerToken(data!.token)}',
      'X-API-Key':
          '00033dbbd7e3c2388d922359abe33193012c6fb36f3854706c2a6b1c7187b5154292acc867fb4e54db67635b5d8ef3ce2d58403ac51e15c95cba3e81e48f01b9',
    };
    try {
      final response = await http.get(
        Uri.parse(
          releaseMode
              ? 'https://api.rooktook.com/api/v1/rankings/leaderboard'
              : 'https://dev-api.rooktook.com/api/v1/rankings/leaderboard',
        ),
        headers: headers,
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedResponse =
            jsonDecode(response.body) as Map<String, dynamic>;
        final leaderboardUsers = List<LeaderboardUser>.from(
          (decodedResponse['data'] as List<dynamic>).map(
            (x) => LeaderboardUser.fromJson(x as Map<String, dynamic>),
          ),
        );
        state = state.copyWith(users: leaderboardUsers);
        return leaderboardUsers;
      }
    } catch (e) {
      log(e.toString());
    }
    return [];
  }
}

class LeaderboardState {
  final List<LeaderboardUser> users;

  LeaderboardState({required this.users});

  factory LeaderboardState.initial() {
    return LeaderboardState(users: []);
  }
  LeaderboardState copyWith({List<LeaderboardUser>? users}) {
    return LeaderboardState(users: users ?? this.users);
  }
}

class LeaderboardUser {
  final String id;
  final String name;
  final int rating;
  final bool isPro;

  LeaderboardUser({
    required this.id,
    required this.name,
    required this.rating,
    required this.isPro,
  });

  factory LeaderboardUser.fromJson(Map<String, dynamic> json) {
    return LeaderboardUser(
      id: json['_id'] as String,
      name: json['userId'] as String,
      rating: json['battleRating'] as int,
      isPro: json['isPro'] as bool? ?? false,
    );
  }
}
