/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.infrastructure.persistence.memory.archive_requests;

// import uim.platform.data.privacy.domain.types;
// import uim.platform.data.privacy.domain.entities.archive_request;
// import uim.platform.data.privacy.domain.ports.archive_request_repository;
import uim.platform.data.privacy;

mixin(ShowModule!());

@safe:
class MemoryArchiveRequestRepository : TenantRepository!(ArchiveRequest, ArchiveRequestId), ArchiveRequestRepository {

  size_t countByDataSubject(TenantId tenantId, DataSubjectId subjectId) {
    return findByDataSubject(tenantId, subjectId).length;
  }
  ArchiveRequest[] findByDataSubject(TenantId tenantId, DataSubjectId subjectId) {
    ArchiveRequest[] result;
    foreach (s; findByTenant(tenantId))
      if (s.dataSubjectId == subjectId)
        result ~= s;
    return result;
  }
  void removeByDataSubject(TenantId tenantId, DataSubjectId subjectId) {
    findByDataSubject(tenantId, subjectId).each!(entity => remove(entity.id));
  }

  size_t countByStatus(TenantId tenantId, ArchiveStatus status) {
    return findByStatus(tenantId, status).length;
  }
  ArchiveRequest[] findByStatus(TenantId tenantId, ArchiveStatus status) {
    ArchiveRequest[] result;
    foreach (s; findByTenant(tenantId))
      if (s.status == status)
        result ~= s;
    return result;
  }
  void removeByStatus(TenantId tenantId, ArchiveStatus status) {
    findByStatus(tenantId, status).each!(entity => remove(entity.id));
  }

}
