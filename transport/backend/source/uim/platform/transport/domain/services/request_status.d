/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.transport.domain.services.request_status;

import uim.platform.transport;

mixin(ShowModule!());

@safe:

/// Derive the overall status of a transport request from its queue entries:
/// failed > running > repeating > warning > initial (still queued somewhere) > success.
RequestStatus aggregateRequestStatus(const ImportQueueEntry[] entries) {
  if (entries.length == 0)
    return RequestStatus.initial;
  if (entries.any!(e => e.status == ImportStatus.failed))
    return RequestStatus.failed;
  if (entries.any!(e => e.status == ImportStatus.running))
    return RequestStatus.running;
  if (entries.any!(e => e.status == ImportStatus.repeating))
    return RequestStatus.repeating;
  if (entries.any!(e => e.status == ImportStatus.initial))
    return entries.any!(e => e.isFinished) ? RequestStatus.running : RequestStatus.initial;
  if (entries.any!(e => e.status == ImportStatus.warning))
    return RequestStatus.warning;
  return RequestStatus.success;
}

///
unittest {
  mixin(ShowTest!("aggregateRequestStatus"));

  ImportQueueEntry a, b;
  assert(aggregateRequestStatus([a]) == RequestStatus.initial);
  a.status = ImportStatus.success;
  assert(aggregateRequestStatus([a]) == RequestStatus.success);
  assert(aggregateRequestStatus([a, b]) == RequestStatus.running); // b still queued downstream
  b.status = ImportStatus.warning;
  assert(aggregateRequestStatus([a, b]) == RequestStatus.warning);
  b.status = ImportStatus.failed;
  assert(aggregateRequestStatus([a, b]) == RequestStatus.failed);
}
