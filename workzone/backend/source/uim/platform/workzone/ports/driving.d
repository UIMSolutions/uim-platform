/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.ports.driving;

import uim.platform.workzone;

mixin(ShowModule!());

@safe:

/// Bundle of all driving ports. Presentation adapters (REST, OData, CLI, GUI)
/// depend on this bundle only — never on concrete interactors or repositories.
struct WorkzonePorts {
  // collaboration
  IManageWorkspacesUseCase workspaces;
  IManageWorkpagesUseCase workpages;
  IManageWidgetsUseCase widgets;
  IManageChannelsUseCase channels;
  IManageContentUseCase content;
  IManageFeedEntriesUseCase feedEntries;
  IManageEventsUseCase events;
  IManageSurveysUseCase surveys;
  IManageForumTopicsUseCase forumTopics;
  IManageKnowledgeBaseUseCase knowledgeBase;
  // inbox
  IManageTasksUseCase tasks;
  IManageNotificationsUseCase notifications;
  // integration
  IManageCardsUseCase cards;
  IManageAppsUseCase apps;
  IManageContentProvidersUseCase contentProviders;
  IManageShellPluginsUseCase shellPlugins;
  // sites & administration
  IManageSitesUseCase sites;
  IManageNavigationItemsUseCase navigationItems;
  IManageThemesUseCase themes;
  IManagePageTemplatesUseCase pageTemplates;
  IManageRolesUseCase roles;
  IManageGroupsUseCase groups;
  IManageTagsUseCase tags;
  IManageUserProfilesUseCase userProfiles;
  // cross-cutting
  IHousekeepingUseCase housekeeping;
  IWorkzoneStatisticsService statistics;
  IWorkzoneSeedService seeder;
}
