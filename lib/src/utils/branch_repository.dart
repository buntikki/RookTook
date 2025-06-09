// ignore_for_file: avoid_classes_with_only_static_members

import 'dart:developer';

import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rooktook/src/model/auth/auth_session.dart';

class BranchRepository {
  static void trackCustomEvent(
    String eventName, {
    Map<String, dynamic>? data,
    required WidgetRef ref,
  }) {
    FlutterBranchSdk.setIdentity(ref.watch(authSessionProvider)?.user.id.value ?? '');
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
  }
}
