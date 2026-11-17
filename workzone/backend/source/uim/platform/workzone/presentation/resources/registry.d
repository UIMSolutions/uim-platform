/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// The resource catalogue of the Work Zone service: which kinds exist, how they
/// are named per protocol, their table columns, actions, secrets and references.
module uim.platform.workzone.presentation.resources.registry;

import uim.platform.workzone;
import uim.platform.workzone.presentation.resources.adapter;

mixin(ShowModule!());

@safe:

/// Payload fields that reference another resource (accept an id or a unique
/// name / title), mapped to the REST path of the referenced resource.
enum string[string] referenceFields = [
  "workspaceId": "workspaces",
  "workpageId": "workpages",
  "targetWorkpageId": "workpages",
  "siteId": "sites",
  "themeId": "themes",
  "templateId": "page-templates",
  "cardId": "cards",
  "appId": "apps",
  "targetAppId": "apps",
  "parentId": "navigation-items",
];

/// Payload fields tried (in order) when a resource is addressed by name.
enum string[] nameFields = ["name", "title", "displayName", "userId", "alias"];

class ResourceRegistry {
  protected IResourceAdapter[] _adapters;
  WorkzonePorts ports;

  this(WorkzonePorts ports) {
    this.ports = ports;
    auto p = ports;

    // ── collaboration ──────────────────────────────────────────────────────
    _adapters ~= new ResourceAdapter!(Workspace, WorkspaceId, CreateWorkspaceRequest, UpdateWorkspaceRequest)(
      p.workspaces, "workspaces", "Workspaces", "Workspace", "Workspaces", "")
      .column("Name", "name").column("Alias", "alias").column("Type", "type").column("Status", "status")
      .column("Members", "members").column("Language", "defaultLanguage").column("ID", "id")
      .action("add-member", "Add Member", (who, id, x) => p.workspaces.addMember(who.tenantId, id,
          WorkspaceMember(fieldString(x, "userId"), fieldString(x, "displayName"),
          parseEnum!MemberRole(fieldString(x, "role"), MemberRole.contributor)), who.userId), ["userId", "displayName", "role"])
      .action("remove-member", "Remove Member", (who, id, x) => p.workspaces.removeMember(who.tenantId, id,
          fieldString(x, "userId"), who.userId), ["userId"])
      .action("change-role", "Change Role", (who, id, x) => p.workspaces.changeRole(who.tenantId, id,
          fieldString(x, "userId"), parseEnum!MemberRole(fieldString(x, "role"), MemberRole.contributor), who.userId),
          ["userId", "role"])
      .action("archive", "Archive", (who, id, _) => p.workspaces.archive(who.tenantId, id, who.userId))
      .action("suspend", "Suspend", (who, id, _) => p.workspaces.suspend(who.tenantId, id, who.userId))
      .action("restore", "Restore", (who, id, _) => p.workspaces.restore(who.tenantId, id, who.userId));

    _adapters ~= new ResourceAdapter!(Workpage, WorkpageId, CreateWorkpageRequest, UpdateWorkpageRequest)(
      p.workpages, "workpages", "Workpages", "Workpage", "Workpages", "workspaceId")
      .column("Title", "title").column("Workspace", "workspaceName").column("Template", "templateName")
      .column("Default", "isDefault").column("Visible", "visible").column("Sort", "sortOrder").column("ID", "id")
      .action("make-default", "Make Default", (who, id, _) => p.workpages.makeDefault(who.tenantId, id, who.userId));

    _adapters ~= new ResourceAdapter!(PageWidget, WidgetId, CreateWidgetRequest, UpdateWidgetRequest)(
      p.widgets, "widgets", "Widgets", "Widget", "Widgets", "workpageId")
      .column("Title", "title").column("Workpage", "workpageTitle").column("Size", "size").column("Row", "row")
      .column("Col", "col").column("Card", "cardId").column("App", "appId").column("ID", "id")
      .action("move", "Move", (who, id, x) => p.widgets.move(who.tenantId, id, cast(int) fieldLong(x, "row"),
          cast(int) fieldLong(x, "col"), who.userId), ["row", "col"]);

    _adapters ~= new ResourceAdapter!(WorkspaceChannel, ChannelId, CreateChannelRequest, UpdateChannelRequest)(
      p.channels, "channels", "Channels", "Channel", "Channels", "workspaceId")
      .column("Name", "name").column("Workspace", "workspaceName").column("Type", "channelType")
      .column("Active", "active").column("Source", "sourceUrl").column("ID", "id")
      .secret("authToken")
      .action("activate", "Activate", (who, id, _) => p.channels.activate(who.tenantId, id, who.userId))
      .action("deactivate", "Deactivate", (who, id, _) => p.channels.deactivate(who.tenantId, id, who.userId));

    _adapters ~= new ResourceAdapter!(ContentItem, ContentId, CreateContentRequest, UpdateContentRequest)(
      p.content, "content", "ContentItems", "ContentItem", "Content", "workspaceId")
      .column("Title", "title").column("Workspace", "workspaceName").column("Type", "contentType")
      .column("Status", "status").column("Author", "authorName").column("Tags", "tags").column("Likes", "likeCount")
      .column("Published", "publishedAt").column("ID", "id")
      .action("publish", "Publish", (who, id, _) => p.content.publish(who.tenantId, id, who.userId))
      .action("archive", "Archive", (who, id, _) => p.content.archive(who.tenantId, id, who.userId))
      .action("pin", "Pin", (who, id, _) => p.content.pin(who.tenantId, id, who.userId))
      .action("unpin", "Unpin", (who, id, _) => p.content.unpin(who.tenantId, id, who.userId))
      .action("like", "Like", (who, id, _) => p.content.like(who.tenantId, id, who.userId));

    _adapters ~= new ResourceAdapter!(FeedEntry, FeedEntryId, CreateFeedEntryRequest, UpdateFeedEntryRequest)(
      p.feedEntries, "feeds", "FeedEntries", "FeedEntry", "Feed", "workspaceId")
      .column("Workspace", "workspaceName").column("Actor", "actorName").column("Action", "action")
      .column("Object", "objectTitle").column("Message", "message").column("Created", "createdAt").column("ID", "id");

    _adapters ~= new ResourceAdapter!(CalendarEvent, EventId, CreateEventRequest, UpdateEventRequest)(
      p.events, "events", "Events", "Event", "Events", "workspaceId")
      .column("Title", "title").column("Workspace", "workspaceName").column("Starts", "startsAt")
      .column("Ends", "endsAt").column("Status", "status").column("Attendees", "attendeeIds").column("ID", "id")
      .action("cancel", "Cancel", (who, id, _) => p.events.cancel(who.tenantId, id, who.userId))
      .action("add-attendee", "Add Attendee", (who, id, x) => p.events.addAttendee(who.tenantId, id,
          fieldString(x, "userId"), who.userId), ["userId"])
      .action("remove-attendee", "Remove Attendee", (who, id, x) => p.events.removeAttendee(who.tenantId, id,
          fieldString(x, "userId"), who.userId), ["userId"]);

    _adapters ~= new ResourceAdapter!(Survey, SurveyId, CreateSurveyRequest, UpdateSurveyRequest)(
      p.surveys, "surveys", "Surveys", "Survey", "Surveys", "workspaceId")
      .column("Title", "title").column("Workspace", "workspaceName").column("Status", "status")
      .column("Questions", "questions").column("Responses", "responseCount").column("Ends", "endsAt").column("ID", "id")
      .action("activate", "Activate", (who, id, _) => p.surveys.activate(who.tenantId, id, who.userId))
      .action("close", "Close", (who, id, _) => p.surveys.close(who.tenantId, id, who.userId))
      .action("archive", "Archive", (who, id, _) => p.surveys.archive(who.tenantId, id, who.userId))
      .action("respond", "Respond", (who, id, _) => p.surveys.respond(who.tenantId, id, who.userId));

    _adapters ~= new ResourceAdapter!(ForumTopic, ForumTopicId, CreateForumTopicRequest, UpdateForumTopicRequest)(
      p.forumTopics, "forum-topics", "ForumTopics", "ForumTopic", "Forum", "workspaceId")
      .column("Title", "title").column("Workspace", "workspaceName").column("Author", "authorName")
      .column("Status", "status").column("Replies", "replyCount").column("Pinned", "pinned").column("Locked", "locked")
      .column("ID", "id")
      .action("reply", "Reply", (who, id, _) => p.forumTopics.reply(who.tenantId, id, who.userId))
      .action("close", "Close", (who, id, _) => p.forumTopics.close(who.tenantId, id, who.userId))
      .action("reopen", "Reopen", (who, id, _) => p.forumTopics.reopen(who.tenantId, id, who.userId))
      .action("pin", "Pin", (who, id, _) => p.forumTopics.pin(who.tenantId, id, who.userId))
      .action("unpin", "Unpin", (who, id, _) => p.forumTopics.unpin(who.tenantId, id, who.userId))
      .action("lock", "Lock", (who, id, _) => p.forumTopics.lock(who.tenantId, id, who.userId))
      .action("unlock", "Unlock", (who, id, _) => p.forumTopics.unlock(who.tenantId, id, who.userId));

    _adapters ~= new ResourceAdapter!(KnowledgeBaseArticle, KBArticleId, CreateArticleRequest, UpdateArticleRequest)(
      p.knowledgeBase, "knowledge-base", "KnowledgeBaseArticles", "KnowledgeBaseArticle", "Knowledge Base", "workspaceId")
      .column("Title", "title").column("Workspace", "workspaceName").column("Category", "category")
      .column("Status", "status").column("Version", "version").column("Helpful", "helpfulCount").column("ID", "id")
      .action("submit", "Submit for Review", (who, id, _) => p.knowledgeBase.submit(who.tenantId, id, who.userId))
      .action("publish", "Publish", (who, id, _) => p.knowledgeBase.publish(who.tenantId, id, who.userId))
      .action("archive", "Archive", (who, id, _) => p.knowledgeBase.archive(who.tenantId, id, who.userId))
      .action("mark-helpful", "Helpful", (who, id, _) => p.knowledgeBase.markHelpful(who.tenantId, id, who.userId));

    // ── inbox ──────────────────────────────────────────────────────────────
    _adapters ~= new ResourceAdapter!(WorkTask, TaskId, CreateTaskRequest, UpdateTaskRequest)(
      p.tasks, "tasks", "Tasks", "Task", "Tasks", "")
      .column("Title", "title").column("Assignee", "assigneeName").column("Priority", "priority")
      .column("Status", "status").column("Due", "dueAt").column("Source", "sourceApp").column("ID", "id")
      .action("start", "Start", (who, id, _) => p.tasks.start(who.tenantId, id, who.userId))
      .action("complete", "Complete", (who, id, _) => p.tasks.complete(who.tenantId, id, who.userId))
      .action("cancel", "Cancel", (who, id, _) => p.tasks.cancel(who.tenantId, id, who.userId))
      .action("reopen", "Reopen", (who, id, _) => p.tasks.reopen(who.tenantId, id, who.userId));

    _adapters ~= new ResourceAdapter!(Notification, NotificationId, CreateNotificationRequest, UpdateNotificationRequest)(
      p.notifications, "notifications", "Notifications", "Notification", "Notifications", "")
      .column("Title", "title").column("Recipient", "recipientId").column("Priority", "priority")
      .column("Status", "status").column("Source", "sourceApp").column("Expires", "expiresAt").column("ID", "id")
      .action("mark-read", "Mark Read", (who, id, _) => p.notifications.markRead(who.tenantId, id, who.userId))
      .action("mark-unread", "Mark Unread", (who, id, _) => p.notifications.markUnread(who.tenantId, id, who.userId))
      .action("dismiss", "Dismiss", (who, id, _) => p.notifications.dismiss(who.tenantId, id, who.userId));

    // ── integration ────────────────────────────────────────────────────────
    _adapters ~= new ResourceAdapter!(Card, CardId, CreateCardRequest, UpdateCardRequest)(
      p.cards, "cards", "Cards", "Card", "Cards", "")
      .column("Title", "title").column("Type", "cardType").column("Data Source", "dataSourceUrl")
      .column("Refresh (s)", "refreshIntervalSec").column("Active", "active").column("ID", "id")
      .secret("authToken")
      .action("activate", "Activate", (who, id, _) => p.cards.activate(who.tenantId, id, who.userId))
      .action("deactivate", "Deactivate", (who, id, _) => p.cards.deactivate(who.tenantId, id, who.userId));

    _adapters ~= new ResourceAdapter!(AppRegistration, AppId, CreateAppRequest, UpdateAppRequest)(
      p.apps, "apps", "Apps", "App", "Apps", "")
      .column("Name", "name").column("Launch URL", "launchUrl").column("Vendor", "vendor").column("Version", "version")
      .column("Platforms", "supportedPlatforms").column("Status", "status").column("ID", "id")
      .action("activate", "Activate", (who, id, _) => p.apps.activate(who.tenantId, id, who.userId))
      .action("deactivate", "Deactivate", (who, id, _) => p.apps.deactivate(who.tenantId, id, who.userId))
      .action("deprecate", "Deprecate", (who, id, _) => p.apps.deprecate(who.tenantId, id, who.userId));

    _adapters ~= new ResourceAdapter!(ExternalContentProvider, ExternalContentProviderId, CreateProviderRequest,
        UpdateProviderRequest)(p.contentProviders, "content-providers", "ContentProviders", "ContentProvider",
        "Content Providers", "")
      .column("Name", "name").column("Type", "providerType").column("Endpoint", "endpointUrl")
      .column("Status", "status").column("Items", "itemCount").column("Last Sync", "lastSyncAt").column("ID", "id")
      .secret("authConfig")
      .action("connect", "Connect", (who, id, _) => p.contentProviders.connect(who.tenantId, id, who.userId))
      .action("disconnect", "Disconnect", (who, id, _) => p.contentProviders.disconnect(who.tenantId, id, who.userId))
      .action("sync", "Sync", (who, id, _) => p.contentProviders.sync(who.tenantId, id, who.userId));

    _adapters ~= new ResourceAdapter!(ShellPlugin, ShellPluginId, CreatePluginRequest, UpdatePluginRequest)(
      p.shellPlugins, "shell-plugins", "ShellPlugins", "ShellPlugin", "Shell Plugins", "")
      .column("Name", "name").column("Version", "version").column("Sites", "assignedSites")
      .column("Hook Points", "hookPoints").column("Status", "status").column("ID", "id")
      .action("activate", "Activate", (who, id, _) => p.shellPlugins.activate(who.tenantId, id, who.userId))
      .action("deactivate", "Deactivate", (who, id, _) => p.shellPlugins.deactivate(who.tenantId, id, who.userId));

    // ── sites & administration ─────────────────────────────────────────────
    _adapters ~= new ResourceAdapter!(Site, SiteId, CreateSiteRequest, UpdateSiteRequest)(
      p.sites, "sites", "Sites", "Site", "Sites", "")
      .column("Name", "name").column("Alias", "alias").column("Theme", "themeName").column("Status", "status")
      .column("Published", "publishedAt").column("ID", "id")
      .action("publish", "Publish", (who, id, _) => p.sites.publish(who.tenantId, id, who.userId))
      .action("unpublish", "Unpublish", (who, id, _) => p.sites.unpublish(who.tenantId, id, who.userId))
      .action("start-maintenance", "Maintenance", (who, id, _) => p.sites.startMaintenance(who.tenantId, id, who.userId))
      .action("archive", "Archive", (who, id, _) => p.sites.archive(who.tenantId, id, who.userId));

    _adapters ~= new ResourceAdapter!(NavigationItem, NavigationItemId, CreateNavigationItemRequest,
        UpdateNavigationItemRequest)(p.navigationItems, "navigation-items", "NavigationItems", "NavigationItem",
        "Navigation", "siteId")
      .column("Title", "title").column("Site", "siteName").column("Type", "itemType").column("Target URL", "targetUrl")
      .column("App", "targetAppName").column("Sort", "sortOrder").column("Visible", "visible").column("ID", "id");

    _adapters ~= new ResourceAdapter!(Theme, ThemeId, CreateThemeRequest, UpdateThemeRequest)(
      p.themes, "themes", "Themes", "Theme", "Themes", "")
      .column("Name", "name").column("Base Theme", "baseTheme").column("Primary", "primaryColor")
      .column("Default", "isDefault").column("Predefined", "predefined").column("ID", "id")
      .action("make-default", "Make Default", (who, id, _) => p.themes.makeDefault(who.tenantId, id, who.userId));

    _adapters ~= new ResourceAdapter!(PageTemplate, PageTemplateId, CreatePageTemplateRequest, UpdatePageTemplateRequest)(
      p.pageTemplates, "page-templates", "PageTemplates", "PageTemplate", "Page Templates", "")
      .column("Name", "name").column("Sections", "sections").column("Default", "isDefault")
      .column("Public", "isPublic").column("ID", "id")
      .action("make-default", "Make Default", (who, id, _) => p.pageTemplates.makeDefault(who.tenantId, id, who.userId));

    _adapters ~= new ResourceAdapter!(Role, RoleId, CreateRoleRequest, UpdateRoleRequest)(
      p.roles, "roles", "Roles", "Role", "Roles", "")
      .column("Name", "name").column("Permissions", "permissions").column("Default", "isDefault")
      .column("Predefined", "predefined").column("ID", "id");

    _adapters ~= new ResourceAdapter!(UserGroup, GroupId, CreateGroupRequest, UpdateGroupRequest)(
      p.groups, "groups", "UserGroups", "UserGroup", "Groups", "")
      .column("Name", "name").column("Type", "groupType").column("Members", "memberIds").column("Roles", "roles")
      .column("Active", "active").column("ID", "id")
      .action("add-member", "Add Member", (who, id, x) => p.groups.addMember(who.tenantId, id,
          fieldString(x, "userId"), who.userId), ["userId"])
      .action("remove-member", "Remove Member", (who, id, x) => p.groups.removeMember(who.tenantId, id,
          fieldString(x, "userId"), who.userId), ["userId"]);

    _adapters ~= new ResourceAdapter!(Tag, TagId, CreateTagRequest, UpdateTagRequest)(
      p.tags, "tags", "Tags", "Tag", "Tags", "")
      .column("Name", "name").column("Colour", "color").column("Parent", "parentTag").column("ID", "id");

    _adapters ~= new ResourceAdapter!(UserProfile, UserProfileId, CreateUserProfileRequest, UpdateUserProfileRequest)(
      p.userProfiles, "user-profiles", "UserProfiles", "UserProfile", "Users", "")
      .column("Display Name", "displayName").column("User", "userId").column("E-Mail", "email")
      .column("Department", "department").column("Roles", "roles").column("Active", "active")
      .column("Last Login", "lastLoginAt").column("ID", "id")
      .action("activate", "Activate", (who, id, _) => p.userProfiles.activate(who.tenantId, id, who.userId))
      .action("deactivate", "Deactivate", (who, id, _) => p.userProfiles.deactivate(who.tenantId, id, who.userId))
      .action("record-login", "Record Login", (who, id, _) => p.userProfiles.recordLogin(who.tenantId, id, who.userId));
  }

  IResourceAdapter[] adapters() {
    return _adapters;
  }

  /// Adapter by REST path / CLI command (null if unknown).
  IResourceAdapter byPath(string path) {
    foreach (a; _adapters)
      if (a.path == path)
        return a;
    return null;
  }

  /// Adapter by OData entity set (null if unknown).
  IResourceAdapter bySet(string setName) {
    foreach (a; _adapters)
      if (a.setName == setName)
        return a;
    return null;
  }

  /// Adapter owning an OData action name (null if unknown); `action` receives the action.
  IResourceAdapter byODataAction(string odataName, out ResourceAction action) {
    foreach (a; _adapters)
      foreach (act; a.actions)
        if (act.odataName == odataName) {
          action = act;
          return a;
        }
    return null;
  }

  /// An id, or the id of the unique resource of `adapter` with that name / title.
  string resolve(IResourceAdapter adapter, TenantId tenantId, string idOrName) {
    if (adapter.get(tenantId, idOrName).type != Json.Type.null_)
      return idOrName;
    auto names = adapter.fields.map!(f => f.name).array;
    foreach (field; nameFields) {
      if (!names.canFind(field))
        continue;
      auto matches = adapter.list(tenantId, [field: idOrName]);
      if (matches.length == 1)
        return matches[0]["id"].get!string;
      if (matches.length > 1)
        throw new ResourceError(400, "Ambiguous", "'" ~ idOrName ~ "' matches " ~ matches.length.to!string
            ~ " " ~ adapter.path ~ " — use the id");
    }
    throw new ResourceError(404, "NotFound", adapter.typeName ~ " '" ~ idOrName ~ "' not found");
  }

  /// Resolve a reference field (workspaceId, siteId, cardId, ...).
  string resolveReference(string field, TenantId tenantId, string idOrName) {
    if (auto target = field in referenceFields)
      if (idOrName.length > 0)
        return resolve(byPath(*target), tenantId, idOrName);
    return idOrName;
  }

  /// A copy of `body` with every reference given by name replaced by its id.
  Json withReferences(TenantId tenantId, Json body) {
    if (body.type != Json.Type.object)
      return body;
    auto result = Json.emptyObject;
    foreach (k, v; body.get!(Json[string]))
      result[k] = (k in referenceFields) !is null && jsonText(v).length > 0
        ? Json(resolveReference(k, tenantId, jsonText(v))) : v;
    return result;
  }

  /// Statistics payload.
  Json statistics(TenantId tenantId) {
    return encode(ports.statistics.statistics(tenantId), true);
  }

  /// Run housekeeping and return the report payload.
  Json housekeeping(TenantId tenantId) {
    return encode(ports.housekeeping.run(tenantId), true);
  }

  /// Install the predefined content and return the report payload.
  Json seed(RequestIdentity who) {
    return encode(ports.seeder.seed(who.tenantId, who.userId), true);
  }
}

///
unittest {
  mixin(ShowTest!("ResourceRegistry"));

  WorkzoneConfig cfg;
  cfg.storage = "memory";
  auto registry = new ResourceRegistry(buildContainer(cfg).ports);
  RequestIdentity who;
  who.tenantId = TenantId("t1");
  who.userId = UserId("jane");
  assert(registry.seed(who)["created"].get!long == 20);
  assert(registry.adapters.length == 24);

  // lenient input, references by name
  auto workspaces = registry.byPath("workspaces");
  auto ws = workspaces.create(who, parseJsonString(`{"name": "Marketing", "type": "project", "enableWiki": "off"}`));
  assert(ws["alias"].get!string == "marketing" && ws["type"].get!string == "project" && !ws["enableWiki"].get!bool);
  auto page = registry.byPath("workpages").create(who, registry.withReferences(who.tenantId,
      parseJsonString(`{"workspaceId": "Marketing", "title": "Home", "templateId": "Dashboard"}`)));
  assert(page["templateName"].get!string == "Dashboard" && page["isDefault"].get!bool);

  // secrets are masked; a masked value in a PATCH keeps the stored secret
  auto cards = registry.byPath("cards");
  auto card = cards.create(who, parseJsonString(`{"title": "KPIs", "authType": "bearer", "authToken": "s3cret"}`));
  assert(card["authToken"].get!string == secretMask);
  auto patched = cards.update(who, card["id"].get!string, parseJsonString(`{"subtitle": "x", "authToken": "********"}`));
  assert(patched["subtitle"].get!string == "x");
  assert(registry.ports.cards.get(who.tenantId, CardId(card["id"].get!string)).authToken == "s3cret");

  // widgets reference cards by title
  auto widget = registry.byPath("widgets").create(who, registry.withReferences(who.tenantId,
      parseJsonString(`{"workpageId": "Home", "cardId": "KPIs", "size": "small", "parameters": "filter=open"}`)));
  assert(widget["title"].get!string == "KPIs" && widget["parameters"][0]["value"].get!string == "open");

  // business errors become ResourceErrors with HTTP status
  int status;
  try workspaces.create(who, parseJsonString(`{"name": "Marketing"}`));
  catch (ResourceError e) status = e.status;
  assert(status == 409);
  status = 0;
  try registry.withReferences(who.tenantId, parseJsonString(`{"workspaceId": "Nope"}`));
  catch (ResourceError e) status = e.status;
  assert(status == 404);

  ResourceAction act;
  assert(registry.byODataAction("AddMemberWorkspace", act) is workspaces && act.parameters == ["userId", "displayName", "role"]);
  auto added = workspaces.invoke(who, ws["id"].get!string, "add-member",
    parseJsonString(`{"userId": "bob", "role": "admin"}`));
  assert(added["members"].length == 2 && added["members"][1]["role"].get!string == "admin");
  assert(registry.resolve(workspaces, who.tenantId, "marketing") == ws["id"].get!string); // by alias
  assert(workspaces.list(who.tenantId, ["type": "project"]).length == 1);
  assert(registry.statistics(who.tenantId)["workspaces"].get!long == 1);
  assert(registry.bySet("Widgets").parentField == "workpageId");
  assert(registry.bySet("NavigationItems").inputFields[0].name == "siteId");
}
