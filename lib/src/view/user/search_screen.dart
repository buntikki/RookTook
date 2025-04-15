import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rooktook/src/constants.dart';
import 'package:rooktook/src/model/user/search_history.dart';
import 'package:rooktook/src/model/user/user.dart';
import 'package:rooktook/src/model/user/user_repository_providers.dart';
import 'package:rooktook/src/utils/l10n_context.dart';
import 'package:rooktook/src/utils/navigation.dart';
import 'package:rooktook/src/utils/rate_limit.dart';
import 'package:rooktook/src/widgets/buttons.dart';
import 'package:rooktook/src/widgets/feedback.dart';
import 'package:rooktook/src/widgets/list.dart';
import 'package:rooktook/src/widgets/platform.dart';
import 'package:rooktook/src/widgets/platform_search_bar.dart';
import 'package:rooktook/src/widgets/user_list_tile.dart';

const _kSaveHistoryDebouncTimer = Duration(seconds: 2);

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({this.onUserTap});

  final void Function(LightUser)? onUserTap;

  static Route<dynamic> buildRoute(BuildContext context, {void Function(LightUser)? onUserTap}) {
    return buildScreenRoute(
      context,
      screen: SearchScreen(onUserTap: onUserTap),
      fullscreenDialog: true,
    );
  }

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();
  final saveHistoryDebouncer = Debouncer(_kSaveHistoryDebouncTimer);
  String? _term;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    super.dispose();
    _searchController.dispose();
  }

  void _onSearchChanged() {
    if (!context.mounted) {
      return;
    }
    final term = _searchController.text;
    if (term.length >= 3) {
      ref.read(autoCompleteUserProvider(term));
      setState(() {
        _term = term;
      });
      saveHistoryDebouncer.call(() {
        ref.read(searchHistoryProvider.notifier).saveTerm(term);
      });
    } else {
      setState(() {
        _term = null;
      });
    }
  }

  // ignore: use_setters_to_change_properties
  void setSearchText(String text) {
    _searchController.text = text;
  }

  @override
  Widget build(BuildContext context) {
    final searchBar = PlatformSearchBar(
      hintText: context.l10n.searchSearch,
      controller: _searchController,
      autoFocus: true,
    );

    final body = _Body(_term, setSearchText, widget.onUserTap);

    return PlatformWidget(
      androidBuilder:
          (context) => Scaffold(
            appBar: AppBar(
              toolbarHeight: 80, // Custom height to fit the search bar
              title: searchBar,
            ),
            body: body,
          ),
      iosBuilder:
          (context) => CupertinoPageScaffold(
            navigationBar: CupertinoNavigationBar(
              automaticallyImplyLeading: false,
              middle: SizedBox(height: 36.0, child: searchBar),
              trailing: NoPaddingTextButton(
                child: Text(context.l10n.close),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            child: body,
          ),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body(this.term, this.onRecentSearchTap, this.onUserTap);

  final String? term;
  final void Function(String) onRecentSearchTap;
  final void Function(LightUser)? onUserTap;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (term != null) {
      return SafeArea(child: _UserList(term!, onUserTap));
    } else {
      final searchHistory = ref.watch(searchHistoryProvider).history;
      return SafeArea(
        child: SingleChildScrollView(
          child:
              searchHistory.isEmpty
                  ? kEmptyWidget
                  : ListSection(
                    header: Text(context.l10n.mobileRecentSearches),
                    headerTrailing: NoPaddingTextButton(
                      child: Text(context.l10n.mobileClearButton),
                      onPressed: () => ref.read(searchHistoryProvider.notifier).clear(),
                    ),
                    showDividerBetweenTiles: true,
                    hasLeading: true,
                    children:
                        searchHistory
                            .map(
                              (term) => PlatformListTile(
                                leading: const Icon(Icons.history),
                                title: Text(term),
                                onTap: () => onRecentSearchTap(term),
                              ),
                            )
                            .toList(),
                  ),
        ),
      );
    }
  }
}

class _UserList extends ConsumerWidget {
  const _UserList(this.term, this.onUserTap);

  final String term;
  final void Function(LightUser)? onUserTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final autoComplete = ref.watch(autoCompleteUserProvider(term));
    return SingleChildScrollView(
      child: autoComplete.when(
        data:
            (userList) =>
                userList.isNotEmpty
                    ? ListSection(
                      header: Row(
                        children: [
                          const Icon(Icons.person),
                          const SizedBox(width: 8),
                          Text(context.l10n.mobilePlayersMatchingSearchTerm(term)),
                        ],
                      ),
                      hasLeading: true,
                      showDividerBetweenTiles: true,
                      children:
                          userList
                              .map(
                                (user) => UserListTile.fromLightUser(
                                  user,
                                  onTap: () {
                                    if (onUserTap != null) {
                                      onUserTap!.call(user);
                                    }
                                  },
                                ),
                              )
                              .toList(),
                    )
                    : Column(
                      children: [
                        const SizedBox(height: 16.0),
                        Center(child: Text(context.l10n.mobileNoSearchResults)),
                      ],
                    ),
        error: (e, _) {
          debugPrint('Error loading search results: $e');
          return const Column(
            children: [
              SizedBox(height: 16.0),
              Center(child: Text('Could not load search results.')),
            ],
          );
        },
        loading: () => const Column(children: [SizedBox(height: 16.0), CenterLoadingIndicator()]),
      ),
    );
  }
}
