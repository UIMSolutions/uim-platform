module infrastructure.container;

import infrastructure.config;

// Repositories
import infrastructure.persistence.in_memory_workspace_repo;
import infrastructure.persistence.in_memory_workpage_repo;
import infrastructure.persistence.in_memory_card_repo;
import infrastructure.persistence.in_memory_content_repo;
import infrastructure.persistence.in_memory_feed_repo;
import infrastructure.persistence.in_memory_notification_repo;
import infrastructure.persistence.in_memory_task_repo;
import infrastructure.persistence.in_memory_channel_repo;
import infrastructure.persistence.in_memory_app_repo;
import infrastructure.persistence.in_memory_widget_repo;

// Use Cases
import application.usecases.manage_workspaces;
import application.usecases.manage_workpages;
import application.usecases.manage_cards;
import application.usecases.manage_content;
import application.usecases.manage_feeds;
import application.usecases.manage_notifications;
import application.usecases.manage_tasks;
import application.usecases.manage_channels;
import application.usecases.manage_apps;
import application.usecases.manage_widgets;

// Controllers
import uim.platform.identity_authentication.presentation.http.workspace;
import uim.platform.identity_authentication.presentation.http.workpage;
import uim.platform.identity_authentication.presentation.http.card;
import uim.platform.identity_authentication.presentation.http.content;
import uim.platform.identity_authentication.presentation.http.feed;
import uim.platform.identity_authentication.presentation.http.notification;
import uim.platform.identity_authentication.presentation.http.task;
import uim.platform.identity_authentication.presentation.http.channel;
import uim.platform.identity_authentication.presentation.http.app;
import uim.platform.identity_authentication.presentation.http.widget;
import uim.platform.identity_authentication.presentation.http.health;

/// Dependency injection container — wires all layers together.
struct Container
{
    // Repositories (driven adapters)
    InMemoryWorkspaceRepository workspaceRepo;
    InMemoryWorkpageRepository workpageRepo;
    InMemoryCardRepository cardRepo;
    InMemoryContentRepository contentRepo;
    InMemoryFeedRepository feedRepo;
    InMemoryNotificationRepository notificationRepo;
    InMemoryTaskRepository taskRepo;
    InMemoryChannelRepository channelRepo;
    InMemoryAppRepository appRepo;
    InMemoryWidgetRepository widgetRepo;

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
Container buildContainer(AppConfig config)
{
    Container c;

    // Infrastructure adapters
    c.workspaceRepo = new InMemoryWorkspaceRepository();
    c.workpageRepo = new InMemoryWorkpageRepository();
    c.cardRepo = new InMemoryCardRepository();
    c.contentRepo = new InMemoryContentRepository();
    c.feedRepo = new InMemoryFeedRepository();
    c.notificationRepo = new InMemoryNotificationRepository();
    c.taskRepo = new InMemoryTaskRepository();
    c.channelRepo = new InMemoryChannelRepository();
    c.appRepo = new InMemoryAppRepository();
    c.widgetRepo = new InMemoryWidgetRepository();

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
    c.healthController = new HealthController();

    return c;
}
