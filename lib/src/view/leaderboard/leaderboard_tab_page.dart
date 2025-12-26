import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:random_avatar/random_avatar.dart';
import 'package:rooktook/src/model/auth/auth_session.dart';
import 'package:rooktook/src/view/home/iap_provider.dart';
import 'package:rooktook/src/view/leaderboard/leaderboard_provider.dart';

class LeaderboardTabPage extends ConsumerStatefulWidget {
  const LeaderboardTabPage({super.key});

  @override
  ConsumerState<LeaderboardTabPage> createState() => _LeaderboardTabPageState();
}

class _LeaderboardTabPageState extends ConsumerState<LeaderboardTabPage> {
  @override
  Widget build(BuildContext context) {
    final userId = ref.watch(authSessionProvider)?.user.id.value;
    final leaderboardPr = ref.watch(fetchLeaderboardUsersProvider);
    final isAvailableRemote = ref.watch(iapProvider).isAvailableRemote;
    return Scaffold(
      appBar: AppBar(title: const Text('Leaderboard')),
      body: leaderboardPr.when(
        data: (data) {
          if (data.isEmpty) {
            return const Center(child: Text('No data found'));
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(fetchLeaderboardUsersProvider);
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: const LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [Color(0xff3C3C3C), Color(0xff222222)],
                  ),
                ),
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Row(
                        spacing: 24,
                        children: [
                          Text('Rank'),
                          SizedBox(),
                          Expanded(flex: 1, child: Text('Name')),
                          Text('Battle Rating'),
                        ],
                      ),
                    ),
                    const Divider(color: Colors.white12, height: 0),
                    ListView.separated(
                      padding: EdgeInsets.zero,
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        final user = data[index];
                        final isCurrentUser = user.name == userId;
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          decoration: BoxDecoration(
                            color: isCurrentUser ? Colors.white : null,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            spacing: 16,
                            children: [
                              Container(
                                width: 36,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6),
                                  color:
                                      isCurrentUser
                                          ? const Color(0xffDFDFDF)
                                          : const Color(0xff2E3137),
                                  border: Border.all(width: .5, color: const Color(0xff464A4F)),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  '#${index + 1}',
                                  style: TextStyle(
                                    color: isCurrentUser ? const Color(0xff565656) : Colors.white,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Row(
                                  spacing: 8,
                                  children: [
                                    RandomAvatar(user.id, height: 32, width: 32),
                                    Expanded(
                                      child: Row(
                                        spacing: 8,
                                        children: [
                                          Flexible(
                                            child: Text(
                                              user.name.length > 16
                                                  ? '${user.name.substring(0, 16)}...'
                                                  : user.name,
                                              style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                color:
                                                    isCurrentUser
                                                        ? const Color(0xff2F2F2F)
                                                        : Colors.white,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          if (user.isPro && isAvailableRemote)
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              spacing: 4,
                                              children: [
                                                SvgPicture.asset(
                                                  'assets/images/svg/pro_icon.svg',
                                                  height: 12,
                                                ),
                                                const Text(
                                                  'PRO',
                                                  style: TextStyle(
                                                    color: Color(0xff54C339),
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w800,
                                                  ),
                                                ),
                                              ],
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Text(
                                user.rating.toString(),
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: isCurrentUser ? const Color(0xff2F2F2F) : Colors.white,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      separatorBuilder:
                          (context, index) => const Divider(color: Colors.white12, height: 0),
                      itemCount: data.length,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        error: (error, stackTrace) => const SizedBox.shrink(),
        loading: () => const Center(child: CircularProgressIndicator.adaptive()),
      ),
    );
  }
}
