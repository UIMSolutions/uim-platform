/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.domain.entities.destruction_request;

import uim.platform.data.privacy.domain.types;

/// A request to destroy blocked or archived personal data.
struct DestructionRequest {
  DestructionRequestId id;
  TenantId tenantId;
  DataSubjectId dataSubjectId;
  UserId requestedBy;
  DestructionStatus status = DestructionStatus.scheduled;
  string[] targetSystems;
  ArchiveRequestId archiveRequestId; // linked archive, if destroying archived data
  BlockingRequestId blockingRequestId; // linked blocking, if destroying blocked data
  string reason;
  long scheduledAt; // 0 = immediate
  long startedAt;
  long completedAt;
}
