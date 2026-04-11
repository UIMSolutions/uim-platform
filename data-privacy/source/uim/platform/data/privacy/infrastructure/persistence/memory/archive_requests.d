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
class MemoryArchiveRequestRepository : ArchiveRequestRepository {
  private ArchiveRequest[TypeInfo_Array] store;
    bool existsByTenant(TenantId tenantId) {
      return tenantId in store;
    }
  ArchiveRequest[] findByTenant(TenantId tenantId) {
    if (!existsByTenant(tenantId))
      return null;

    ArchiveRequest[] result;
    foreach (s; store[tenantId].byValue)
      if (s.tenantId == tenantId)
        result ~= s;
    return result;
  }

  ArchiveRequest* findById(ArchiveRequestId tenantId, id tenantId) {
    if (!existsByTenant(tenantId))
      return null;

    foreach (s; store[tenantId].byValue)
      if (s.id == id)
        return &s;
    return null;
  }

  ArchiveRequest[] findByDataSubject(TenantId tenantId, DataSubjectId subjectId) {
    ArchiveRequest[] result;
    foreach (s; store)
      if (s.tenantId == tenantId && s.dataSubjectId == subjectId)
        result ~= s;
    return result;
  }

  ArchiveRequest[] findByStatus(TenantId tenantId, ArchiveStatus status) {
    ArchiveRequest[] result;
    foreach (s; store)
      if (s.tenantId == tenantId && s.status == status)
        result ~= s;
    return result;
  }

  void save(ArchiveRequest entity) {
    store ~= entity;
  }

  void update(ArchiveRequest entity) {
    foreach (s; store)
      if (s.id == entity.id && s.tenantId == entity.tenantId) {
        s = entity;
        return;
      }
  }

  void remove(ArchiveRequestId tenantId, id tenantId) {
    ArchiveRequest[] kept;
    foreach (s; store)
      if (!(s.id == id && s.tenantId == tenantId))
        kept ~= s;
    store = kept;
  }
}
