/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.infrastructure.persistence.memory.deletion_requests;

// import uim.platform.data.privacy.domain.types;
// import uim.platform.data.privacy.domain.entities.deletion_request;
// import uim.platform.data.privacy.domain.ports.repositories.deletion_requests;
import uim.platform.data.privacy;

mixin(ShowModule!());

@safe:
class MemoryDeletionRequestRepository : TenantRepository!(DeletionRequest, DeletionRequestId), DeletionRequestRepository {

  // #region ByDataSubject
  size_t countByDataSubject(TenantId tenantId, DataSubjectId subjectId) {
    return findByDataSubject(tenantId, subjectId).length;
  }

  DeletionRequest[] filterByDataSubject(DeletionRequest[] records, DataSubjectId subjectId) {
    return records.filter!(s => s.dataSubjectId == subjectId).array;
  }

  DeletionRequest[] findByDataSubject(TenantId tenantId, DataSubjectId dataSubjectId) {
    return filterByDataSubject(findByTenant(tenantId), dataSubjectId);
  }

  void removeByDataSubject(TenantId tenantId, DataSubjectId subjectId) {
    findByDataSubject(tenantId, subjectId).each!(entity => remove(entity));
  }
  // #endregion ByDataSubject

  // #region ByStatus
  size_t countByStatus(TenantId tenantId, DeletionStatus status) {
    return findByStatus(tenantId, status).length;
  }

  DeletionRequest[] filterByStatus(DeletionRequest[] records, DeletionStatus status) {
    return records.filter!(s => s.status == status).array;
  }

  DeletionRequest[] findByStatus(TenantId tenantId, DeletionStatus status) {
    return filterByStatus(findByTenant(tenantId), status);
  }

  void removeByStatus(TenantId tenantId, DeletionStatus status) {
    findByStatus(tenantId, status).each!(entity => remove(entity.id));
  }
  // #endregion ByStatus

}
