/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.domain.ports.usecases.functions;

import uim.platform.kyma;

mixin(ShowModule!());

@safe:
/// Application service for serverless function lifecycle management.
interface IManageFunctionsUseCase {

  UsecaseResult createFunction(CreateFunctionRequest request);

  UsecaseResult updateFunction(UpdateFunctionRequest req);
  
  bool hasFunction(TenantId tenantId, ServerlessFunctionId functionId);
  
  ServerlessFunction getFunction(TenantId tenantId, ServerlessFunctionId functionId);

  ServerlessFunction[] listByNamespace(TenantId tenantId, NamespaceId nsId);

  ServerlessFunction[] listByEnvironment(TenantId tenantId, KymaEnvironmentId environmentId);

  UsecaseResult deleteFunction(TenantId tenantId, ServerlessFunctionId functionId);
  
}


