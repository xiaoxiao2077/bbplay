import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '/model/video/item.dart';
import '/pages/video/page.dart';
import '/pages/login/page.dart';
import '/pages/search/page.dart';
import '/pages/launch/page.dart';
import '/pages/history/page.dart';
import '/pages/favorite/page.dart';
import '/pages/timeslot/page.dart';
import '/pages/search/result.dart';
import '/pages/desktop/video/page.dart' as desktop_video;

//视频播放会打开新的窗口
GoRouter deskRouter(VideoItem item) {
  if (item.bvid == null || item.cid == null) {
    return mobileRouter;
  }
  return GoRouter(
    initialLocation: '/video/play',
    errorPageBuilder: (context, state) => MaterialPage(
      child: Center(
        child: Text('Error: ${state.error}'),
      ),
    ),
    routes: [
      GoRoute(
        path: '/video/play',
        builder: (BuildContext context, GoRouterState state) {
          return VideoPlayPage(item: item);
        },
      ),
    ],
  );
}

var mobileRouter = GoRouter(
  initialLocation: '/',
  errorPageBuilder: (context, state) => MaterialPage(
    child: Center(
      child: Text('Error: ${state.error}'),
    ),
  ),
  routes: [
    GoRoute(
      path: '/',
      builder: (BuildContext context, GoRouterState state) => LaunchPage(),
    ),
    GoRoute(
      path: '/video/play',
      builder: (BuildContext context, GoRouterState state) {
        Map<String, dynamic> query = state.extra as Map<String, dynamic>;
        return VideoPlayPage(item: query['item']);
      },
    ),
    GoRoute(
      path: '/desktop/video/play',
      builder: (BuildContext context, GoRouterState state) {
        Map<String, dynamic> query = state.extra as Map<String, dynamic>;
        return desktop_video.VideoPlayPage(item: query['item']);
      },
    ),
    GoRoute(
      path: '/favorites',
      builder: (BuildContext context, GoRouterState state) =>
          const FavoritePage(),
    ),
    GoRoute(
      path: '/history',
      builder: (BuildContext context, GoRouterState state) =>
          const HistoryPage(),
    ),
    GoRoute(
      path: '/timeslot',
      builder: (BuildContext context, GoRouterState state) =>
          const TimeSlotPage(),
    ),
    GoRoute(
      path: '/search',
      builder: (BuildContext context, GoRouterState state) =>
          const SearchVideoPage(),
    ),
    GoRoute(
      path: '/search/result',
      builder: (BuildContext context, GoRouterState state) {
        Map<String, dynamic> query = state.extra as Map<String, dynamic>;
        return SearchResultPage(keyword: query['keyword']);
      },
    ),
    GoRoute(
      path: '/login',
      builder: (BuildContext context, GoRouterState state) =>
          const LoginFormPage(),
    ),
  ],
);
