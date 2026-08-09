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

  CommandResult createSoftwareComponent(CreateSoftwareComponentRequest req);
  CommandResult cloneSoftwareComponent(CloneSoftwareComponentRequest req);
  CommandResult pullSoftwareComponent(PullSoftwareComponentRequest req);
  SoftwareComponent getSoftwareComponent(TenantId tenantId, SoftwareComponentId id);
  SoftwareComponent[] listSoftwareComponents(TenantId tenantId, SystemInstanceId systemId);
  CommandResult deleteSoftwareComponent(TenantId tenantId, SoftwareComponentId id);

}
