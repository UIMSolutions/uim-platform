/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Typed identifiers. TenantId and UserId come from uim-framework.
module uim.platform.events.domain.types.ids;

import uim.platform.events;

mixin(ShowModule!());

@safe:

struct MessagingServiceId { mixin(IdTemplate); }
struct MessageClientId { mixin(IdTemplate); }
struct QueueId { mixin(IdTemplate); }
struct QueueSubscriptionId { mixin(IdTemplate); }
struct WebhookId { mixin(IdTemplate); }
struct EventChannelId { mixin(IdTemplate); }
struct MessageBindingId { mixin(IdTemplate); }
struct QueueMessageId { mixin(IdTemplate); }

/// A new random identifier (UUID v4).
string newResourceId() @trusted {
  import std.uuid : randomUUID;

  return randomUUID().toString;
}

///
unittest {
  assert(newResourceId().length == 36);
  assert(newResourceId() != newResourceId());
  assert(QueueId("q").value == "q" && QueueId.init.isNull);
}
