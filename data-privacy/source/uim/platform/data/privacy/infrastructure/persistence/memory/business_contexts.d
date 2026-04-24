/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.infrastructure.persistence.memory.business_contexts;

// import uim.platform.data.privacy.domain.types;
// import uim.platform.data.privacy.domain.entities.business_context;
// import uim.platform.data.privacy.domain.ports.business_context_repository;
import uim.platform.data.privacy;

mixin(ShowModule!());

@safe:
class MemoryBusinessContextRepository : TenantRepository!(BusinessContext, BusinessContextId), BusinessContextRepository {

  // #region ByStatus
  size_t countByStatus(TenantId tenantId, BusinessContextStatus status) {
    return findByStatus(tenantId, status).length;
  }

  BusinessContext[] filterByStatus(BusinessContext[] contexts, BusinessContextStatus status) { 
    return contexts.filter!(c => c.status == status).array;
  }

  BusinessContext[] findByStatus(TenantId tenantId, BusinessContextStatus status) {
    return filterByStatus(findByTenant(tenantId), status);
  }

  void removeByStatus(TenantId tenantId, BusinessContextStatus status) {
    findByStatus(tenantId, status).each!(entity => remove(entity.id));
  }
  // #endregion ByStatus

  // #region ByControllerGroup
  size_t countByControllerGroup(TenantId tenantId, DataControllerGroupId groupId) {
    return findByControllerGroup(tenantId, groupId).length;
  }

  BusinessContext[] filterByControllerGroup(BusinessContext[] contexts, DataControllerGroupId groupId) {
    return contexts.filter!(c => c.controllerGroupId == groupId).array;
  }

  BusinessContext[] findByControllerGroup(TenantId tenantId, DataControllerGroupId groupId) {
    return filterByControllerGroup(findByTenant(tenantId), groupId);
  }

  void removeByControllerGroup(TenantId tenantId, DataControllerGroupId groupId) {
    findByControllerGroup(tenantId, groupId).each!(entity => remove(entity.id));
  }
  // #endregion ByControllerGroup

}
