/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.content_agent.domain.types;

import uim.platform.content_agent;

mixin(ShowModule!());

@safe:
/// Unique identifier type aliases for type safety.
struct ContentPackageId {
  mixin(IdTemplate);
}

struct ContentTypeId {
  mixin(IdTemplate);
}

struct ContentProviderId {
  mixin(IdTemplate);
}

struct TransportRequestId {
  mixin(IdTemplate);
}

struct ExportJobId {
  mixin(IdTemplate);
}

struct ImportJobId {
  mixin(IdTemplate);
}

struct TransportQueueId {
  mixin(IdTemplate);
}

struct ContentActivityId {
  mixin(IdTemplate);
}