/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.events.domain.types;

import uim.platform.events;

// mixin(ShowModule!());

@safe:

struct MessagingServiceId  { string value; this(string v) { value = v; } mixin DomainId; }
struct MessageClientId     { string value; this(string v) { value = v; } mixin DomainId; }
struct QueueId             { string value; this(string v) { value = v; } mixin DomainId; }
struct QueueSubscriptionId { string value; this(string v) { value = v; } mixin DomainId; }
struct WebhookId           { string value; this(string v) { value = v; } mixin DomainId; }
struct EventChannelId      { string value; this(string v) { value = v; } mixin DomainId; }
struct MessageBindingId    { string value; this(string v) { value = v; } mixin DomainId; }
