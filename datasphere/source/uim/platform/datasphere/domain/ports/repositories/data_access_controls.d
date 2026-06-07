/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere.domain.ports.repositories.data_access_controls;

// import uim.platform.datasphere.domain.entities.data_access_control;
import uim.platform.datasphere;

// mixin(ShowModule!()); 

@safe:
interface DataAccessControlRepository : ITenantRepository!(DataAccessControl, DataAccessControlId) {

  bool existsById(TenantId tenantId, SpaceId spaceId, DataAccessControlId id);
  DataAccessControl findById(TenantId tenantId, SpaceId spaceId, DataAccessControlId id);
  void removeById(TenantId tenantId, SpaceId spaceId, DataAccessControlId id);

  size_t countBySpace(TenantId tenantId, SpaceId spaceId);
  DataAccessControl[] findBySpace(TenantId tenantId, SpaceId spaceId);
  void removeBySpace(TenantId tenantId, SpaceId spaceId);

  size_t countByView(TenantId tenantId, SpaceId spaceId, ViewId viewId);
  DataAccessControl[] findByView(TenantId tenantId, SpaceId spaceId, ViewId viewId);
  void removeByView(TenantId tenantId, SpaceId spaceId, ViewId viewId);

}
