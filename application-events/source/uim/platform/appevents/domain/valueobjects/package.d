/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.appevents.domain.valueobjects;

import uim.platform.service;

// mixin(ShowModule!());

@safe:

// TenantId and UserId are provided by uim.platform.service

struct EventSubscriptionId  {
    string value;
    this(string value) { this.value = value; }
    mixin IdTemplate;
}
struct EventTopicId         {
    string value;
    this(string value) { this.value = value; }
    mixin IdTemplate;
}
struct EventChannelId       {
    string value;
    this(string value) { this.value = value; }
    mixin IdTemplate;
}
struct EventMessageId       {
    string value;
    this(string value) { this.value = value; }
    mixin IdTemplate;
}
struct EventFilterId        {
    string value;
    this(string value) { this.value = value; }
    mixin IdTemplate;
}
struct DeadLetterEntryId    {
    string value;
    this(string value) { this.value = value; }
    mixin IdTemplate;
}
struct FormationId          {
    string value;
    this(string value) { this.value = value; }
    mixin IdTemplate;
}
struct SystemRegistrationId {
    string value;
    this(string value) { this.value = value; }
    mixin IdTemplate;
}
