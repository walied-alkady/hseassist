enum AppPage {
  login,
  register,
  home,
  admin,
  profile,
  error,
  settings,
  languageDialogue,
  forgotPassword,
  resetPassword,
  workplaceUser,
  inviteUser,
  recieveInvitation,
  noInvitationMessage,
  list,
  hazardHunterGame,
  taskCreate,
  taskCreateHazard,
  taskCreateIncident,
  hazardIdCreate,
  incidentCreate,
  workplaceLocation,
  quizeGame,
  miniSession,
  userAdminIntro,
  userIntro,
  themeSelectionDialoge
}

extension AppPageExtension on AppPage {

  String get path {
    switch (this) {
      case AppPage.login:
        return "/";
      case AppPage.register:
        return "/register"; 
      case AppPage.forgotPassword:
        return "/forgotPassword";
      case AppPage.home:
        return "/home";
      case AppPage.admin:
        return "home/admin";
      case AppPage.hazardHunterGame:
        return "home/game";
      case AppPage.profile:
        return "home/profile";
      case AppPage.error:
        return "error";  
      // case AppPage.list:
      //   return "list";
      case AppPage.settings:
        return "home/settings";
      case AppPage.languageDialogue:
        return "home/settings/languageDialogue";
      case AppPage.themeSelectionDialoge:
        return "home/settings/themeSelectionDialoge";
      case AppPage.resetPassword:
        return "/resetPassword";
      case AppPage.workplaceUser:
        return "workplaceUser";
      // case AppPage.joinOrganization:
      //   return "joinOrganization";
      case AppPage.inviteUser:
        return 'inviteUser';
      case AppPage.recieveInvitation:
        return "recieveInvitation";
      case AppPage.noInvitationMessage:
        return "noInvitationMessage";
      case AppPage.list:
        return "home/list";
      case AppPage.taskCreate:
        return "home/taskCreate";
      case AppPage.hazardIdCreate:
        return "home/hazardCreate";
      case AppPage.taskCreateHazard:
        return "home/hazardCreate/taskCreateHazard";
      case AppPage.incidentCreate:
        return "home/incidentCreate";
      case AppPage.taskCreateIncident:
        return "home/incidentCreate/taskCreateIncident";
      case AppPage.workplaceLocation:
        return "workplaceLocation";
      case AppPage.quizeGame:
        return "home/quizeGame";
      case AppPage.miniSession:
        return "home/miniSession";
      case AppPage.userAdminIntro:
        return "/userAdminIntro";
      case AppPage.userIntro:
        return "/userIntro";
    }
  }

  String get name {
    switch (this) {
      case AppPage.login:
        return "login";
      case AppPage.register:
        return "register";
      case AppPage.home:
        return "home";
      case AppPage.admin:
        return "admin";
      case AppPage.hazardHunterGame:
        return "game";
      case AppPage.profile:
        return "profile";
      case AppPage.error:
        return "error";  
      // case AppPage.list:
      //   return "list";
      case AppPage.settings:
        return "settings";  
      case AppPage.languageDialogue:
        return "languageDialogue";
      case AppPage.themeSelectionDialoge:
        return "themeSelectionDialoge";
      case AppPage.forgotPassword:
        return "forgotPassword";
      case AppPage.resetPassword:
        return "resetPassword";
      case AppPage.workplaceUser:
        return "workplaceUser";
      case AppPage.inviteUser:
        return "inviteUser";
      case AppPage.recieveInvitation:
        return "recieveInvitation";
      case AppPage.noInvitationMessage:
        return "noInvitationMessage";
      case AppPage.list:
        return "list";
      case AppPage.taskCreate:
        return "taskCreate";
      case AppPage.taskCreateHazard:
        return "taskCreateHazard";
      case AppPage.taskCreateIncident:
        return "taskCreateIncident";    
      case AppPage.hazardIdCreate:
        return "hazardCreate";
      case AppPage.incidentCreate:
        return "incidentCreate";
      case AppPage.workplaceLocation:
        return "workplaceLocation";
      case AppPage.quizeGame:
        return "quizeGame";
      case AppPage.miniSession:
        return "miniSession";
      case AppPage.userAdminIntro:
        return "userAdminIntro";
      case AppPage.userIntro:
        return "userIntro";
    }
  }

  // String get title {
  //   switch (this) {
  //     case AppPage.login:
  //       return "LOGIN";
  //   }
  // }

}
