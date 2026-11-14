/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.transport.domain.types.ids;

import uim.platform.transport;

mixin(ShowModule!());

@safe:

/// Strongly-typed identifier of a transport node (deployment target / source).
struct TransportNodeId {
  mixin(IdTemplate);
}

/// Strongly-typed identifier of a transport route (directed node → node edge).
struct TransportRouteId {
  mixin(IdTemplate);
}

/// Strongly-typed identifier of a transport request (unit of transport).
struct TransportRequestId {
  mixin(IdTemplate);
}

/// Strongly-typed identifier of an import queue entry.
struct ImportQueueEntryId {
  mixin(IdTemplate);
}

/// Strongly-typed identifier of a transport action (audit trail record).
struct TransportActionId {
  mixin(IdTemplate);
}
