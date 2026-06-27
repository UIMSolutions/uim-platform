/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.buildcode.domain.ports.repositories.ai_requests;

import uim.platform.buildcode;

// mixin(ShowModule!());

@safe:

interface AIRequestRepository : ITenantRepository!(AIRequest, AIRequestId) {
  AIRequest[]  findByProject(TenantId tenantId, string projectId);
  AIRequest[]  findByStatus(TenantId tenantId, AIRequestStatus status);
  AIRequest[]  findByType(TenantId tenantId, AIGenerationType type);
  AIRequest[]  findByUser(TenantId tenantId, string userId);
}
