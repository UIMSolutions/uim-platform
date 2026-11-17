/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.ports.usecases.collaboration;

import uim.platform.workzone;

mixin(ShowModule!());

@safe:

/// Workspaces. Removal cascades to everything inside the workspace.
interface IManageWorkspacesUseCase : IManageResource!(Workspace, WorkspaceId, CreateWorkspaceRequest, UpdateWorkspaceRequest) {
  UsecaseResult addMember(TenantId tenantId, WorkspaceId id, WorkspaceMember member, UserId actor);
  UsecaseResult removeMember(TenantId tenantId, WorkspaceId id, string userId, UserId actor);
  UsecaseResult changeRole(TenantId tenantId, WorkspaceId id, string userId, MemberRole role, UserId actor);
  UsecaseResult archive(TenantId tenantId, WorkspaceId id, UserId actor);
  UsecaseResult suspend(TenantId tenantId, WorkspaceId id, UserId actor);
  UsecaseResult restore(TenantId tenantId, WorkspaceId id, UserId actor);
}

/// Workpages of a workspace. Removal cascades to the page's widgets.
interface IManageWorkpagesUseCase : IManageResource!(Workpage, WorkpageId, CreateWorkpageRequest, UpdateWorkpageRequest) {
  UsecaseResult makeDefault(TenantId tenantId, WorkpageId id, UserId actor);
}

/// Widgets on workpages.
interface IManageWidgetsUseCase : IManageResource!(PageWidget, WidgetId, CreateWidgetRequest, UpdateWidgetRequest) {
  UsecaseResult move(TenantId tenantId, WidgetId id, int row, int col, UserId actor);
}

/// Channels of a workspace.
interface IManageChannelsUseCase : IManageResource!(WorkspaceChannel, ChannelId, CreateChannelRequest, UpdateChannelRequest) {
  UsecaseResult activate(TenantId tenantId, ChannelId id, UserId actor);
  UsecaseResult deactivate(TenantId tenantId, ChannelId id, UserId actor);
}

/// Blog posts, wiki pages, announcements and documents.
interface IManageContentUseCase : IManageResource!(ContentItem, ContentId, CreateContentRequest, UpdateContentRequest) {
  UsecaseResult publish(TenantId tenantId, ContentId id, UserId actor);
  UsecaseResult archive(TenantId tenantId, ContentId id, UserId actor);
  UsecaseResult pin(TenantId tenantId, ContentId id, UserId actor);
  UsecaseResult unpin(TenantId tenantId, ContentId id, UserId actor);
  UsecaseResult like(TenantId tenantId, ContentId id, UserId actor);
}

/// Activity stream entries (also written by the application services).
interface IManageFeedEntriesUseCase : IManageResource!(FeedEntry, FeedEntryId, CreateFeedEntryRequest, UpdateFeedEntryRequest) {
}

/// Calendar events (status follows the clock via housekeeping).
interface IManageEventsUseCase : IManageResource!(CalendarEvent, EventId, CreateEventRequest, UpdateEventRequest) {
  UsecaseResult cancel(TenantId tenantId, EventId id, UserId actor);
  UsecaseResult addAttendee(TenantId tenantId, EventId id, string userId, UserId actor);
  UsecaseResult removeAttendee(TenantId tenantId, EventId id, string userId, UserId actor);
}

/// Surveys: draft → active → closed → archived.
interface IManageSurveysUseCase : IManageResource!(Survey, SurveyId, CreateSurveyRequest, UpdateSurveyRequest) {
  UsecaseResult activate(TenantId tenantId, SurveyId id, UserId actor);
  UsecaseResult close(TenantId tenantId, SurveyId id, UserId actor);
  UsecaseResult archive(TenantId tenantId, SurveyId id, UserId actor);
  UsecaseResult respond(TenantId tenantId, SurveyId id, UserId actor);
}

/// Forum topics.
interface IManageForumTopicsUseCase : IManageResource!(ForumTopic, ForumTopicId, CreateForumTopicRequest, UpdateForumTopicRequest) {
  UsecaseResult reply(TenantId tenantId, ForumTopicId id, UserId actor);
  UsecaseResult close(TenantId tenantId, ForumTopicId id, UserId actor);
  UsecaseResult reopen(TenantId tenantId, ForumTopicId id, UserId actor);
  UsecaseResult pin(TenantId tenantId, ForumTopicId id, UserId actor);
  UsecaseResult unpin(TenantId tenantId, ForumTopicId id, UserId actor);
  UsecaseResult lock(TenantId tenantId, ForumTopicId id, UserId actor);
  UsecaseResult unlock(TenantId tenantId, ForumTopicId id, UserId actor);
}

/// Knowledge base articles: draft → review → published → archived.
interface IManageKnowledgeBaseUseCase : IManageResource!(KnowledgeBaseArticle, KBArticleId, CreateArticleRequest, UpdateArticleRequest) {
  UsecaseResult submit(TenantId tenantId, KBArticleId id, UserId actor);
  UsecaseResult publish(TenantId tenantId, KBArticleId id, UserId actor);
  UsecaseResult archive(TenantId tenantId, KBArticleId id, UserId actor);
  UsecaseResult markHelpful(TenantId tenantId, KBArticleId id, UserId actor);
}
