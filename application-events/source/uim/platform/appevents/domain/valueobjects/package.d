/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.appevents.domain.valueobjects;

import uim.platform.service;

@safe:

// TenantId and UserId are provided by uim.platform.service

struct EventSubscriptionId  { string value; mixin DomainId; }
struct EventTopicId         { string value; mixin DomainId; }
struct EventChannelId       { string value; mixin DomainId; }
struct EventMessageId       { string value; mixin DomainId; }
struct EventFilterId        { string value; mixin DomainId; }
struct DeadLetterEntryId    { string value; mixin DomainId; }
struct FormationId          { string value; mixin DomainId; }
struct SystemRegistrationId { string value; mixin DomainId; }
