/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.transport.domain.types;

import uim.platform.transport;

// mixin(ShowModule!());

@safe:

struct TransportNodeId {
    string value;
    this(string value) { this.value = value; }
    mixin IdTemplate;
}

struct TransportRouteId {
    string value;
    this(string value) { this.value = value; }
    mixin IdTemplate;
}

struct TransportRequestId {
    string value;
    this(string value) { this.value = value; }
    mixin IdTemplate;
}

struct ImportQueueEntryId {
    string value;
    this(string value) { this.value = value; }
    mixin IdTemplate;
}

struct TransportActionId {
    string value;
    this(string value) { this.value = value; }
    mixin IdTemplate;
}
