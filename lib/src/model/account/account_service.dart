import 'dart:async';

import 'package:flutter/material.dart' show Navigator, Text, showAdaptiveDialog;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rooktook/src/binding.dart' show LichessBinding;
import 'package:rooktook/src/model/account/account_repository.dart';
import 'package:rooktook/src/model/auth/auth_session.dart';
import 'package:rooktook/src/model/common/id.dart';
import 'package:rooktook/src/model/notifications/notification_service.dart';
import 'package:rooktook/src/model/notifications/notifications.dart'
    show LocalNotification, PlaybanNotification;
import 'package:rooktook/src/model/user/user.dart' show TemporaryBan, User;
import 'package:rooktook/src/navigation.dart' show currentNavigatorKeyProvider;
import 'package:rooktook/src/network/http.dart';
import 'package:rooktook/src/view/play/playban.dart';
import 'package:rooktook/src/widgets/platform_alert_dialog.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'account_service.g.dart';

@Riverpod(keepAlive: true)
AccountService accountService(Ref ref) {
  final service = AccountService(ref);
  ref.onDispose(() {
    service.dispose();
  });
  return service;
}

class AccountService {
  AccountService(this._ref);

  ProviderSubscription<AsyncValue<User?>>? _accountProviderSubscription;
  StreamSubscription<(NotificationResponse, LocalNotification)>? _notificationResponseSubscription;

  final Ref _ref;

  static const _storageKey = 'account.playban_notification_date';

  void start() {
    final prefs = LichessBinding.instance.sharedPreferences;

    _accountProviderSubscription = _ref.listen(accountProvider, (_, account) {
      final playban = account.valueOrNull?.playban;
      final storedDate = prefs.getString(_storageKey);
      final lastPlaybanNotificationDate = storedDate != null ? DateTime.parse(storedDate) : null;

      if (playban != null && lastPlaybanNotificationDate != playban.date) {
        _savePlaybanNotificationDate(playban.date);
        _ref.read(notificationServiceProvider).show(PlaybanNotification(playban));
      } else if (playban == null && lastPlaybanNotificationDate != null) {
        _ref
            .read(notificationServiceProvider)
            .cancel(lastPlaybanNotificationDate.toIso8601String().hashCode);
        _clearPlaybanNotificationDate();
      }
    });

    _notificationResponseSubscription = NotificationService.responseStream.listen((data) {
      final (_, notification) = data;
      switch (notification) {
        case PlaybanNotification(:final playban):
          _onPlaybanNotificationResponse(playban);
        case _:
          break;
      }
    });
  }

  void _savePlaybanNotificationDate(DateTime date) {
    LichessBinding.instance.sharedPreferences.setString(_storageKey, date.toIso8601String());
  }

  void _clearPlaybanNotificationDate() {
    LichessBinding.instance.sharedPreferences.remove(_storageKey);
  }

  void dispose() {
    _accountProviderSubscription?.close();
    _notificationResponseSubscription?.cancel();
  }

  Future<void> _onPlaybanNotificationResponse(TemporaryBan playban) async {
    final context = _ref.read(currentNavigatorKeyProvider).currentContext;
    if (context == null || !context.mounted) return;

    return showAdaptiveDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return PlatformAlertDialog(
          content: PlaybanMessage(playban: playban, centerText: true),
          actions: [
            PlatformDialogAction(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> setGameBookmark(GameId id, {required bool bookmark}) async {
    final session = _ref.read(authSessionProvider);
    if (session == null) return;

    await _ref.withClient((client) => AccountRepository(client).bookmark(id, bookmark: bookmark));

    _ref.invalidate(accountProvider);
  }
}
