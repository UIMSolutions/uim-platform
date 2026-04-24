/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.infrastructure.persistence.memory.destruction_requests;

// import uim.platform.data.privacy.domain.types;
// import uim.platform.data.privacy.domain.entities.destruction_request;
// import uim.platform.data.privacy.domain.ports.repositories.destruction_requests;
import uim.platform.data.privacy;

mixin(ShowModule!());

@safe:
class MemoryDestructionRequestRepository : TenantRepository!(DestructionRequest, DestructionRequestId), DestructionRequestRepository {

  // #region ByDataSubject
  size_t countByDataSubject(TenantId tenantId, DataSubjectId subjectId) {
    return findByDataSubject(tenantId, subjectId).length;
  }

  DestructionRequest[] filterByDataSubject(DestructionRequest[] records, DataSubjectId subjectId) {
    return records.filter!(s => s.dataSubjectId == subjectId).array;
  }

  DestructionRequest[] findByDataSubject(TenantId tenantId, DataSubjectId subjectId) {
    return filterByDataSubject(findByTenant(tenantId), subjectId);
  }

  void removeByDataSubject(TenantId tenantId, DataSubjectId subjectId) {
    findByDataSubject(tenantId, subjectId).each!(entity => remove(entity));
  }
  // #endregion ByDataSubject

  // #region ByStatus
  size_t countByStatus(TenantId tenantId, DestructionStatus status) {
    return findByStatus(tenantId, status).length;
  }

  DestructionRequest[] filterByStatus(DestructionRequest[] records, DestructionStatus status) {
    return records.filter!(s => s.status == status).array;
  }

  DestructionRequest[] findByStatus(TenantId tenantId, DestructionStatus status) {
    return filterByStatus(findByTenant(tenantId), status);
  }
  // #endregion ByStatus

}
