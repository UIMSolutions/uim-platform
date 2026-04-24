/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.infrastructure.persistence.memory.consent_purposes;

// import uim.platform.data.privacy.domain.types;
// import uim.platform.data.privacy.domain.entities.consent_purpose;
// import uim.platform.data.privacy.domain.ports.consent_purpose_repository;
import uim.platform.data.privacy;

mixin(ShowModule!());

@safe:
class MemoryConsentPurposeRepository : TenantRepository!(ConsentPurpose, ConsentPurposeId), ConsentPurposeRepository {

  // #region ByController
  size_t countByController(TenantId tenantId, DataControllerId controllerId) {
    return findByController(tenantId, controllerId).length;
  }

  ConsentPurpose[] filterByController(ConsentPurpose[] purposes, DataControllerId controllerId) {
    return purposes.filter!(s => s.controllerId == controllerId).array;
  }

  ConsentPurpose[] findByController(TenantId tenantId, DataControllerId controllerId) {
    return filterByController(findByTenant(tenantId), controllerId);
  }

  void removeByController(TenantId tenantId, DataControllerId controllerId) {
    findByController(tenantId, controllerId).each!(entity => remove(entity.id));
  }
  // #endregion ByController

  // #region ByStatus
  size_t countByStatus(TenantId tenantId, ConsentPurposeStatus status) {
    return findByStatus(tenantId, status).length;
  }

  ConsentPurpose[] filterByStatus(ConsentPurpose[] purposes, ConsentPurposeStatus status) {
    return purposes.filter!(s => s.status == status).array;
  }

  ConsentPurpose[] findByStatus(TenantId tenantId, ConsentPurposeStatus status) {
    return filterByStatus(findByTenant(tenantId), status);
  }

  void removeByStatus(TenantId tenantId, ConsentPurposeStatus status) {
    findByStatus(tenantId, status).each!(entity => remove(entity));
  }
  // #region ByStatus

}
