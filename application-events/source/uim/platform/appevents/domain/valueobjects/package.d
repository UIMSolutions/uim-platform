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

struct EventSubscriptionId {
    mixin(IdTemplate);
}

struct EventTopicId {
    mixin(IdTemplate);
}

struct EventChannelId {
    mixin(IdTemplate);
}

struct EventMessageId {
    mixin(IdTemplate);
}

struct EventFilterId {
    mixin(IdTemplate);
}

struct DeadLetterEntryId {
    mixin(IdTemplate);
}

struct FormationId {
    mixin(IdTemplate);
}

struct SystemRegistrationId {
    mixin(IdTemplate);
}
