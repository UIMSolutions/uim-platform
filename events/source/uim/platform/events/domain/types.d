/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.events.domain.types;

import uim.platform.events;

mixin(ShowModule!());

@safe:

struct MessagingServiceId  { mixin(IdTemplate); }
struct MessageClientId     { mixin(IdTemplate); }
struct QueueId             { mixin(IdTemplate); }
struct QueueSubscriptionId { mixin(IdTemplate); }
struct WebhookId           { mixin(IdTemplate); }
struct EventChannelId      { mixin(IdTemplate); }
struct MessageBindingId    { mixin(IdTemplate); }
