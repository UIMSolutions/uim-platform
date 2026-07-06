/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.transport.domain.types;

import uim.platform.transport;

mixin(ShowModule!());

@safe:

struct TransportNodeId {
    mixin(IdTemplate);
}

struct TransportRouteId {
    mixin(IdTemplate);
}

struct TransportRequestId {
    mixin(IdTemplate);
}

struct ImportQueueEntryId {
    mixin(IdTemplate);
}

struct TransportActionId {
    mixin(IdTemplate);
}
