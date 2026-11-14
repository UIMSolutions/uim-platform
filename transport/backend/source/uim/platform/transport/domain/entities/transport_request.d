/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.transport.domain.entities.transport_request;

import uim.platform.transport;

mixin(ShowModule!());

@safe:

/// A unit of transport: an MTA archive, integration content package, HTML5 app, ...
/// Created by source systems (CI/CD pipelines, SAP Cloud Integration), exported
/// from its source node and imported/forwarded along the routes.
struct TransportRequest {
  mixin TenantEntity!TransportRequestId;

  string name;
  string description;
  string externalId;
  ContentType contentType = ContentType.mtaArchive;
  /// Aggregated status of all import queue entries of this request.
  RequestStatus status = RequestStatus.initial;
  string version_;
  string contentSize;
  /// Location of the content archive. Empty = metadata-only request.
  string storageUrl;
  string checksum;
  TransportNodeId sourceNodeId;
  string namedUser;
  string systemId;
  long queuedAt;
  long importedAt;
  string errorMessage;

  bool hasContent() const {
    return storageUrl.length > 0;
  }

  Json toJson() const {
    return entityToJson
      .set("name", name)
      .set("description", description)
      .set("externalId", externalId)
      .set("contentType", enumName(contentType))
      .set("status", enumName(status))
      .set("version", version_)
      .set("contentSize", contentSize)
      .set("storageUrl", storageUrl)
      .set("checksum", checksum)
      .set("sourceNodeId", sourceNodeId.value)
      .set("namedUser", namedUser)
      .set("systemId", systemId)
      .set("queuedAt", queuedAt)
      .set("importedAt", importedAt)
      .set("errorMessage", errorMessage);
  }
}
