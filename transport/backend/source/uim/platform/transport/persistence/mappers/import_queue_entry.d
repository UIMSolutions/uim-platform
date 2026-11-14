/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.transport.persistence.mappers.import_queue_entry;

import uim.platform.transport;

mixin(ShowModule!());

@safe:

struct ImportQueueEntryMapper {
  static Json toRecord(const ImportQueueEntry e) {
    auto r = baseRecord(e);
    r["nodeId"] = e.nodeId.value;
    r["requestId"] = e.requestId.value;
    r["status"] = enumName(e.status);
    r["queuePosition"] = e.queuePosition;
    r["queuedAt"] = e.queuedAt;
    r["startedAt"] = e.startedAt;
    r["completedAt"] = e.completedAt;
    r["errorMessage"] = e.errorMessage;
    r["importLog"] = e.importLog;
    r["isSelected"] = e.isSelected;
    r["scheduledAt"] = e.scheduledAt;
    return r;
  }

  static ImportQueueEntry fromRecord(Json r) {
    ImportQueueEntry e;
    readBase(e, r);
    e.nodeId = TransportNodeId(fieldString(r, "nodeId"));
    e.requestId = TransportRequestId(fieldString(r, "requestId"));
    e.status = fieldEnum!ImportStatus(r, "status", ImportStatus.initial);
    e.queuePosition = fieldInt(r, "queuePosition");
    e.queuedAt = fieldLong(r, "queuedAt");
    e.startedAt = fieldLong(r, "startedAt");
    e.completedAt = fieldLong(r, "completedAt");
    e.errorMessage = fieldString(r, "errorMessage");
    e.importLog = fieldString(r, "importLog");
    e.isSelected = fieldBool(r, "isSelected", true);
    e.scheduledAt = fieldLong(r, "scheduledAt");
    return e;
  }
}
