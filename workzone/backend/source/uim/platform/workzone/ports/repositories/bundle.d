/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.ports.repositories.bundle;

import uim.platform.workzone;

mixin(ShowModule!());

@safe:

/// All driven persistence ports, handed to the interactors by the container.
struct WorkzoneRepositories {
  IWorkspaceRepository workspaces;
  IWorkpageRepository workpages;
  IWidgetRepository widgets;
  IChannelRepository channels;
  IContentRepository content;
  IFeedEntryRepository feedEntries;
  IEventRepository events;
  ISurveyRepository surveys;
  IForumTopicRepository forumTopics;
  IKnowledgeBaseRepository knowledgeBase;
  ITaskRepository tasks;
  INotificationRepository notifications;
  ICardRepository cards;
  IAppRepository apps;
  IContentProviderRepository contentProviders;
  IShellPluginRepository shellPlugins;
  ISiteRepository sites;
  INavigationItemRepository navigationItems;
  IThemeRepository themes;
  IPageTemplateRepository pageTemplates;
  IRoleRepository roles;
  IGroupRepository groups;
  ITagRepository tags;
  IUserProfileRepository userProfiles;
}
