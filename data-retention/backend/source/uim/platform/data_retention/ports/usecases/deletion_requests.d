/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Driving port of the deletion requests.
module uim.platform.data_retention.ports.usecases.deletion_requests;

import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

interface IManageDeletionRequests {
  /// One pending request per data subject.
  DeletionRequest create(CreateDeletionRequestCommand c);
  /// Block, or delete/anonymize if no retention obligation (and no legal
  /// hold) stands against it — otherwise reject and block instead.
  DeletionRequest process(TenantId t, DeletionRequestId id, UserId actor);
  DeletionRequest cancel(TenantId t, DeletionRequestId id, UserId actor);
  DeletionRequest get(TenantId t, DeletionRequestId id);
  DeletionRequest[] list(TenantId t);
  /// Closed requests only (pending ones must be cancelled first).
  void remove(TenantId t, DeletionRequestId id, UserId actor);
  /// Process every pending request (background worker).
  RunSummary processPending(TenantId t, UserId actor);
}
