/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.domain.ports.repositories.archive_requests;

import uim.platform.data.privacy.domain.types;
import uim.platform.data.privacy.domain.entities.archive_request;

/// Port for persisting and querying archive requests.
interface ArchiveRequestRepository {
  bool existsByTenant(TenantId tenantId);
  ArchiveRequest[] findByTenant(TenantId tenantId);

  bool existsId(ArchiveRequestId id, TenantId tenantId);
  ArchiveRequest findById(ArchiveRequestId id, TenantId tenantId);

  ArchiveRequest[] findByDataSubject(TenantId tenantId, DataSubjectId dataSubjectId);
  ArchiveRequest[] findByStatus(TenantId tenantId, ArchiveStatus status);
  
  void save(ArchiveRequest request);
  void update(ArchiveRequest request);
  void remove(ArchiveRequestId id, TenantId tenantId);
}
