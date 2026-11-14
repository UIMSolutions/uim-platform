/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_environment.domain.entities.transport_request;

import uim.platform.abap_environment;

mixin(ShowModule!());

@safe:

/// A transport request moving changes from a source to a target system (CTS).
struct TransportRequest {
  mixin TenantEntity!TransportRequestId;

  SystemInstanceId sourceSystemId;
  string sourceSystemName;
  SystemInstanceId targetSystemId;
  string targetSystemName;
  string name; /// transport number "<SID>K9nnnnn", generated
  string description;
  string owner;
  TransportType transportType = TransportType.workbench;
  TransportStatus status = TransportStatus.modifiable;
  string statusMessage;

  TransportTask[] tasks;
  long releasedAt;
  long importedAt;
}
