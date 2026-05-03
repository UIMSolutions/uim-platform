/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.infrastructure.container;

// import uim.platform.workzone.infrastructure.config;

// // Repositories
// import uim.platform.workzone.infrastructure.persistence.memory.workspace;
// import uim.platform.workzone.infrastructure.persistence.memory.workpage;
// import uim.platform.workzone.infrastructure.persistence.memory.card;
// import uim.platform.workzone.infrastructure.persistence.memory.content;
// import uim.platform.workzone.infrastructure.persistence.memory.feed;
// import uim.platform.workzone.infrastructure.persistence.memory.notification;
// import uim.platform.workzone.infrastructure.persistence.memory.task;
// import uim.platform.workzone.infrastructure.persistence.memory.channel;
// import uim.platform.workzone.infrastructure.persistence.memory.app;
// import uim.platform.workzone.infrastructure.persistence.memory.widget;

// // Use Cases
// import uim.platform.workzone.application.usecases.manage.workspaces;
// import uim.platform.workzone.application.usecases.manage.workpages;
// import uim.platform.workzone.application.usecases.manage.cards;
// import uim.platform.workzone.application.usecases.manage.content;
// import uim.platform.workzone.application.usecases.manage.feeds;
// import uim.platform.workzone.application.usecases.manage.notifications;
// import uim.platform.workzone.application.usecases.manage.tasks;
// import uim.platform.workzone.application.usecases.manage.channels;
// import uim.platform.workzone.application.usecases.manage.apps;
// import uim.platform.workzone.application.usecases.manage.widgets;

// // Controllers
// import uim.platform.identity_authentication.presentation.http.workspace;
// import uim.platform.identity_authentication.presentation.http.workpage;
// import uim.platform.identity_authentication.presentation.http.card;
// import uim.platform.identity_authentication.presentation.http.content;
// import uim.platform.identity_authentication.presentation.http.feed;
// import uim.platform.identity_authentication.presentation.http.notification;
// import uim.platform.identity_authentication.presentation.http.task;
// import uim.platform.identity_authentication.presentation.http.channel;
// import uim.platform.identity_authentication.presentation.http.app;
// import uim.platform.identity_authentication.presentation.http.widget;
// import uim.platform.identity_authentication.presentation.http.health;
import uim.platform.workzone;

mixin(ShowModule!());

@safe:
/// Dependency injection container — wires all layers together.
struct Container {
  // Repositories (driven adapters)
  MemoryWorkspaceRepository workspaceRepo;
  MemoryWorkpageRepository workpageRepo;
  MemoryCardRepository cardRepo;
  MemoryContentRepository contentRepo;
  MemoryFeedRepository feedRepo;
  MemoryNotificationRepository notificationRepo;
  MemoryTaskRepository taskRepo;
  MemoryChannelRepository channelRepo;
  MemoryAppRepository appRepo;
  MemoryWidgetRepository widgetRepo;

  // Use cases (application layer)
  ManageWorkspacesUseCase manageWorkspaces;
  ManageWorkpagesUseCase manageWorkpages;
  ManageCardsUseCase manageCards;
  ManageContentUseCase manageContent;
  ManageFeedsUseCase manageFeeds;
  ManageNotificationsUseCase manageNotifications;
  ManageTasksUseCase manageTasks;
  ManageChannelsUseCase manageChannels;
  ManageAppsUseCase manageApps;
  ManageWidgetsUseCase manageWidgets;

  // Controllers (driving adapters)
  WorkspaceController workspaceController;
  WorkpageController workpageController;
  CardController cardController;
  ContentController contentController;
  FeedController feedController;
  NotificationController notificationController;
  TaskController taskController;
  ChannelController channelController;
  AppController appController;
  WidgetController widgetController;
  HealthController healthController;
}

/// Build the full dependency graph.
Container buildContainer(SrvConfig config) {
  Container c;

  // Infrastructure adapters
  c.workspaceRepo = new MemoryWorkspaceRepository();
  c.workpageRepo = new MemoryWorkpageRepository();
  c.cardRepo = new MemoryCardRepository();
  c.contentRepo = new MemoryContentRepository();
  c.feedRepo = new MemoryFeedRepository();
  c.notificationRepo = new MemoryNotificationRepository();
  c.taskRepo = new MemoryTaskRepository();
  c.channelRepo = new MemoryChannelRepository();
  c.appRepo = new MemoryAppRepository();
  c.widgetRepo = new MemoryWidgetRepository();

  // Application use cases
  c.manageWorkspaces = new ManageWorkspacesUseCase(c.workspaceRepo);
  c.manageWorkpages = new ManageWorkpagesUseCase(c.workpageRepo);
  c.manageCards = new ManageCardsUseCase(c.cardRepo);
  c.manageContent = new ManageContentUseCase(c.contentRepo);
  c.manageFeeds = new ManageFeedsUseCase(c.feedRepo);
  c.manageNotifications = new ManageNotificationsUseCase(c.notificationRepo);
  c.manageTasks = new ManageTasksUseCase(c.taskRepo);
  c.manageChannels = new ManageChannelsUseCase(c.channelRepo);
  c.manageApps = new ManageAppsUseCase(c.appRepo);
  c.manageWidgets = new ManageWidgetsUseCase(c.widgetRepo);

  // Presentation controllers
  c.workspaceController = new WorkspaceController(c.manageWorkspaces);
  c.workpageController = new WorkpageController(c.manageWorkpages);
  c.cardController = new CardController(c.manageCards);
  c.contentController = new ContentController(c.manageContent);
  c.feedController = new FeedController(c.manageFeeds);
  c.notificationController = new NotificationController(c.manageNotifications);
  c.taskController = new TaskController(c.manageTasks);
  c.channelController = new ChannelController(c.manageChannels);
  c.appController = new AppController(c.manageApps);
  c.widgetController = new WidgetController(c.manageWidgets);
  c.healthController = new HealthController("workzone");

  return c;
}
