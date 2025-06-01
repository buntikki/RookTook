// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import 'package:rooktook/src/model/auth/bearer.dart';
import 'package:rooktook/src/model/auth/session_storage.dart';
import 'package:rooktook/src/network/http.dart';

final referralProvider = StateNotifierProvider<ReferralNotifier, ReferralState>(
  (ref) => ReferralNotifier(),
);
final fetchUserReferralDetails = FutureProvider(
  (ref) => ref.read(referralProvider.notifier).fetchUserReferralDetails(),
);

class ReferralNotifier extends StateNotifier<ReferralState> {
  ReferralNotifier() : super(ReferralState.initial());

  Future<void> getUserReferrals() async {
    const storage = SessionStorage();
    final data = await storage.read();
    final headers = {
      'Access-Control-Allow-Origin': '*',
      'Origin': 'https://lichess.dev',
      'Authorization': 'Bearer ${signBearerToken(data!.token)}',
    };
    try {
      final response = await http.get(lichessUri('/api/rt-referral/all'), headers: headers);
      log(response.body);
      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedResponse =
            jsonDecode(response.body) as Map<String, dynamic>;
        state = state.copyWith(
          referrals:
              (decodedResponse['referrals'] as List<dynamic>)
                  .map((x) => ReferralModel.fromMap(x as Map<String, dynamic>))
                  .toList(),
          referred:
              (decodedResponse['referred'] as List<dynamic>)
                  .map((x) => ReferralModel.fromMap(x as Map<String, dynamic>))
                  .toList(),
        );
        print('hogya kya');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> fetchUserReferralDetails() async {
    const storage = SessionStorage();
    final data = await storage.read();
    final headers = {
      'Access-Control-Allow-Origin': '*',
      'Origin': 'https://lichess.dev',
      'Authorization': 'Bearer ${signBearerToken(data!.token)}',
    };
    try {
      final response = await http.get(lichessUri('/api/rt-referral/details'), headers: headers);
      log(response.body);
      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedResponse =
            jsonDecode(response.body) as Map<String, dynamic>;
        state = state.copyWith(referralDetails: ReferralDetailsModel.fromMap(decodedResponse));
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> createReferral(String referrerId) async {
    const storage = SessionStorage();
    final data = await storage.read();
    final headers = {
      'Access-Control-Allow-Origin': '*',
      'Origin': 'https://lichess.dev',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${signBearerToken(data!.token)}',
    };
    try {
      final response = await http.post(
        lichessUri('/api/rt-referral/create'),
        headers: headers,
        body: jsonEncode({'referrerId': referrerId}),
      );
      log(response.body);
      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedResponse =
            jsonDecode(response.body) as Map<String, dynamic>;

        print(decodedResponse);
      }
    } catch (e) {
      rethrow;
    }
  }
}

class ReferralState {
  final List<ReferralModel> referrals;
  final List<ReferralModel> referred;
  final ReferralDetailsModel referralDetails;

  ReferralState({required this.referrals, required this.referred, required this.referralDetails});
  factory ReferralState.initial() =>
      ReferralState(referrals: [], referred: [], referralDetails: ReferralDetailsModel.initial());

  ReferralState copyWith({
    List<ReferralModel>? referrals,
    List<ReferralModel>? referred,
    ReferralDetailsModel? referralDetails,
  }) {
    return ReferralState(
      referrals: referrals ?? this.referrals,
      referred: referred ?? this.referred,
      referralDetails: referralDetails ?? this.referralDetails,
    );
  }
}

class ReferralModel {
  final String id;
  final String referrerId;
  final String referredId;
  final int createdAt;
  final int updatedAt;
  final bool hasJoinedTournament;
  final bool rewarded;
  final ReferredUserModel referredUser;

  ReferralModel({
    required this.id,
    required this.referrerId,
    required this.referredId,
    required this.createdAt,
    required this.updatedAt,
    required this.hasJoinedTournament,
    required this.rewarded,
    required this.referredUser,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'referrerId': referrerId,
      'referredId': referredId,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'hasJoinedTournament': hasJoinedTournament,
      'rewarded': rewarded,
      'referredUser': referredUser.toMap(),
    };
  }

  factory ReferralModel.fromMap(Map<String, dynamic> map) {
    return ReferralModel(
      id: map['id'] as String,
      referrerId: map['referrerId'] as String,
      referredId: map['referredId'] as String,
      createdAt: map['createdAt'] as int,
      updatedAt: map['updatedAt'] as int,
      hasJoinedTournament: map['hasJoinedTournament'] as bool,
      rewarded: map['rewarded'] as bool,
      referredUser: ReferredUserModel.fromMap(map['referredUser'] as Map<String, dynamic>),
    );
  }
}

class ReferredUserModel {
  final String id;
  final String name;

  ReferredUserModel({required this.id, required this.name});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'id': id, 'name': name};
  }

  factory ReferredUserModel.fromMap(Map<String, dynamic> map) {
    return ReferredUserModel(id: map['id'] as String, name: map['name'] as String);
  }
}

class ReferralDetailsModel {
  final String referralId;
  final ReferralRewardModel referralReward;

  ReferralDetailsModel({required this.referralId, required this.referralReward});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'referralId': referralId, 'referralReward': referralReward.toMap()};
  }

  factory ReferralDetailsModel.initial() => ReferralDetailsModel(
    referralId: '',
    referralReward: ReferralRewardModel(coinType: '', value: 0),
  );
  factory ReferralDetailsModel.fromMap(Map<String, dynamic> map) {
    return ReferralDetailsModel(
      referralId: map['referralId'] as String,
      referralReward: ReferralRewardModel.fromMap(map['referralReward'] as Map<String, dynamic>),
    );
  }
}

class ReferralRewardModel {
  final String coinType;
  final int value;

  ReferralRewardModel({required this.coinType, required this.value});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'coinType': coinType, 'value': value};
  }

  factory ReferralRewardModel.fromMap(Map<String, dynamic> map) {
    return ReferralRewardModel(coinType: map['coinType'] as String, value: map['value'] as int);
  }
}
