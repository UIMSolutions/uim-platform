/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.agentry.persistence.mappers.backend_connection;

import uim.platform.agentry;

mixin(ShowModule!());

@safe:

/// BackendConnection ⇄ snapshot record.
struct BackendConnectionMapper {
  static Json toRecord(const BackendConnection e) {
    auto r = baseRecord(e);
    r["name"] = e.name;
    r["description"] = e.description;
    r["backendType"] = enumValue(e.backendType);
    r["status"] = enumValue(e.status);
    r["backendUrl"] = e.backendUrl;
    r["clientId"] = e.clientId;
    r["authMethod"] = e.authMethod;
    r["sysId"] = e.sysId;
    r["sysNumber"] = e.sysNumber;
    r["client"] = e.client;
    r["language"] = e.language;
    r["destinationName"] = e.destinationName;
    r["lastTestedAt"] = e.lastTestedAt;
    r["lastTestedBy"] = e.lastTestedBy;
    r["sslEnabled"] = e.sslEnabled;
    r["certificateFingerprint"] = e.certificateFingerprint;
    return r;
  }

  static BackendConnection fromRecord(Json r) {
    BackendConnection e;
    readBase(e, r);
    e.name = fieldString(r, "name");
    e.description = fieldString(r, "description");
    e.backendType = fieldEnum!BackendType(r, "backendType", BackendType.s4hana);
    e.status = fieldEnum!ConnectionStatus(r, "status", ConnectionStatus.inactive);
    e.backendUrl = fieldString(r, "backendUrl");
    e.clientId = fieldString(r, "clientId");
    e.authMethod = fieldString(r, "authMethod");
    e.sysId = fieldString(r, "sysId");
    e.sysNumber = fieldString(r, "sysNumber");
    e.client = fieldString(r, "client");
    e.language = fieldString(r, "language");
    e.destinationName = fieldString(r, "destinationName");
    e.lastTestedAt = fieldLong(r, "lastTestedAt");
    e.lastTestedBy = fieldString(r, "lastTestedBy");
    e.sslEnabled = fieldBool(r, "sslEnabled");
    e.certificateFingerprint = fieldString(r, "certificateFingerprint");
    return e;
  }
}
