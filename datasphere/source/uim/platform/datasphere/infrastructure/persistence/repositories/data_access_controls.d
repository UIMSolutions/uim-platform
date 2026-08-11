/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere.infrastructure.persistence.repositories.data_access_controls;

// import uim.platform.datasphere.domain.entities.data_access_control;
// import uim.platform.datasphere.domain.ports.repositories.data_access_controls;

import uim.platform.datasphere;

mixin(ShowModule!());

@safe:
class DataAccessControlRepository : TenantRepository!(DataAccessControl, DataAccessControlId), IDataAccessControlRepository {

  // #region ById
  bool existsById(TenantId tenantId, SpaceId spaceId, DataAccessControlId id) {
    return findBySpace(tenantId, spaceId).any!(ca => ca.id == id);
  }

  DataAccessControl findById(TenantId tenantId, SpaceId spaceId, DataAccessControlId id) {
    foreach (dac; findBySpace(tenantId, spaceId)) {
      if (dac.id == id)
        return dac;
    }
    return DataAccessControl.init;
  }

  void removeById(TenantId tenantId, SpaceId spaceId, DataAccessControlId id) {
    remove(findById(tenantId, spaceId, id));
  }
  // #endregion ById

  // #region BySpace
  size_t countBySpace(TenantId tenantId, SpaceId spaceId) {
    return findBySpace(tenantId, spaceId).length;
  }

  DataAccessControl[] filterBySpace(DataAccessControl[] dacs, SpaceId spaceId) {
    return dacs.filter!(dac => dac.spaceId == spaceId).array;
  }

  DataAccessControl[] findBySpace(TenantId tenantId, SpaceId spaceId) {
    return filterBySpace(findByTenant(tenantId), spaceId);
  }

  void removeBySpace(TenantId tenantId, SpaceId spaceId) {
    findBySpace(tenantId, spaceId).each!(dac => remove(dac));
  }
  // #endregion BySpace

  size_t countByView(TenantId tenantId, SpaceId spaceId, ViewId viewId) {
    return findByView(tenantId, spaceId, viewId).length;
  }

  DataAccessControl[] filterByView(DataAccessControl[] dacs, ViewId viewId) {
    return dacs.filter!(dac => dac.targetViewIds.any!(id => id == viewId)).array;
  }

  DataAccessControl[] findByView(TenantId tenantId, SpaceId spaceId, ViewId viewId) {
    return filterByView(findBySpace(tenantId, spaceId), viewId);
  }

  void removeByView(TenantId tenantId, SpaceId spaceId, ViewId viewId) {
    findByView(tenantId, spaceId, viewId).each!(dac => remove(dac));
  }

}
