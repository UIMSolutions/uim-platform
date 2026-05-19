/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.appevents.domain.valueobjects;

@safe:

struct EventSubscriptionId { string value; bool isNull() const { return value.length == 0; } }
struct EventTopicId        { string value; bool isNull() const { return value.length == 0; } }
struct EventChannelId      { string value; bool isNull() const { return value.length == 0; } }
struct EventMessageId      { string value; bool isNull() const { return value.length == 0; } }
struct EventFilterId       { string value; bool isNull() const { return value.length == 0; } }
struct DeadLetterEntryId   { string value; bool isNull() const { return value.length == 0; } }
struct FormationId         { string value; bool isNull() const { return value.length == 0; } }
struct SystemRegistrationId{ string value; bool isNull() const { return value.length == 0; } }
struct TenantId            { string value; bool isNull() const { return value.length == 0; } }
struct UserId              { string value; bool isNull() const { return value.length == 0; } }
