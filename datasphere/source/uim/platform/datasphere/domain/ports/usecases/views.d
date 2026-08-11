/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere.domain.ports.usecases.views;

// import uim.platform.datasphere.domain.entities.view_;
// import uim.platform.datasphere.domain.ports.repositories.views;
// import uim.platform.datasphere.application.dto;

import uim.platform.datasphere;

mixin(ShowModule!()); 

@safe:
interface IManageViewsUseCase { 
  
  CommandResult createView(CreateViewRequest r);
  View getById(TenantId tenantId, SpaceId spaceId, ViewId id);
  View[] list(TenantId tenantId, SpaceId spaceId);
  View[] listExposed(TenantId tenantId, SpaceId spaceId);
  CommandResult updateView(UpdateViewRequest r);
  CommandResult deleteView(TenantId tenantId, SpaceId spaceId, ViewId id);

}
