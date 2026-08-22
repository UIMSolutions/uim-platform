/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.domain.ports.usecases.modules;
// import uim.platform.kyma.application.dto;
// import uim.platform.kyma.domain.entities.kyma_module;
// import uim.platform.kyma.domain.ports.repositories.modules;
// import uim.platform.kyma.domain.services.module_dependency_resolver;

import uim.platform.kyma;

mixin(ShowModule!());

@safe:
/// Application service for Kyma module management.
interface IManageModulesUseCase {

  UsecaseResult enableModule(EnableModuleRequest request);

  UsecaseResult disableModule(TenantId tenantId, KymaModuleId moduleId);

  UsecaseResult updateModule(UpdateModuleRequest request);

  bool hasModule(TenantId tenantId, KymaModuleId moduleId);

  KymaModule getModule(TenantId tenantId, KymaModuleId moduleId);

  KymaModule[] listByEnvironment(TenantId tenantId, KymaEnvironmentId environmentId);

  UsecaseResult deleteModule(TenantId tenantId, KymaModuleId moduleId);

}
