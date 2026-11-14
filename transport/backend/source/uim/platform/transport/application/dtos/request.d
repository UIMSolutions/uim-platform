/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.transport.application.dtos.request;

import uim.platform.transport;

mixin(ShowModule!());

@safe:

struct CreateRequestInput {
  TenantId tenantId;
  string id;
  string name;
  string description;
  string externalId;
  string contentType; /// ContentType name, default mtaArchive
  string version_;
  string contentSize;
  string storageUrl;
  string checksum;
  string sourceNodeId;
  string namedUser;
  string systemId;
  UserId createdBy;
}

struct UpdateRequestInput {
  TenantId tenantId;
  TransportRequestId requestId;
  string name;
  string description;
  string externalId;
  string contentType;
  string version_;
  string contentSize;
  string storageUrl;
  string checksum;
  string namedUser;
  string systemId;
  UserId updatedBy;

  static UpdateRequestInput from(const TransportRequest r) {
    UpdateRequestInput u;
    u.tenantId = r.tenantId;
    u.requestId = r.id;
    u.name = r.name;
    u.description = r.description;
    u.externalId = r.externalId;
    u.contentType = enumName(r.contentType);
    u.version_ = r.version_;
    u.contentSize = r.contentSize;
    u.storageUrl = r.storageUrl;
    u.checksum = r.checksum;
    u.namedUser = r.namedUser;
    u.systemId = r.systemId;
    return u;
  }
}
