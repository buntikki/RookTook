import 'dart:convert';
import 'dart:developer';

import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:rooktook/src/constants.dart';
import 'package:rooktook/src/model/auth/auth_session.dart';
import 'package:rooktook/src/model/auth/bearer.dart';
import 'package:rooktook/src/model/auth/session_storage.dart';
import 'package:rooktook/src/network/http.dart';

final tournamentProvider = StateNotifierProvider<TournamentNotifier, List<Tournament>>((ref) {
  return TournamentNotifier();
});
final fetchTournamentsProvider = FutureProvider<List<Tournament>>((ref) async {
  final tournamentNotifier = ref.read(tournamentProvider.notifier);
  return await tournamentNotifier.fetchTournaments();
});

class TournamentNotifier extends StateNotifier<List<Tournament>> {
  TournamentNotifier() : super([]);
  Future<List<Tournament>> fetchTournaments() async {
    const storage = SessionStorage();
    final data = await storage.read();
    var headers = {
      'Access-Control-Allow-Origin': '*',
      'Origin': 'https://lichess.dev',
      'Authorization': 'Bearer ${signBearerToken(data!.token)}',
    };

    try {
      final response = await http.get(lichessUri('/api/rt-tournament/active'), headers: headers);
      if (response.statusCode == 200) {
        log(response.body);
        final Map<String, dynamic> decodedResponse =
            jsonDecode(response.body) as Map<String, dynamic>;
        return (decodedResponse['rtTournaments'] as List<dynamic>)
            .map((x) => Tournament.fromMap(x as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      log('Error fetching tournaments: $e');
    }
    return [];
  }

  Future<Tournament?> joinTournament({required String id, String? inviteCode}) async {
    const storage = SessionStorage();
    final data = await storage.read();
    final headers = {
      'Access-Control-Allow-Origin': '*',
      'Origin': 'https://lichess.dev',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${signBearerToken(data!.token)}',
    };
    print(signBearerToken(data!.token));
    try {
      final response = await http.post(
        lichessUri('/api/rt-tournament/join/$id'),
        headers: headers,
        body: inviteCode != null ? jsonEncode({}) : null,
      );
      log(response.body);
      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedResponse =
            jsonDecode(response.body) as Map<String, dynamic>;
        return Tournament.fromMap(decodedResponse);
      }
    } catch (e) {
      log('Error joining tournaments: $e');
    }
    return null;
  }
}

class Tournament {
  final int startTime;
  final String description;
  final int endTime;
  final int minParticipants;
  final String visibility;
  final String access;
  final int puzzleDuration;
  final int entrySilverCoins;
  final String name;
  final int maxParticipants;
  final int rewardGoldCoins;
  final bool oneTime;
  final String id;
  final String rewardPool;
  final String customRules;
  final String howToPlay;
  final List<Player> players;

  Tournament({
    required this.startTime,
    required this.description,
    required this.endTime,
    required this.minParticipants,
    required this.visibility,
    required this.access,
    required this.puzzleDuration,
    required this.entrySilverCoins,
    required this.name,
    required this.maxParticipants,
    required this.id,
    required this.oneTime,
    required this.rewardPool,
    required this.rewardGoldCoins,
    required this.customRules,
    required this.howToPlay,
    required this.players,
  });

  factory Tournament.fromMap(Map<String, dynamic> map) {
    return Tournament(
      startTime: map['startTime'] as int,
      description: map['description'] as String,
      endTime: map['endTime'] as int,
      minParticipants: map['minParticipants'] as int,
      visibility: map['visibility'] as String,
      access: map['access'] as String,
      puzzleDuration: map['puzzleDuration'] as int,
      entrySilverCoins: map['entrySilverCoins'] as int,
      name: map['name'] as String,
      maxParticipants: map['maxParticipants'] as int,
      id: map['id'] as String,
      rewardGoldCoins: map['rewardGoldCoins'] as int,
      rewardPool: map['rewardPool'] as String,
      customRules: map['customRules'] as String,
      howToPlay: map['howToPlay'] as String,
      oneTime: map['oneTime'] as bool,
      players:
          (map['players'] != null
              ? (map['players'] as List<dynamic>).map(
                    (x) => Player.fromMap(x as Map<String, dynamic>),
                  )
                  as List<Player>
              : []),
    );
  }
}

class Player {
  final String id;
  final String userId;
  final bool active;
  final int rating;
  final int? score;
  final bool? withdraw;

  Player({
    required this.id,
    required this.userId,
    required this.active,
    required this.rating,
    required this.score,
    required this.withdraw,
  });

  factory Player.fromMap(Map<String, dynamic> map) {
    return Player(
      id: map['id'] as String,
      userId: map['userId'] as String,
      active: map['active'] as bool,
      rating: map['rating'] as int,
      score: map['score'] != null ? map['score'] as int : null,
      withdraw: map['withdraw'] != null ? map['withdraw'] as bool : null,
    );
  }
}
