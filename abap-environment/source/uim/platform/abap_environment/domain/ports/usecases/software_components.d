/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_environment.domain.ports.usecases.software_components;

import uim.platform.abap_environment;

// mixin(ShowModule!());

@safe:
/// Application service for software component lifecycle (clone, pull, manage).
interface IManageSoftwareComponentsUseCase { 

  UsecaseResult createSoftwareComponent(CreateSoftwareComponentRequest req);
  UsecaseResult cloneSoftwareComponent(CloneSoftwareComponentRequest req);
  UsecaseResult pullSoftwareComponent(PullSoftwareComponentRequest req);
  SoftwareComponent getSoftwareComponent(TenantId tenantId, SoftwareComponentId id);
  SoftwareComponent[] listSoftwareComponents(TenantId tenantId, SystemInstanceId systemId);
  UsecaseResult deleteSoftwareComponent(TenantId tenantId, SoftwareComponentId id);

}
