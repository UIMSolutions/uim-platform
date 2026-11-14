/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.transport.persistence.mappers.transport_request;

import uim.platform.transport;

mixin(ShowModule!());

@safe:

struct TransportRequestMapper {
  static Json toRecord(const TransportRequest e) {
    auto r = baseRecord(e);
    r["name"] = e.name;
    r["description"] = e.description;
    r["externalId"] = e.externalId;
    r["contentType"] = enumName(e.contentType);
    r["status"] = enumName(e.status);
    r["version"] = e.version_;
    r["contentSize"] = e.contentSize;
    r["storageUrl"] = e.storageUrl;
    r["checksum"] = e.checksum;
    r["sourceNodeId"] = e.sourceNodeId.value;
    r["namedUser"] = e.namedUser;
    r["systemId"] = e.systemId;
    r["queuedAt"] = e.queuedAt;
    r["importedAt"] = e.importedAt;
    r["errorMessage"] = e.errorMessage;
    return r;
  }

  static TransportRequest fromRecord(Json r) {
    TransportRequest e;
    readBase(e, r);
    e.name = fieldString(r, "name");
    e.description = fieldString(r, "description");
    e.externalId = fieldString(r, "externalId");
    e.contentType = fieldEnum!ContentType(r, "contentType", ContentType.mtaArchive);
    e.status = fieldEnum!RequestStatus(r, "status", RequestStatus.initial);
    e.version_ = fieldString(r, "version");
    e.contentSize = fieldString(r, "contentSize");
    e.storageUrl = fieldString(r, "storageUrl");
    e.checksum = fieldString(r, "checksum");
    e.sourceNodeId = TransportNodeId(fieldString(r, "sourceNodeId"));
    e.namedUser = fieldString(r, "namedUser");
    e.systemId = fieldString(r, "systemId");
    e.queuedAt = fieldLong(r, "queuedAt");
    e.importedAt = fieldLong(r, "importedAt");
    e.errorMessage = fieldString(r, "errorMessage");
    return e;
  }
}
