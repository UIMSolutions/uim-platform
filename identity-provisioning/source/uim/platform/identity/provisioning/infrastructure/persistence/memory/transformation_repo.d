/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.provisioning.infrastructure.persistence.memory.transformation;

import uim.platform.identity.provisioning.domain.types;
import uim.platform.identity.provisioning.domain.entities.transformation;
import uim.platform.identity.provisioning.domain.ports.repositories.transformations;

class MemoryTransformationRepository : TenantRepository!(Transformation, TransformationId), TransformationRepository {

  // #region BySystem
  size_t countBySystem(TenantId tenantId, string systemId) {
    return findBySystem(tenantId, systemId).length;
  }

  Transformation[] filterBySystem(Transformation[] items, string systemId) {
    return items.filter!(e => e.systemId == systemId).array;
  }

  Transformation[] findBySystem(TenantId tenantId, string systemId) {
    return filterBySystem(findByTenant(tenantId), systemId);
  }

  void removeBySystem(TenantId tenantId, string systemId) {
    findBySystem(tenantId, systemId).each!(e => remove(e.id));
  }
  // #endregion BySystem

  // #region BySystemRole
  size_t countBySystemRole(TenantId tenantId, SystemRole role) {
    return findBySystemRole(tenantId, role).length;
  }

  Transformation[] filterBySystemRole(Transformation[] items, SystemRole role) {
    return items.filter!(e => e.systemRole == role).array;
  }

  Transformation[] findBySystemRole(TenantId tenantId, SystemRole role) {
    return filterBySystemRole(findByTenant(tenantId), role);
  }

  void removeBySystemRole(TenantId tenantId, SystemRole role) {
    findBySystemRole(tenantId, role).each!(e => remove(e.id));
  }
  // #endregion BySystemRole

}
