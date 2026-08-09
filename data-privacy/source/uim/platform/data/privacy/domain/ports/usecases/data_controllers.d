/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.domain.ports.usescases.data_controllers;

import uim.platform.data.privacy;

mixin(ShowModule!());

@safe:
interface IManageDataControllersUseCase { 

  CommandResult createController(CreateDataControllerRequest req);
  DataController getController(TenantId tenantId, DataControllerId id);
  DataController[] listControllers(TenantId tenantId);
  CommandResult updateController(UpdateDataControllerRequest req);
  CommandResult deleteController(TenantId tenantId, DataControllerId id);
  
}
