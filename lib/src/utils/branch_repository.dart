// ignore_for_file: avoid_classes_with_only_static_members

import 'dart:developer';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rooktook/src/model/auth/auth_session.dart';

class BranchRepository {
  static Future<void> trackCustomEvent(
    String eventName, {
    Map<String, Object>? data,
    required WidgetRef ref,
  }) async {
    final userId = ref.watch(authSessionProvider)?.user.id.value ?? '';
    FlutterBranchSdk.setIdentity(userId);
    final BranchEvent event = BranchEvent.customEvent(eventName);
    if (data != null) {
      data.forEach((key, value) {
        event.addCustomData(key, value);
      });
    }
    final buo = [BranchUniversalObject(canonicalIdentifier: 'flutter')];
    FlutterBranchSdk.trackContent(buo: buo, branchEvent: event);
    log(event.toMap().toString());
    log('identity: ${ref.watch(authSessionProvider)?.user.id.value ?? ''}');
    final analytics = FirebaseAnalytics.instance;
    await analytics.setUserId(id: userId);
    await analytics.logEvent(name: eventName, parameters: data);
  }
}
