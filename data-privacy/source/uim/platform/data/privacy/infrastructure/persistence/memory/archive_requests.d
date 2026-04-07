/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.infrastructure.persistence.memory.archive_request_repo;

import uim.platform.data.privacy.domain.types;
import uim.platform.data.privacy.domain.entities.archive_request;
import uim.platform.data.privacy.domain.ports.archive_request_repository;

class MemoryArchiveRequestRepository : ArchiveRequestRepository {
  private ArchiveRequest[] store;

  ArchiveRequest[] findByTenant(TenantId tenantId) {
    ArchiveRequest[] result;
    foreach (ref s; store)
      if (s.tenantId == tenantId)
        result ~= s;
    return result;
  }

  ArchiveRequest* findById(ArchiveRequestId id, TenantId tenantId) {
    foreach (ref s; store)
      if (s.id == id && s.tenantId == tenantId)
        return &s;
    return null;
  }

  ArchiveRequest[] findByDataSubject(TenantId tenantId, DataSubjectId subjectId) {
    ArchiveRequest[] result;
    foreach (ref s; store)
      if (s.tenantId == tenantId && s.dataSubjectId == subjectId)
        result ~= s;
    return result;
  }

  ArchiveRequest[] findByStatus(TenantId tenantId, ArchiveStatus status) {
    ArchiveRequest[] result;
    foreach (ref s; store)
      if (s.tenantId == tenantId && s.status == status)
        result ~= s;
    return result;
  }

  void save(ArchiveRequest entity) {
    store ~= entity;
  }

  void update(ArchiveRequest entity) {
    foreach (ref s; store)
      if (s.id == entity.id && s.tenantId == entity.tenantId) {
        s = entity;
        return;
      }
  }

  void remove(ArchiveRequestId id, TenantId tenantId) {
    ArchiveRequest[] kept;
    foreach (ref s; store)
      if (!(s.id == id && s.tenantId == tenantId))
        kept ~= s;
    store = kept;
  }
}
