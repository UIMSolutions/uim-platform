/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.workzone.domain.types;

import uim.platform.workzone;

// mixin(ShowModule!());

@safe:
/// Unique identifier type aliases for type safety.
struct WorkspaceId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}
struct WorkpageId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}
struct CardId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}
struct ContentId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}
struct FeedEntryId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}
struct NotificationId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}
struct TaskId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}
struct ChannelId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}
struct AppId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}
struct WidgetId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}

struct RoleId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}
struct SiteId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}
struct EventId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}
struct SurveyId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}
struct ForumTopicId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}
struct KBArticleId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}
struct GroupId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}
struct TagId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}
struct ThemeId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}
struct NavigationItemId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}
struct PageTemplateId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}
struct ExternalContentProviderId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}
struct ShellPluginId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}
struct UserProfileId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}
struct MemberId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}