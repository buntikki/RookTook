import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:rooktook/src/model/auth/bearer.dart';
import 'package:rooktook/src/model/auth/session_storage.dart';
import 'package:rooktook/src/model/puzzle/storm.dart';
import 'package:rooktook/src/network/http.dart';

final tournamentProvider = StateNotifierProvider<TournamentNotifier, List<Tournament>>((ref) {
  return TournamentNotifier();
});
final fetchTournamentsProvider = FutureProvider<List<Tournament>>((ref) async {
  final tournamentNotifier = ref.read(tournamentProvider.notifier);
  return await tournamentNotifier.fetchTournaments();
});
final fetchUserTournamentsProvider = FutureProvider<List<Tournament>>((ref) async {
  final tournamentNotifier = ref.read(tournamentProvider.notifier);
  return await tournamentNotifier.fetchUserTournaments();
});
final fetchLeaderboardProvider = FutureProvider.family<List<Player>, String>((ref, id) async {
  final tournamentNotifier = ref.read(tournamentProvider.notifier);
  final tournament = await tournamentNotifier.fetchSingleTournament(id);
  return await tournamentNotifier.sortLeaderboard(tournament?.players ?? []);
});
final fetchLeaderboardProviderWithLoading = FutureProvider.family<List<Player>, String>((
  ref,
  id,
) async {
  final tournamentNotifier = ref.read(tournamentProvider.notifier);
  await Future.delayed(const Duration(seconds: 10));
  final tournament = await tournamentNotifier.fetchSingleTournament(id);
  return await tournamentNotifier.sortLeaderboard(tournament?.players ?? []);
});

class TournamentNotifier extends StateNotifier<List<Tournament>> {
  TournamentNotifier() : super([]);
  Future<List<Tournament>> fetchTournaments() async {
    const storage = SessionStorage();
    final data = await storage.read();
    final headers = {
      'Access-Control-Allow-Origin': '*',
      'Origin': 'https://lichess.dev',
      'Authorization': 'Bearer ${signBearerToken(data!.token)}',
    };

    try {
      final response = await http.get(
        lichessUri('/api/rt-tournament-with-players/active'),
        headers: headers,
      );
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

  Future<List<Tournament>> fetchUserTournaments() async {
    const storage = SessionStorage();
    final data = await storage.read();
    final headers = {
      'Access-Control-Allow-Origin': '*',
      'Origin': 'https://lichess.dev',
      'Authorization': 'Bearer ${signBearerToken(data!.token)}',
    };

    try {
      final response = await http.get(
        lichessUri('/api/rt-tournament-with-players/active/participated'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        log(response.body);
        final Map<String, dynamic> decodedResponse =
            jsonDecode(response.body) as Map<String, dynamic>;
        return (decodedResponse['rtTournaments'] as List<dynamic>)
            .map((x) => Tournament.fromMap(x as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      log('Error fetching user tournaments: $e');
    }
    return [];
  }

  Future<Tournament?> fetchSingleTournament(String id) async {
    print('fetchSingleTournament called');
    const storage = SessionStorage();
    final data = await storage.read();
    final headers = {
      'Access-Control-Allow-Origin': '*',
      'Origin': 'https://lichess.dev',
      'Authorization': 'Bearer ${signBearerToken(data!.token)}',
    };

    try {
      final response = await http.get(
        lichessUri('/api/rt-tournament-details-with-players/$id'),
        headers: headers,
      );
      log(response.body);
      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedResponse =
            jsonDecode(response.body) as Map<String, dynamic>;
        return Tournament.fromMap(decodedResponse['rtTournament'] as Map<String, dynamic>);
      }
    } catch (e) {
      log('Error fetching single tournament: $e');
    }
    return null;
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
    // print(signBearerToken(data!.token));
    try {
      final response = await http.post(
        lichessUri('/api/rt-tournament/join/$id'),
        headers: headers,
        body: jsonEncode({'inviteCode': inviteCode ?? ''}),
      );
      log(response.body);
      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedResponse =
            jsonDecode(response.body) as Map<String, dynamic>;
        return Tournament.fromMap(decodedResponse['rtTournament'] as Map<String, dynamic>);
      }
    } catch (e) {
      log('Error joining tournaments: $e');
    }
    return null;
  }

  Future<bool> fetchTournamentResult({required String id, required StormRunStats stats}) async {
    print('fetchTournamentResult called');
    const storage = SessionStorage();
    final data = await storage.read();
    final headers = {
      'Access-Control-Allow-Origin': '*',
      'Origin': 'https://lichess.dev',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${signBearerToken(data!.token)}',
    };
    // print(signBearerToken(data!.token));
    try {
      final response = await http.put(
        lichessUri('api/rt-tournament/$id/player/result'),
        headers: headers,
        body: json.encode({
          'score': stats.score,
          'combo': stats.comboBest,
          'errors': stats.errors,
          'time': stats.time.inSeconds,
          'puzzles': stats.slowPuzzleIds.length,
          'moves': stats.moves,
        }),
      );
      log(response.body);
      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedResponse =
            jsonDecode(response.body) as Map<String, dynamic>;
        if (decodedResponse['status'] == 'success') {
          return true;
        }
      }
    } catch (e) {
      log('Error fetchting result: $e');
    }
    return false;
  }

  Future<List<Player>> sortLeaderboard(List<Player> players) async {
    players.sort((a, b) {
      return b.rank.compareTo(a.rank);
    });

    return players;
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
  final bool haveParticipated;
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
    required this.haveParticipated,
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
      rewardGoldCoins: map['rewardGoldCoins'] != null ? map['rewardGoldCoins'] as int : 0,
      rewardPool: map['rewardPool'] as String,
      customRules: map['customRules'] as String,
      howToPlay: map['howToPlay'] as String,
      oneTime: map['oneTime'] as bool,
      haveParticipated: map['haveParticipated'] as bool,
      players:
          (map['players'] != null
              ? (map['players'] as List<dynamic>)
                  .map((x) => Player.fromMap(x as Map<String, dynamic>))
                  .toList()
              : []),
    );
  }
}

class Player {
  final String id;
  final String userId;
  final bool active;
  final int puzzles;
  final int score;
  final int moves;
  final int errors;
  final int combo;
  final int time;
  final int rank;
  final int rewardGoldCoins;
  final bool? withdraw;

  Player({
    required this.id,
    required this.userId,
    required this.active,
    required this.puzzles,
    required this.score,
    required this.withdraw,
    required this.combo,
    required this.time,
    required this.rank,
    required this.rewardGoldCoins,
    required this.errors,
    required this.moves,
  });

  factory Player.fromMap(Map<String, dynamic> map) {
    return Player(
      id: map['id'] as String,
      userId: map['userId'] as String,
      active: map['active'] as bool,
      puzzles: map['puzzles'] != null ? map['puzzles'] as int : 0,
      score: map['score'] != null ? map['score'] as int : 0,
      rank: map['rank'] != null ? map['rank'] as int : 0,
      time: map['time'] != null ? map['time'] as int : 0,
      combo: map['combo'] != null ? map['combo'] as int : 0,
      moves: map['moves'] != null ? map['moves'] as int : 0,
      errors: map['errors'] != null ? map['errors'] as int : 0,
      rewardGoldCoins: map['rewardGoldCoins'] != null ? map['rewardGoldCoins'] as int : 0,
      withdraw: map['withdraw'] != null ? map['withdraw'] as bool : null,
    );
  }
}

final tournamentStatusProvider = StateNotifierProvider.family<
  TournamentStatusNotifier,
  TournamentStatus,
  (int startTime, int endTime)
>((ref, times) {
  return TournamentStatusNotifier(startTime: times.$1, endTime: times.$2);
});

class TournamentStatus {
  final bool isStarted;
  final bool isEnded;

  TournamentStatus({required this.isStarted, required this.isEnded});
}

class TournamentStatusNotifier extends StateNotifier<TournamentStatus> {
  TournamentStatusNotifier({required this.startTime, required this.endTime})
    : super(TournamentStatus(isStarted: false, isEnded: false)) {
    _checkStatus();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _checkStatus());
  }

  final int startTime;
  final int endTime;
  Timer? _timer;

  void _checkStatus() {
    final now = DateTime.now();
    final start = DateTime.fromMillisecondsSinceEpoch(startTime);
    final end = DateTime.fromMillisecondsSinceEpoch(endTime);

    state = TournamentStatus(isStarted: now.isAfter(start), isEnded: now.isAfter(end));
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
