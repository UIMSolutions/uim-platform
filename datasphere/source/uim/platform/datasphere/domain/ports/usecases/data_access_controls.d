/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere.domain.ports.usecases.data_access_controls;

import uim.platform.datasphere;

mixin(ShowModule!()); 

@safe:
interface IManageDataAccessControlsUseCase { 

  CommandResult createDataAccessControl(CreateDataAccessControlRequest r);
  DataAccessControl getDataAccessControl(TenantId tenantId, SpaceId spaceId, DataAccessControlId id);
  DataAccessControl[] listDataAccessControls(TenantId tenantId, SpaceId spaceId);
  CommandResult updateDataAccessControl(UpdateDataAccessControlRequest r);
  CommandResult deleteDataAccessControl(TenantId tenantId, SpaceId spaceId, DataAccessControlId id);

}
