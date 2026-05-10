/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.transport.domain.services.transport_validator;

import uim.platform.transport;

mixin(ShowModule!());

@safe:

class TransportValidator {
    static bool isValidNode(TransportNode node) {
        return node.name.length > 0;
    }

    static bool isValidRoute(TransportRoute route) {
        return route.name.length > 0
            && route.sourceNodeId.value.length > 0
            && route.destinationNodeId.value.length > 0
            && route.sourceNodeId.value != route.destinationNodeId.value;
    }

    static bool isValidRequest(TransportRequest req) {
        return req.name.length > 0;
    }

    static bool isValidQueueEntry(ImportQueueEntry entry) {
        return entry.nodeId.value.length > 0
            && entry.requestId.value.length > 0;
    }

    static bool isValidAction(TransportAction action) {
        return action.requestId.value.length > 0
            && action.performedBy.length > 0;
    }
}
