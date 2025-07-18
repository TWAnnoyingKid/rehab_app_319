import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:page_transition/page_transition.dart';

import '../../index.dart';
import 'serialization_util.dart';

export 'package:go_router/go_router.dart';
export 'serialization_util.dart';

const kTransitionInfoKey = '__transition_info__';

class AppStateNotifier extends ChangeNotifier {
  bool showSplashImage = true;

  void stopShowingSplashImage() {
    showSplashImage = false;
    notifyListeners();
  }
}

GoRouter createRouter(AppStateNotifier appStateNotifier) => GoRouter(
      initialLocation: '/',
      debugLogDiagnostics: true,
      refreshListenable: appStateNotifier,
      errorBuilder: (context, state) => LoginWidget(),
      routes: [
        FFRoute(
          name: '_initialize',
          path: '/',
          builder: (context, _) => LoginWidget(),
          routes: [
            FFRoute(
              name: 'login',
              path: 'login',
              builder: (context, params) => LoginWidget(),
            ),
            FFRoute(
              name: 'setting',
              path: 'setting',
              builder: (context, params) => SettingWidget(),
            ),
            FFRoute(
              name: 'settings_menu',
              path: 'settings_menu',
              builder: (context, params) => SettingsMenuWidget(),
            ),
            FFRoute(
              name: 'preference_settings',
              path: 'preference_settings',
              builder: (context, params) => PreferenceSettingsWidget(),
            ),
            FFRoute(
              name: 'need',
              path: 'need',
              builder: (context, params) => NeedWidget(),
            ),
            FFRoute(
              name: 'home',
              path: 'home',
              builder: (context, params) => HomeWidget(),
            ),
            FFRoute(
              name: 'need2',
              path: 'need2',
              builder: (context, params) => Need2Widget(),
            ),
            FFRoute(
              name: 'trainupperbody1',
              path: 'trainupperbody1',
              builder: (context, params) => Trainupperbody1Widget(),
            ),
            FFRoute(
              name: 'LINE',
              path: 'line',
              builder: (context, params) => LineWidget(),
            ),
            FFRoute(
              name: 'trainupperbody2',
              path: 'trainupperbody2',
              builder: (context, params) => Trainupperbody2Widget(),
            ),
            FFRoute(
              name: 'trainupperbody',
              path: 'trainupperbody',
              builder: (context, params) => TrainupperbodyWidget(),
            ),
            FFRoute(
              name: 'trainlowerbody',
              path: 'trainlowerbody',
              builder: (context, params) => TrainlowerbodyWidget(),
            ),
            FFRoute(
              name: 'trainlowerbody1',
              path: 'trainlowerbody1',
              builder: (context, params) => Trainlowerbody1Widget(),
            ),
            FFRoute(
              name: 'trainmouth',
              path: 'trainmouth',
              builder: (context, params) => TrainmouthWidget(),
            ),
            FFRoute(
              name: 'documental',
              path: 'documental',
              builder: (context, params) => DocumentalWidget(),
            ),
            FFRoute(
              name: 'about',
              path: 'about',
              builder: (context, params) => AboutWidget(),
            ),
            FFRoute(
              name: 'train',
              path: 'train',
              builder: (context, params) => TrainWidget(),
            ),
            FFRoute(
              name: 'notice',
              path: 'notice',
              builder: (context, params) => NoticeWidget(),
            ),
            FFRoute(
              name: 'trainlowerbody2',
              path: 'trainlowerbody2',
              builder: (context, params) => Trainlowerbody2Widget(),
            ),
            FFRoute(
              name: 'knowledge_main_page',
              path: 'knowledge_main_page',
              builder: (context, params) => KnowledgeMainPageWidget(),
            ),
            FFRoute(
              name: 'knowledge_page',
              path: 'knowledge_page',
              builder: (context, params) => KnowledgePageWidget(),
            ),
            FFRoute(
              name: 'questions_page',
              path: 'questions_page',
              builder: (context, params) => QuestionsPageWidget(),
            )
          ].map((r) => r.toRoute(appStateNotifier)).toList(),
        ),
      ].map((r) => r.toRoute(appStateNotifier)).toList(),
    );

extension NavParamExtensions on Map<String, String?> {
  Map<String, String> get withoutNulls => Map.fromEntries(
        entries
            .where((e) => e.value != null)
            .map((e) => MapEntry(e.key, e.value!)),
      );
}

extension NavigationExtensions on BuildContext {
  void safePop() {
    // If there is only one route on the stack, navigate to the initial
    // page instead of popping.
    // 更新: 在go_router 6.0中，matches不再有length屬性
    if (canPop() == false) {
      go('/');
    } else {
      pop();
    }
  }
}

extension _GoRouterStateExtensions on GoRouterState {
  Map<String, dynamic> get extraMap =>
      extra != null ? extra as Map<String, dynamic> : {};
  Map<String, dynamic> get allParams => <String, dynamic>{}
    ..addAll(params) // 使用params而非pathParameters
    ..addAll(queryParams) // 使用queryParams而非uri.queryParameters
    ..addAll(extraMap);
  TransitionInfo get transitionInfo => extraMap.containsKey(kTransitionInfoKey)
      ? extraMap[kTransitionInfoKey] as TransitionInfo
      : TransitionInfo.appDefault();
}

class FFParameters {
  FFParameters(this.state, [this.asyncParams = const {}]);

  final GoRouterState state;
  final Map<String, Future<dynamic> Function(String)> asyncParams;

  Map<String, dynamic> futureParamValues = {};

  // Parameters are empty if the params map is empty or if the only parameter
  // present is the special extra parameter reserved for the transition info.
  bool get isEmpty =>
      state.allParams.isEmpty ||
      (state.extraMap.length == 1 &&
          state.extraMap.containsKey(kTransitionInfoKey));
  bool isAsyncParam(MapEntry<String, dynamic> param) =>
      asyncParams.containsKey(param.key) && param.value is String;
  bool get hasFutures => state.allParams.entries.any(isAsyncParam);
  Future<bool> completeFutures() => Future.wait(
        state.allParams.entries.where(isAsyncParam).map(
          (param) async {
            final doc = await asyncParams[param.key]!(param.value)
                .onError((_, __) => null);
            if (doc != null) {
              futureParamValues[param.key] = doc;
              return true;
            }
            return false;
          },
        ),
      ).onError((_, __) => [false]).then((v) => v.every((e) => e));

  dynamic getParam<T>(
    String paramName,
    ParamType type, [
    bool isList = false,
  ]) {
    if (futureParamValues.containsKey(paramName)) {
      return futureParamValues[paramName];
    }
    if (!state.allParams.containsKey(paramName)) {
      return null;
    }
    final param = state.allParams[paramName];
    // Got parameter from `extras`, so just directly return it.
    if (param is! String) {
      return param;
    }
    // Return serialized value.
    return deserializeParam<T>(
      param,
      type,
      isList,
    );
  }
}

class FFRoute {
  const FFRoute({
    required this.name,
    required this.path,
    required this.builder,
    this.requireAuth = false,
    this.asyncParams = const {},
    this.routes = const [],
  });

  final String name;
  final String path;
  final bool requireAuth;
  final Map<String, Future<dynamic> Function(String)> asyncParams;
  final Widget Function(BuildContext, FFParameters) builder;
  final List<GoRoute> routes;

  GoRoute toRoute(AppStateNotifier appStateNotifier) => GoRoute(
        name: name,
        path: path,
        pageBuilder: (context, state) {
          final ffParams = FFParameters(state, asyncParams);
          final page = ffParams.hasFutures
              ? FutureBuilder(
                  future: ffParams.completeFutures(),
                  builder: (context, _) => builder(context, ffParams),
                )
              : builder(context, ffParams);
          final child = page;

          final transitionInfo = state.transitionInfo;
          return transitionInfo.hasTransition
              ? CustomTransitionPage(
                  key: state.pageKey,
                  child: child,
                  transitionDuration: transitionInfo.duration,
                  transitionsBuilder: PageTransition(
                    type: transitionInfo.transitionType,
                    duration: transitionInfo.duration,
                    reverseDuration: transitionInfo.duration,
                    alignment: transitionInfo.alignment,
                    child: child,
                  ).transitionsBuilder,
                )
              : MaterialPage(key: state.pageKey, child: child);
        },
        routes: routes,
      );
}

class TransitionInfo {
  const TransitionInfo({
    required this.hasTransition,
    this.transitionType = PageTransitionType.fade,
    this.duration = const Duration(milliseconds: 300),
    this.alignment,
  });

  final bool hasTransition;
  final PageTransitionType transitionType;
  final Duration duration;
  final Alignment? alignment;

  static TransitionInfo appDefault() => TransitionInfo(hasTransition: false);
}
