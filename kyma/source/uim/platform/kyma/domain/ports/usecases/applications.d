/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.domain.ports.usecases.applications;

import uim.platform.kyma;

mixin(ShowModule!());

@safe:
/// Application service for external application connectivity.
interface IManageApplicationsUseCase {
  
  UsecaseResult register(RegisterApplicationRequest req);

  UsecaseResult updateApplication(string appId, UpdateApplicationRequest req);

  UsecaseResult updateApplication(TenantId tenantId, ApplicationId appId, UpdateApplicationRequest req);

  UsecaseResult connectApplication(TenantId tenantId, ApplicationId appId);

  UsecaseResult disconnectApplication(TenantId tenantId, ApplicationId appId);

  bool hasApplication(TenantId tenantId, ApplicationId appId);

  Application getApplication(TenantId tenantId, ApplicationId appId);

  Application[] listByEnvironment(TenantId tenantId, KymaEnvironmentId envId);

  Application[] listByTenant(TenantId tenantId);

  UsecaseResult deleteApplication(TenantId tenantId, string appId);

  UsecaseResult deleteApplication(TenantId tenantId, ApplicationId appId);

}


