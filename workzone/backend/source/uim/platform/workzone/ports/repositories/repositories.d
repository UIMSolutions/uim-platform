/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.ports.repositories.repositories;

import uim.platform.workzone;

mixin(ShowModule!());

@safe:

/// Persistence port of every Work Zone aggregate: the tenant repository plus
/// lookups by display name (name / title), by workspace and by specification.
interface IWorkzoneRepository(TEntity, TId) : ITenantRepository!(TEntity, TId) {
  /// First aggregate whose display name (see nameOf) equals `name` (TEntity.init if none).
  TEntity findByName(TenantId tenantId, string name);
  /// Aggregates living in a workspace.
  TEntity[] findByWorkspace(TenantId tenantId, WorkspaceId workspaceId);
  /// Aggregates satisfying a specification.
  TEntity[] findMatching(TenantId tenantId, scope bool delegate(const TEntity) @safe specification);
}

alias IWorkspaceRepository = IWorkzoneRepository!(Workspace, WorkspaceId);
alias IWorkpageRepository = IWorkzoneRepository!(Workpage, WorkpageId);
alias IWidgetRepository = IWorkzoneRepository!(PageWidget, WidgetId);
alias IChannelRepository = IWorkzoneRepository!(WorkspaceChannel, ChannelId);
alias IContentRepository = IWorkzoneRepository!(ContentItem, ContentId);
alias IFeedEntryRepository = IWorkzoneRepository!(FeedEntry, FeedEntryId);
alias IEventRepository = IWorkzoneRepository!(CalendarEvent, EventId);
alias ISurveyRepository = IWorkzoneRepository!(Survey, SurveyId);
alias IForumTopicRepository = IWorkzoneRepository!(ForumTopic, ForumTopicId);
alias IKnowledgeBaseRepository = IWorkzoneRepository!(KnowledgeBaseArticle, KBArticleId);
alias ITaskRepository = IWorkzoneRepository!(WorkTask, TaskId);
alias INotificationRepository = IWorkzoneRepository!(Notification, NotificationId);
alias ICardRepository = IWorkzoneRepository!(Card, CardId);
alias IAppRepository = IWorkzoneRepository!(AppRegistration, AppId);
alias IContentProviderRepository = IWorkzoneRepository!(ExternalContentProvider, ExternalContentProviderId);
alias IShellPluginRepository = IWorkzoneRepository!(ShellPlugin, ShellPluginId);
alias ISiteRepository = IWorkzoneRepository!(Site, SiteId);
alias INavigationItemRepository = IWorkzoneRepository!(NavigationItem, NavigationItemId);
alias IThemeRepository = IWorkzoneRepository!(Theme, ThemeId);
alias IPageTemplateRepository = IWorkzoneRepository!(PageTemplate, PageTemplateId);
alias IRoleRepository = IWorkzoneRepository!(Role, RoleId);
alias IGroupRepository = IWorkzoneRepository!(UserGroup, GroupId);
alias ITagRepository = IWorkzoneRepository!(Tag, TagId);
alias IUserProfileRepository = IWorkzoneRepository!(UserProfile, UserProfileId);
