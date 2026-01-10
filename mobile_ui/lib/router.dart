import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_ui/ui/category/category_main.dart';
import 'package:mobile_ui/ui/home/home_main.dart';
import 'package:mobile_ui/ui/link/list/link_list_main.dart';
import 'package:mobile_ui/ui/link/form/link_form_main.dart';
import 'package:mobile_ui/ui/note/form/note_form_main.dart';
import 'package:mobile_ui/ui/purchase/form/purchase_form_main.dart';
import 'package:mobile_ui/ui/setting/setting_main.dart';
import 'package:mobile_ui/ui/shared/bottom_nav_widget.dart';
import 'package:mobile_ui/ui/tag/tag_main.dart';

final GlobalKey<NavigatorState> _rootNavigationKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _homeNavigationKey = GlobalKey<NavigatorState>(debugLabel: 'home');
final GlobalKey<NavigatorState> _linkNavigationKey = GlobalKey<NavigatorState>(debugLabel: 'link');
final GlobalKey<NavigatorState> _purchaseNavigationKey = GlobalKey<NavigatorState>(debugLabel: 'purchase');
final GlobalKey<NavigatorState> _noteNavigationKey = GlobalKey<NavigatorState>(debugLabel: 'note');

final router = GoRouter(
  navigatorKey: _rootNavigationKey,
  debugLogDiagnostics: true,
  initialLocation: '/',
  routes: <RouteBase>[
    StatefulShellRoute.indexedStack(
      parentNavigatorKey: _rootNavigationKey,
      builder: (BuildContext context, GoRouterState state, StatefulNavigationShell navigationShell) {
        return BottomNavWidget(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          navigatorKey: _homeNavigationKey,
          routes: [
            GoRoute(
              name: 'home',
              path: '/',
              builder: (BuildContext context, GoRouterState state) {
                return const HomeMain();
              },
              routes: [
                GoRoute(
                  name: 'setting',
                  path: 'setting',
                  builder: (context, state) => SettingMain(),
                  routes: [
                    GoRoute(name: 'tag', path: 'tag', builder: (context, state) => TagMain()),
                    GoRoute(name: 'category', path: 'category', builder: (context, state) => CategoryMain()),
                  ],
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _linkNavigationKey,
          routes: [
            GoRoute(
              name: 'link',
              path: '/link',
              builder: (BuildContext context, GoRouterState state) {
                return const LinkFormMain();
              },
              routes: [
                GoRoute(
                  path: 'list',
                  builder: (BuildContext context, GoRouterState state) {
                    return const LinkListMain();
                  },
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _purchaseNavigationKey,
          routes: [
            GoRoute(
              name: 'purchase',
              path: '/purchase',
              builder: (BuildContext context, GoRouterState state) {
                return const PurchaseFormMain();
              },
            ),
          ],
        ),
        StatefulShellBranch(
          navigatorKey: _noteNavigationKey,
          routes: [
            GoRoute(
              name: 'note',
              path: '/note',
              builder: (BuildContext context, GoRouterState state) {
                return const NoteFormMain();
              },
            ),
          ],
        ),
      ],
    ),
  ],
);
