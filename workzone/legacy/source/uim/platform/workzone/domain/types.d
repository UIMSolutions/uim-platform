/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.domain.types;

import uim.platform.workzone;

mixin(ShowModule!());

@safe:
/// Unique identifier type aliases for type safety.
struct WorkspaceId  {
    mixin(IdTemplate);
}
struct WorkpageId  {
    mixin(IdTemplate);
}
struct CardId  {
    mixin(IdTemplate);
}
struct ContentId  {
    mixin(IdTemplate);
}
struct FeedEntryId  {
    mixin(IdTemplate);
}
struct NotificationId  {
    mixin(IdTemplate);
}
struct TaskId  {
    mixin(IdTemplate);
}
struct ChannelId  {
    mixin(IdTemplate);
}
struct AppId  {
    mixin(IdTemplate);
}
struct WidgetId  {
    mixin(IdTemplate);
}

struct RoleId  {
    mixin(IdTemplate);
}
struct SiteId  {
    mixin(IdTemplate);
}
struct EventId  {
    mixin(IdTemplate);
}
struct SurveyId  {
    mixin(IdTemplate);
}
struct ForumTopicId  {
    mixin(IdTemplate);
}
struct KBArticleId  {
    mixin(IdTemplate);
}
struct GroupId  {
    mixin(IdTemplate);
}
struct TagId  {
    mixin(IdTemplate);
}
struct ThemeId  {
    mixin(IdTemplate);
}
struct NavigationItemId  {
    mixin(IdTemplate);
}
struct PageTemplateId  {
    mixin(IdTemplate);
}
struct ExternalContentProviderId  {
    mixin(IdTemplate);
}
struct ShellPluginId  {
    mixin(IdTemplate);
}
struct UserProfileId  {
    mixin(IdTemplate);
}
struct MemberId  {
    mixin(IdTemplate);
}