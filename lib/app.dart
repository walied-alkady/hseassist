import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hseassist/blocs/blocs.dart';
import 'package:hseassist/enums/authentication%20status.dart'
    show AuthenticationStatus;
import 'package:hseassist/models/hse_hazard.dart';
import 'package:hseassist/models/hse_incident.dart';
import 'package:hseassist/theme.dart';

import 'enums/app_page.dart';
import 'models/auth_user.dart';
import 'pages/pages.dart';
import 'pages/theme_selection_dialog.dart';
import 'repository/logging_reprository.dart';
import 'widgets/error_page.dart';

class AppMain extends StatelessWidget {
  const AppMain({super.key});
  @override
  Widget build(BuildContext context) {
    final log = LoggerReprository('AppMain');
    return BlocBuilder<AppCubit, AppState>(
      builder: (context, state) {
        bool isDarkMode = context.read<AppCubit>().prefs.isDarkTheme;
        final GoRouter routerConfig = GoRouter(
          initialLocation: AppPage.login.path,
          //observers: [HomeRouteObserver()],
          routes: <RouteBase>[
            // login
            GoRoute(
              path: AppPage.login.path,
              name: AppPage.login.name,
              builder: (BuildContext context, GoRouterState state) {
                return BlocProvider(
                  create: (BuildContext context) => LoginCubit()..initForm(),
                  child: LoginPage(),
                );
              },
              routes: <RouteBase>[
                // register
                GoRoute(
                  path: AppPage.register.path,
                  name: AppPage.register.name,
                  builder: (BuildContext context, GoRouterState state) {
                    return BlocProvider(
                      create: (BuildContext context) => RegisterCubit(),
                      child: RegisterPage(),
                    );
                  },
                ),
                //forgot pass
                GoRoute(
                  path: AppPage.forgotPassword.path,
                  name: AppPage.forgotPassword.name,
                  builder: (BuildContext context, GoRouterState state) {
                    return BlocProvider(
                      create: (BuildContext context) => ForgotPasswordCubit(),
                      child: const ForgotPasswordPage(),
                    );
                  },
                )
              ],
            ),
            //Admin user first login
            GoRoute(
              path: AppPage.userAdminIntro.path,
              name: AppPage.userAdminIntro.name,
              builder: (BuildContext context, GoRouterState state) {
                return BlocProvider(
                  create: (BuildContext context) =>
                      UserAdminIntroCubit()..initForm(),
                  child: const UserAdminIntroPage(),
                );
              },
            ),
            //location user first login
            GoRoute(
              path: AppPage.userIntro.path,
              name: AppPage.userIntro.name,
              builder: (BuildContext context, GoRouterState state) {
                return BlocProvider(
                  create: (BuildContext context) =>
                      UserIntroCubit()..initForm(),
                  child: const UserIntroPage(),
                );
              },
            ),
            //homepage & settings
            GoRoute(
              path: AppPage.home.path,
              name: AppPage.home.name,
              builder: (BuildContext context, GoRouterState state) {
                return BlocProvider(
                  create: (BuildContext context) => HomeCubit()..initForm(),
                  child: HomePage(),
                );
              },
              routes: <RouteBase>[
                //profile
                GoRoute(
                  path: AppPage.profile.path,
                  name: AppPage.profile.name,
                  builder: (BuildContext context, GoRouterState state) {
                    return BlocProvider(
                      create: (BuildContext context) => ProfileCubit(
                          authService: context.read<AppCubit>().authService,
                          db: context.read<AppCubit>().db,
                          log: log,
                          storage: context.read<AppCubit>().storage)
                        ..initForm(),
                      child: const ProfilePage(),
                    );
                  },
                ),
                //quizeGame
                GoRoute(
                  path: AppPage.quizeGame.path,
                  name: AppPage.quizeGame.name,
                  builder: (BuildContext context, GoRouterState state) {
                    return QuizeGamePage();
                  },
                ),
                // lists
                GoRoute(
                  path: AppPage.list.path,
                  name: AppPage.list.name,
                  builder: (BuildContext context, GoRouterState state) {
                    final Map<String, dynamic> extraData =
                        state.extra as Map<String, dynamic>;
                    final List<ListItem> items =
                        List<ListItem>.from(extraData['list']);
                    final listType = extraData['type'];
                    return BlocProvider(
                      create: (BuildContext context) =>
                          ListCubit(items, listType),
                      child: const ListPage(),
                    );
                  },
                ),
                //task
                GoRoute(
                  path: AppPage.taskCreate.path,
                  name: AppPage.taskCreate.name,
                  builder: (BuildContext context, GoRouterState state) {
                    return BlocProvider(
                      create: (BuildContext context) =>
                          TaskCreateCubit()..initForm(),
                      child: TaskCreatePage(),
                    );
                  },
                ),
                //hazard
                GoRoute(
                  path: AppPage.hazardIdCreate.path,
                  name: AppPage.hazardIdCreate.name,
                  builder: (BuildContext context, GoRouterState state) {
                    final extraData = state.extra as Map<String, dynamic>?;
                    HseHazard? additionalInfo;
                    if (extraData?['editableHazard'] != null) {
                      additionalInfo =
                          extraData?['editableHazard'] as HseHazard;
                    }
                    return BlocProvider(
                      create: (BuildContext context) {
                        if (additionalInfo == null) {
                          return (HazardIdCreateCubit()..initForm());
                        } else {
                          return HazardIdCreateCubit(
                              originalHazard: additionalInfo)
                            ..initForm()
                            ..startEditing(additionalInfo);
                        }
                      },
                      child: HazardIdCreatePage(),
                    );
                  },
                  routes: <RouteBase>[
                    //hazard task
                    //task
                    GoRoute(
                      path: AppPage.taskCreateHazard.path,
                      name: AppPage.taskCreateHazard.name,
                      builder: (BuildContext context, GoRouterState state) {
                        return BlocProvider(
                          create: (BuildContext context) => TaskCreateCubit(),
                          child: TaskCreatePage(isManaged: true),
                        );
                      },
                    ),
                  ],
                ),
                //incident
                GoRoute(
                  path: AppPage.incidentCreate.path,
                  name: AppPage.incidentCreate.name,
                  builder: (BuildContext context, GoRouterState state) {
                    final extraData = state.extra as Map<String, dynamic>?;
                    HseIncident? additionalInfo;
                    if (extraData?['editableIncident'] != null) {
                      additionalInfo =
                          extraData?['editableIncident'] as HseIncident;
                    }
                    return BlocProvider(
                      create: (BuildContext context) {
                        if (additionalInfo == null) {
                          return (IncidentCreateCubit()..initForm());
                        } else {
                          return IncidentCreateCubit(
                              originalIncident: additionalInfo)
                            ..initForm()
                            ..startEditing(additionalInfo);
                        }
                      },
                      child: IncidentCreatePage(),
                    );
                  },
                  routes: <RouteBase>[
                    //Incident task
                    //task
                    GoRoute(
                      path: AppPage.taskCreateIncident.path,
                      name: AppPage.taskCreateIncident.name,
                      builder: (BuildContext context, GoRouterState state) {
                        return BlocProvider(
                          create: (BuildContext context) => TaskCreateCubit(),
                          child: TaskCreatePage(isManaged: true),
                        );
                      },
                    ),
                  ],
                ),
                //miniSession
                GoRoute(
                  path: AppPage.miniSession.path,
                  name: AppPage.miniSession.name,
                  builder: (BuildContext context, GoRouterState state) {
                    return BlocProvider(
                      create: (BuildContext context) => MiniSessionCubit(),
                      child: const MiniSessionPage(),
                    );
                  },
                ),
                //HazardHunterGameMain
                GoRoute(
                  path: AppPage.hazardHunterGame.path,
                  name: AppPage.hazardHunterGame.name,
                  builder: (BuildContext context, GoRouterState state) {
                    return HazardHunterGameMain();
                  },
                ),
                //settings
                GoRoute(
                    path: AppPage.settings.path,
                    name: AppPage.settings.name,
                    builder: (BuildContext context, GoRouterState state) {
                      return BlocProvider(
                        create: (BuildContext context) => SettingsCubit(),
                        child: const SettingsPage(),
                      );
                      //SettingsPage(controller: settingsController);
                    },
                    routes: <RouteBase>[
                      //language dialogue
                      GoRoute(
                        path: AppPage.languageDialogue.path,
                        name: AppPage.languageDialogue.name,
                        builder: (BuildContext context, GoRouterState state) {
                          return BlocProvider(
                            create: (BuildContext context) => SettingsCubit(),
                            child: const LanguageSelectionDialog(),
                          );
                        },
                      ),
                      //theme dialogue
                      GoRoute(
                        path: AppPage.themeSelectionDialoge.path,
                        name: AppPage.themeSelectionDialoge.name,
                        builder: (BuildContext context, GoRouterState state) {
                          return BlocProvider(
                            create: (BuildContext context) => SettingsCubit(),
                            child: const ThemeSelectionDialog(),
                          );
                        },
                      ),

                      // workplace location
                      GoRoute(
                        path: AppPage.workplaceLocation.path,
                        name: AppPage.workplaceLocation.name,
                        builder: (BuildContext context, GoRouterState state) {
                          return BlocProvider(
                            create: (BuildContext context) =>
                                WorkplaceLocationCubit(
                              authService:
                                  context.read<AppCubit>().authService,
                              db: context.read<AppCubit>().db,
                              log: log,
                            ),
                            child: const WorkplaceLocationPage(),
                          );
                        },
                      ),
                    ]),
                //admin
                GoRoute(
                    path: AppPage.admin.path,
                    name: AppPage.admin.name,
                    builder: (BuildContext context, GoRouterState state) {
                      return BlocProvider(
                        create: (BuildContext context) =>
                            AdminCubit()..initData(),
                        child: AdminPage(),
                      );
                    },
                    routes: <RouteBase>[
                      //worlplace user
                      GoRoute(
                        path: AppPage.workplaceUser.path,
                        name: AppPage.workplaceUser.name,
                        builder: (BuildContext context, GoRouterState state) {
                          final extraData =
                              state.extra as Map<String, dynamic>?;
                          log.i(extraData?.toString() ??
                              'worlplace user extra is null');
                          AuthUser eq;
                          if (extraData != null) {
                            final Map<String, dynamic> item =
                                Map<String, dynamic>.from(extraData['item']);
                            eq = AuthUser.fromMap(item);
                          } else {
                            eq = AuthUser.empty;
                          }
                          return BlocProvider(
                            create: (BuildContext context) =>
                                WorkplaceUserCubit(eq,
                                    authService:
                                        context.read<AppCubit>().authService,
                                    db: context.read<AppCubit>().db,
                                    log: log,
                                    prefs: context.read<AppCubit>().prefs)
                                  ..initForm(),
                            child: const WorkplaceUserPage(),
                          );
                          //SettingsPage(controller: settingsController);
                        },
                      ),
                      // invite user
                      GoRoute(
                        path: AppPage.inviteUser.path,
                        name: AppPage.inviteUser.name,
                        builder: (BuildContext context, GoRouterState state) {
                          return BlocProvider(
                            create: (BuildContext context) =>
                                InviteUserCubit()..initForm(),
                            child: InviteUserPage(),
                          );
                        },
                      ),
                    ]),
              ],
            ),
          ],
          errorBuilder: (context, state) {
            log.e(state.error?.message);
            return ErrorPage(errorMessage: state.error!.message);
          },
          debugLogDiagnostics: true,
          redirect: (context, state) { // here is where we use redirect
            final loggingIn = state.matchedLocation == AppPage.login.path;
            final forgetPass = state.matchedLocation == AppPage.forgotPassword.path;
            final register = state.matchedLocation == AppPage.register.path;
            if (context.read<AppCubit>().userAuthStatus ==AuthenticationStatus.unauthenticated && !loggingIn && !forgetPass && !register) {
              return AppPage.login.path; 
            }
            return null;
          },
        );
        return MaterialApp.router(
          restorationScopeId: 'app',
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          onGenerateTitle: (BuildContext context) => 'appTitle'.tr(),
          theme: state.themeData, 
          darkTheme: safetyThemeClassic, 
          themeMode: isDarkMode
              ? ThemeMode.dark
              : ThemeMode.light, 
          routerConfig: routerConfig, 
        );
      },
    );
  }
}
