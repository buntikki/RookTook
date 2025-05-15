// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

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
    try {
      final response = await http.get(
        Uri.parse('https://play.rooktook.com/api/rt-tournaments/active'),
      );
      if (response.statusCode == 200) {
        final decodedResponse = jsonDecode(response.body) as List;
        return decodedResponse.map((x) => Tournament.fromMap(x as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      log('Error fetching tournaments: $e');
    }
    return [];
  }
}

class Tournament {
  final String startTime;
  final String description;
  final String endTime;
  final String createdAt;
  final int minParticipants;
  final String visibility;
  final String access;
  final int puzzleDuration;
  final int entryCost;
  final String name;
  final String updatedAt;
  final int maxParticipants;
  final String id;

  Tournament({
    required this.startTime,
    required this.description,
    required this.endTime,
    required this.createdAt,
    required this.minParticipants,
    required this.visibility,
    required this.access,
    required this.puzzleDuration,
    required this.entryCost,
    required this.name,
    required this.updatedAt,
    required this.maxParticipants,
    required this.id,
  });

  factory Tournament.fromMap(Map<String, dynamic> map) {
    return Tournament(
      startTime: map['startTime'] as String,
      description: map['description'] as String,
      endTime: map['endTime'] as String,
      createdAt: map['createdAt'] as String,
      minParticipants: map['minParticipants'] as int,
      visibility: map['visibility'] as String,
      access: map['access'] as String,
      puzzleDuration: map['puzzleDuration'] as int,
      entryCost: map['entryCost'] as int,
      name: map['name'] as String,
      updatedAt: map['updatedAt'] as String,
      maxParticipants: map['maxParticipants'] as int,
      id: map['id'] as String,
    );
  }
}
