/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere.domain.ports.usecases.spaces;

import uim.platform.datasphere;

mixin(ShowModule!()); 

@safe:
interface IManageSpacesUseCase { 
  
  UsecaseResult createSpace(CreateSpaceRequest r);
  Space getSpace(TenantId tenantId, SpaceId id);
  Space[] listSpaces(TenantId tenantId);
  UsecaseResult updateSpace(UpdateSpaceRequest r);
  UsecaseResult deleteSpace(TenantId tenantId, SpaceId id);
  size_t countSpaces(TenantId tenantId);
  
}
