/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_environment.domain.ports.usecases.system_instances;

import uim.platform.abap_environment;

// mixin(ShowModule!());

@safe:
/// Application service for ABAP system instance lifecycle management.
interface ManageSystemInstancesUseCase { 

  CommandResult createInstance(CreateSystemInstanceRequest req);
  CommandResult updateInstance(UpdateSystemInstanceRequest req);;
  SystemInstance getInstance(TenantId tenantId, SystemInstanceId id);
  SystemInstance[] listInstances(TenantId tenantId);
  CommandResult deleteInstance(TenantId tenantId, SystemInstanceId id);
  
}
