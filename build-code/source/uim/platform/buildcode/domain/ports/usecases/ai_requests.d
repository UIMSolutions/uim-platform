/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.buildcode.domain.ports.usecases.ai_requests;

import uim.platform.buildcode;

mixin(ShowModule!());

@safe:

interface IManageAIRequestsUseCase {

  UsecaseResult generate(TenantId tenantId, AIGenerateRequest req);
  AIRequest getById(TenantId tenantId, string id);
  AIRequest[] list(TenantId tenantId);
  AIRequest[] listByProject(TenantId tenantId, string projectId);
  AIRequest[] listByStatus(TenantId tenantId, string statusStr);
  UsecaseResult updateStatus(TenantId tenantId, string id, string statusStr, string generatedCode = "", string errorMsg = "");
  
}
