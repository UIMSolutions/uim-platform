/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.transport.application.services.request_status_sync;

import uim.platform.transport;

mixin(ShowModule!());

@safe:

/// Recompute the aggregated status of a request from its queue entries and
/// store it if it changed. Requests without queue entries keep their status.
RequestStatus syncRequestStatus(ITransportRequestRepository requests, IImportQueueEntryRepository queue,
    TenantId tenantId, TransportRequestId requestId) {
  auto request = requests.findById(tenantId, requestId);
  if (request.isNull)
    return RequestStatus.initial;
  auto entries = queue.findByRequest(tenantId, requestId);
  if (entries.length == 0)
    return request.status;
  auto status = aggregateRequestStatus(entries);
  if (status != request.status) {
    request.status = status;
    request.updatedAt = Clock.currStdTime();
    requests.update(request);
  }
  return status;
}
