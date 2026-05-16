/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.transport.domain.entities.import_queue_entry;

import uim.platform.transport;

mixin(ShowModule!());

@safe:

/// An entry in the import queue of a transport node.
/// Represents a transport request that is pending, in progress, or completed at that node.
struct ImportQueueEntry {
    mixin TenantEntity!ImportQueueEntryId;

    TransportNodeId nodeId;
    TransportRequestId requestId;
    ImportStatus status = ImportStatus.initial;
    int queuePosition = 0;
    string queuedAt;
    string startedAt;
    long completedAt;
    string errorMessage;
    string importLog;
    bool isSelected = true;
    long scheduledAt;

    Json toJson() const {
        return entityToJson
            .set("nodeId", nodeId.value)
            .set("requestId", requestId.value)
            .set("status", status.to!string)
            .set("queuePosition", queuePosition)
            .set("queuedAt", queuedAt)
            .set("startedAt", startedAt)
            .set("completedAt", completedAt)
            .set("errorMessage", errorMessage)
            .set("importLog", importLog)
            .set("isSelected", isSelected)
            .set("scheduledAt", scheduledAt);
    }
}
