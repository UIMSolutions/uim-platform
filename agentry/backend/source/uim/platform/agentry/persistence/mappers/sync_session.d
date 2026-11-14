/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.agentry.persistence.mappers.sync_session;

import uim.platform.agentry;

mixin(ShowModule!());

@safe:

/// SyncSession ⇄ snapshot record.
struct SyncSessionMapper {
  static Json toRecord(const SyncSession e) {
    auto r = baseRecord(e);
    r["deviceId"] = e.deviceId.value;
    r["applicationId"] = e.applicationId.value;
    r["connectionId"] = e.connectionId.value;
    r["status"] = enumValue(e.status);
    r["direction"] = enumValue(e.direction);
    r["startedAt"] = e.startedAt;
    r["completedAt"] = e.completedAt;
    r["bytesSent"] = e.bytesSent;
    r["bytesReceived"] = e.bytesReceived;
    r["recordsSent"] = e.recordsSent;
    r["recordsReceived"] = e.recordsReceived;
    r["errorMessage"] = e.errorMessage;
    r["clientAppVersion"] = e.clientAppVersion;
    r["triggeredBy"] = e.triggeredBy.value;
    return r;
  }

  static SyncSession fromRecord(Json r) {
    SyncSession e;
    readBase(e, r);
    e.deviceId = DeviceId(fieldString(r, "deviceId"));
    e.applicationId = MobileApplicationId(fieldString(r, "applicationId"));
    e.connectionId = BackendConnectionId(fieldString(r, "connectionId"));
    e.status = fieldEnum!SyncStatus(r, "status", SyncStatus.pending);
    e.direction = fieldEnum!SyncDirection(r, "direction", SyncDirection.bidirectional);
    e.startedAt = fieldLong(r, "startedAt");
    e.completedAt = fieldLong(r, "completedAt");
    e.bytesSent = fieldLong(r, "bytesSent");
    e.bytesReceived = fieldLong(r, "bytesReceived");
    e.recordsSent = fieldLong(r, "recordsSent");
    e.recordsReceived = fieldLong(r, "recordsReceived");
    e.errorMessage = fieldString(r, "errorMessage");
    e.clientAppVersion = fieldString(r, "clientAppVersion");
    e.triggeredBy = UserId(fieldString(r, "triggeredBy"));
    return e;
  }
}
