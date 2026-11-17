/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.infrastructure.container;

import uim.platform.workzone;

mixin(ShowModule!());

@safe:

/// Dependency injection container — wires domain, application and persistence.
/// Presentation adapters (REST, OData, CLI, GUI) are created by the entry points
/// (app.d, cli.d, gui.d) on top of this container and only see `ports`.
class Container {
  WorkzoneConfig config;

  // ── Driven adapters ───────────────────────────────────────────────────
  ISnapshotStorage storage; // null in "memory" mode
  WorkzoneRepositories repositories;
  IWorkzoneEventPublisher publisher;
  SimulatedContentProviderGateway gateway;

  // ── Driving ports ─────────────────────────────────────────────────────
  WorkzonePorts ports;

  this(WorkzoneConfig config, long delegate() @safe clock = null) {
    this.config = config;
    wirePersistence();
    wireApplication(clock);
  }

  protected void wirePersistence() {
    if (config.usesFileStorage)
      storage = new JsonFileSnapshotStorage(config.dataDir);

    auto repo(TEntity, TId)(string collection) {
      ITenantStore!(TEntity, TId) s = storage is null
        ? new TenantStore!(TEntity, TId)()
        : new SnapshotTenantStore!(TEntity, TId, RecordMapper!TEntity)(storage, collection);
      return new WorkzoneRepository!(TEntity, TId)(s);
    }

    alias C = WorkzoneCollections;
    with (repositories) {
      workspaces = repo!(Workspace, WorkspaceId)(C.workspaces);
      workpages = repo!(Workpage, WorkpageId)(C.workpages);
      widgets = repo!(PageWidget, WidgetId)(C.widgets);
      channels = repo!(WorkspaceChannel, ChannelId)(C.channels);
      content = repo!(ContentItem, ContentId)(C.content);
      feedEntries = repo!(FeedEntry, FeedEntryId)(C.feedEntries);
      events = repo!(CalendarEvent, EventId)(C.events);
      surveys = repo!(Survey, SurveyId)(C.surveys);
      forumTopics = repo!(ForumTopic, ForumTopicId)(C.forumTopics);
      knowledgeBase = repo!(KnowledgeBaseArticle, KBArticleId)(C.knowledgeBase);
      tasks = repo!(WorkTask, TaskId)(C.tasks);
      notifications = repo!(Notification, NotificationId)(C.notifications);
      cards = repo!(Card, CardId)(C.cards);
      apps = repo!(AppRegistration, AppId)(C.apps);
      contentProviders = repo!(ExternalContentProvider, ExternalContentProviderId)(C.contentProviders);
      shellPlugins = repo!(ShellPlugin, ShellPluginId)(C.shellPlugins);
      sites = repo!(Site, SiteId)(C.sites);
      navigationItems = repo!(NavigationItem, NavigationItemId)(C.navigationItems);
      themes = repo!(Theme, ThemeId)(C.themes);
      pageTemplates = repo!(PageTemplate, PageTemplateId)(C.pageTemplates);
      roles = repo!(Role, RoleId)(C.roles);
      groups = repo!(UserGroup, GroupId)(C.groups);
      tags = repo!(Tag, TagId)(C.tags);
      userProfiles = repo!(UserProfile, UserProfileId)(C.userProfiles);
    }
    publisher = new LogEventPublisher();
    gateway = new SimulatedContentProviderGateway();
  }

  protected void wireApplication(long delegate() @safe clock) {
    auto r = repositories;
    auto cascade = new CascadeDeleter(r);
    auto feed = new FeedRecorder(r);
    with (ports) {
      workspaces = new ManageWorkspacesUseCase(r, cascade, feed, publisher);
      workpages = new ManageWorkpagesUseCase(r, cascade, publisher);
      widgets = new ManageWidgetsUseCase(r, publisher);
      channels = new ManageChannelsUseCase(r, publisher);
      content = new ManageContentUseCase(r, feed, publisher);
      feedEntries = new ManageFeedEntriesUseCase(r, feed, publisher);
      events = new ManageEventsUseCase(r, feed, publisher);
      surveys = new ManageSurveysUseCase(r, feed, publisher);
      forumTopics = new ManageForumTopicsUseCase(r, feed, publisher);
      knowledgeBase = new ManageKnowledgeBaseUseCase(r, feed, publisher);
      tasks = new ManageTasksUseCase(r, publisher);
      notifications = new ManageNotificationsUseCase(r, publisher);
      cards = new ManageCardsUseCase(r, publisher);
      apps = new ManageAppsUseCase(r, publisher);
      contentProviders = new ManageContentProvidersUseCase(r, gateway, publisher);
      shellPlugins = new ManageShellPluginsUseCase(r, publisher);
      sites = new ManageSitesUseCase(r, cascade, publisher);
      navigationItems = new ManageNavigationItemsUseCase(r, publisher);
      themes = new ManageThemesUseCase(r, publisher);
      pageTemplates = new ManagePageTemplatesUseCase(r, publisher);
      roles = new ManageRolesUseCase(r, publisher);
      groups = new ManageGroupsUseCase(r, publisher);
      tags = new ManageTagsUseCase(r, publisher);
      userProfiles = new ManageUserProfilesUseCase(r, publisher);
      housekeeping = new HousekeepingUseCase(r, gateway, publisher, clock);
      statistics = new WorkzoneStatisticsService(r);
      seeder = new WorkzoneSeedService(r, publisher);
    }
  }
}

/// Build the full dependency graph.
Container buildContainer(WorkzoneConfig config, long delegate() @safe clock = null) {
  return new Container(config, clock);
}

///
unittest {
  mixin(ShowTest!("Container — end-to-end scenario"));

  WorkzoneConfig cfg;
  cfg.storage = "memory";
  long offset; // simulated time travel for housekeeping
  auto c = buildContainer(cfg, () => nowStdTime() + offset);
  auto p = c.ports;
  auto t = TenantId("t1");
  auto jane = UserId("jane");
  auto bob = UserId("bob");

  // ── seed ───────────────────────────────────────────────────────────────
  auto seeded = p.seeder.seed(t, jane);
  assert(seeded.created == 20 && seeded.skipped == 0, seeded.items.join(", "));
  assert(p.seeder.seed(t, jane).created == 0); // idempotent
  RoleId roleId(string name) {
    return p.roles.list(t).filter!(x => x.name == name).front.id;
  }

  assert(p.roles.remove(t, roleId("Viewer"), jane).code == 409); // predefined

  // ── user profiles (default role assigned) ──────────────────────────────
  CreateUserProfileRequest up;
  up.tenantId = t;
  up.actor = jane;
  up.spec.userId = jane;
  up.spec.firstName = "Jane";
  up.spec.lastName = "Doe";
  up.spec.email = "jane@example.com";
  auto janeProfile = p.userProfiles.create(up);
  assert(janeProfile.isSuccess, janeProfile.message);
  assert(p.userProfiles.get(t, UserProfileId(janeProfile.id)).roles == ["Viewer"]);
  assert(p.userProfiles.create(up).code == 409); // one profile per user
  up.spec.userId = bob;
  up.spec.firstName = "Bob";
  up.spec.email = "bob@";
  assert(p.userProfiles.create(up).code == 422);
  up.spec.email = "bob@example.com";
  assert(p.userProfiles.create(up).isSuccess);

  // ── workspace: creator is owner, alias derived ─────────────────────────
  CreateWorkspaceRequest ws;
  ws.tenantId = t;
  ws.actor = jane;
  ws.spec.name = "Sales EMEA";
  ws.spec.enableForum = false;
  auto wsResult = p.workspaces.create(ws);
  assert(wsResult.isSuccess, wsResult.message);
  auto wsId = WorkspaceId(wsResult.id);
  auto sales = p.workspaces.get(t, wsId);
  assert(sales.alias_ == "sales-emea" && sales.members.length == 1 && sales.members[0].role == MemberRole.owner);
  assert(p.workspaces.create(ws).code == 409); // duplicate name
  ws.spec.name = "Sales Other";
  ws.spec.alias_ = "sales-emea";
  assert(p.workspaces.create(ws).code == 409); // duplicate alias
  assert(p.workspaces.addMember(t, wsId, WorkspaceMember("bob", "", MemberRole.contributor), jane).isSuccess);
  assert(p.workspaces.removeMember(t, wsId, "jane", jane).code == 409); // last owner
  assert(p.feedEntries.list(t).any!(f => f.action == "joined" && f.actorName == "Bob Doe"));

  // ── workpages & widgets ────────────────────────────────────────────────
  CreateWorkpageRequest wp;
  wp.tenantId = t;
  wp.actor = jane;
  wp.parentId = wsId;
  wp.spec.title = "Home";
  auto homeId = WorkpageId(p.workpages.create(wp).id);
  auto home = p.workpages.get(t, homeId);
  assert(home.isDefault && home.templateName == "Standard"); // first page, default template
  wp.spec.title = "Pipeline";
  wp.spec.isDefault = true;
  auto pipelineId = WorkpageId(p.workpages.create(wp).id);
  assert(!p.workpages.get(t, homeId).isDefault && p.workpages.get(t, pipelineId).isDefault);
  assert(p.workpages.create(wp).code == 409); // title unique per workspace
  wp.spec.title = "Restricted";
  wp.spec.allowedRoles = ["Nope"];
  assert(p.workpages.create(wp).code == 404);

  CreateCardRequest card;
  card.tenantId = t;
  card.actor = jane;
  card.spec.title = "Open Opportunities";
  card.spec.dataSourceUrl = "/odata/v4/sales/Opportunities";
  auto cardId = CardId(p.cards.create(card).id);

  CreateWidgetRequest wg;
  wg.tenantId = t;
  wg.actor = jane;
  wg.parentId = pipelineId;
  wg.spec.cardId = cardId;
  wg.spec.size = WidgetSize.large;
  wg.spec.col = 2;
  assert(p.widgets.create(wg).code == 422); // large widget does not fit into column 2
  wg.spec.col = 1;
  auto widgetResult = p.widgets.create(wg);
  assert(widgetResult.isSuccess, widgetResult.message);
  assert(p.widgets.get(t, WidgetId(widgetResult.id)).title == "Open Opportunities");
  assert(p.cards.remove(t, cardId, jane).code == 409); // shown by a widget
  assert(p.cards.deactivate(t, cardId, jane).code == 409);

  // ── content: wiki toggle, tags, publish → feed ─────────────────────────
  CreateContentRequest ct;
  ct.tenantId = t;
  ct.actor = jane;
  ct.parentId = wsId;
  ct.spec.title = "Q4 Plan";
  ct.spec.body_ = "Targets and accounts for Q4.";
  ct.spec.tags = ["Sales", "Unknown"];
  assert(p.content.create(ct).code == 404); // unknown tag
  ct.spec.tags = ["Sales"];
  auto contentId = ContentId(p.content.create(ct).id);
  assert(p.content.pin(t, contentId, jane).code == 409); // draft
  assert(p.content.publish(t, contentId, jane).isSuccess);
  assert(p.content.publish(t, contentId, jane).code == 409);
  assert(p.feedEntries.list(t).any!(f => f.action == "published" && f.objectTitle == "Q4 Plan"));
  assert(p.tags.remove(t, p.tags.list(t).filter!(x => x.name == "Sales").front.id, jane).code == 409); // in use

  // ── forum disabled, knowledge base four-eyes rule ──────────────────────
  CreateForumTopicRequest ft;
  ft.tenantId = t;
  ft.actor = jane;
  ft.parentId = wsId;
  ft.spec.title = "Pricing";
  ft.spec.body_ = "How do we price bundles?";
  assert(p.forumTopics.create(ft).code == 409); // forum disabled

  CreateArticleRequest kb;
  kb.tenantId = t;
  kb.actor = jane;
  kb.parentId = wsId;
  kb.spec.title = "Discount policy";
  kb.spec.body_ = "Max. 15 % without approval.";
  auto kbId = KBArticleId(p.knowledgeBase.create(kb).id);
  assert(p.knowledgeBase.publish(t, kbId, bob).code == 409); // not reviewed
  assert(p.knowledgeBase.submit(t, kbId, jane).isSuccess);
  assert(p.knowledgeBase.publish(t, kbId, jane).code == 409); // author cannot publish
  assert(p.knowledgeBase.publish(t, kbId, bob).isSuccess);
  assert(p.knowledgeBase.get(t, kbId).version_ == 1);

  // ── tasks, notifications, events, surveys, housekeeping ────────────────
  CreateTaskRequest tk;
  tk.tenantId = t;
  tk.actor = jane;
  tk.spec.title = "Approve discount";
  tk.spec.assigneeId = bob;
  tk.spec.dueAt = nowStdTime() + stdTimeDay;
  auto taskId = TaskId(p.tasks.create(tk).id);
  assert(p.tasks.start(t, taskId, bob).isSuccess);

  CreateNotificationRequest nt;
  nt.tenantId = t;
  nt.actor = jane;
  nt.spec.recipientId = UserId("ghost");
  nt.spec.title = "Welcome";
  assert(p.notifications.create(nt).code == 404); // no profile
  nt.spec.recipientId = bob;
  nt.spec.expiresAt = nowStdTime() + stdTimeDay;
  auto noteId = NotificationId(p.notifications.create(nt).id);
  assert(p.notifications.markRead(t, noteId, bob).isSuccess);

  CreateEventRequest ev;
  ev.tenantId = t;
  ev.actor = jane;
  ev.parentId = wsId;
  ev.spec.title = "Pipeline review";
  ev.spec.startsAt = nowStdTime() + stdTimeDay / 2;
  ev.spec.endsAt = ev.spec.startsAt - 1;
  assert(p.events.create(ev).code == 422); // ends before it starts
  ev.spec.endsAt = 0; // one hour by default
  auto eventId = EventId(p.events.create(ev).id);
  assert(p.events.get(t, eventId).status == EventStatus.scheduled);

  CreateSurveyRequest sv;
  sv.tenantId = t;
  sv.actor = jane;
  sv.parentId = wsId;
  sv.spec.title = "Pulse";
  sv.spec.questions = [SurveyQuestion("", "Happy?", QuestionType.singleChoice, ["yes"])];
  sv.spec.endsAt = nowStdTime() + stdTimeDay;
  auto surveyId = SurveyId(p.surveys.create(sv).id);
  assert(p.surveys.activate(t, surveyId, jane).code == 422); // one option only
  UpdateSurveyRequest svu;
  svu.tenantId = t;
  svu.actor = jane;
  svu.id = surveyId;
  svu.spec = sv.spec;
  svu.spec.questions[0].options = ["yes", "no"];
  assert(p.surveys.update(svu).isSuccess);
  assert(p.surveys.activate(t, surveyId, jane).isSuccess);
  assert(p.surveys.respond(t, surveyId, bob).isSuccess);
  assert(p.surveys.respond(t, surveyId, bob).code == 409); // single response
  assert(p.surveys.update(svu).code == 409); // questions locked

  assert(p.housekeeping.run(t).changed == 0);
  offset = 2 * stdTimeDay; // two days later
  auto hk = p.housekeeping.run(t);
  assert(hk.changed == 4, hk.changes.join("; ")); // task overdue, event completed, survey closed, notification expired
  assert(p.tasks.get(t, taskId).status == TaskStatus.overdue);
  assert(p.events.get(t, eventId).status == EventStatus.completed);
  assert(p.surveys.get(t, surveyId).status == SurveyStatus.closed);
  assert(p.notifications.get(t, noteId).status == NotificationStatus.dismissed);
  assert(p.tasks.complete(t, taskId, bob).isSuccess);
  offset = 0;

  // ── apps, sites, navigation, theme ─────────────────────────────────────
  CreateAppRequest app;
  app.tenantId = t;
  app.actor = jane;
  app.spec.name = "Manage Leads";
  app.spec.launchUrl = "leads";
  assert(p.apps.create(app).code == 422);
  app.spec.launchUrl = "/apps/leads/index.html";
  auto appId = AppId(p.apps.create(app).id);

  CreateSiteRequest site;
  site.tenantId = t;
  site.actor = jane;
  site.spec.name = "Sales Portal";
  auto siteResult = p.sites.create(site);
  assert(siteResult.isSuccess, siteResult.message);
  auto siteId = SiteId(siteResult.id);
  assert(p.sites.get(t, siteId).themeName == "Morning Horizon" && p.sites.get(t, siteId).alias_ == "sales-portal");
  assert(p.sites.publish(t, siteId, jane).code == 409); // no navigation yet

  CreateNavigationItemRequest nav;
  nav.tenantId = t;
  nav.actor = jane;
  nav.parentId = siteId;
  nav.spec.title = "Sales";
  nav.spec.itemType = NavigationItemType.group;
  auto groupId = NavigationItemId(p.navigationItems.create(nav).id);
  nav.spec.title = "Leads";
  nav.spec.itemType = NavigationItemType.app;
  nav.spec.targetAppId = appId;
  nav.spec.parentId = groupId;
  auto leadsNav = p.navigationItems.create(nav);
  assert(leadsNav.isSuccess, leadsNav.message);
  nav.spec.title = "Pipeline";
  nav.spec.itemType = NavigationItemType.workpage;
  nav.spec.targetWorkpageId = pipelineId;
  nav.spec.parentId = NavigationItemId(leadsNav.id);
  assert(p.navigationItems.create(nav).code == 422); // parent is no group
  nav.spec.parentId = groupId;
  assert(p.navigationItems.create(nav).isSuccess);
  assert(p.navigationItems.remove(t, groupId, jane).code == 409); // has children
  assert(p.apps.remove(t, appId, jane).code == 409); // linked by navigation
  assert(p.workpages.remove(t, pipelineId, jane).code == 409); // linked by navigation
  assert(p.sites.publish(t, siteId, jane).isSuccess);
  assert(p.sites.remove(t, siteId, jane).code == 409); // published
  auto themeId = p.sites.get(t, siteId).themeId;
  assert(p.themes.remove(t, themeId, jane).code == 409);

  CreatePluginRequest plugin;
  plugin.tenantId = t;
  plugin.actor = jane;
  plugin.spec.name = "Chat Bot";
  plugin.spec.scriptUrl = "https://cdn.example.com/bot.js";
  plugin.spec.assignedSites = ["Sales Portal"];
  auto pluginId = ShellPluginId(p.shellPlugins.create(plugin).id);
  assert(p.shellPlugins.activate(t, pluginId, jane).code == 422); // no hook point

  // ── content providers via the gateway ──────────────────────────────────
  CreateProviderRequest cp;
  cp.tenantId = t;
  cp.actor = jane;
  cp.spec.name = "News";
  cp.spec.endpointUrl = "https://news.example.com/feed";
  cp.spec.refreshIntervalSec = 600;
  auto providerId = ExternalContentProviderId(p.contentProviders.create(cp).id);
  assert(p.contentProviders.sync(t, providerId, jane).code == 409); // not connected
  assert(p.contentProviders.connect(t, providerId, jane).isSuccess);
  assert(p.contentProviders.sync(t, providerId, jane).isSuccess);
  assert(p.contentProviders.get(t, providerId).itemCount > 0);
  cp.spec.name = "Broken";
  cp.spec.endpointUrl = "https://x.example.com/[fail]";
  auto brokenId = ExternalContentProviderId(p.contentProviders.create(cp).id);
  assert(p.contentProviders.connect(t, brokenId, jane).isSuccess); // recorded as error
  assert(p.contentProviders.get(t, brokenId).status == ProviderStatus.error);

  // ── statistics ─────────────────────────────────────────────────────────
  auto stats = p.statistics.statistics(t);
  assert(stats.workspaces == 1 && stats.members == 2 && stats.workpages == 2 && stats.widgets == 1);
  assert(stats.contentPublished == 1 && stats.articlesPublished == 1 && stats.sitesPublished == 1);
  assert(stats.providersConnected == 1 && stats.users == 2 && stats.roles == 6 && stats.lastPublishedAt > 0);

  // ── archive blocks new content; deletion cascades ──────────────────────
  assert(p.workspaces.archive(t, wsId, jane).isSuccess);
  ct.spec.title = "Late";
  assert(p.content.create(ct).code == 409);
  assert(p.sites.unpublish(t, siteId, jane).isSuccess);
  assert(p.sites.remove(t, siteId, jane).isSuccess);
  assert(p.navigationItems.list(t).length == 0);
  assert(p.shellPlugins.get(t, pluginId).assignedSites.length == 0);
  assert(p.workspaces.remove(t, wsId, jane).isSuccess);
  assert(p.workpages.list(t).length == 0 && p.widgets.list(t).length == 0 && p.content.list(t).length == 0);
  assert(p.feedEntries.list(t).length == 0 && p.events.list(t).length == 0 && p.knowledgeBase.list(t).length == 0);
  assert(p.cards.remove(t, cardId, jane).isSuccess); // no widget left
}
