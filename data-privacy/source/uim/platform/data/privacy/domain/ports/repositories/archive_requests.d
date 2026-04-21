/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.domain.ports.repositories.archive_requests;

import uim.platform.data.privacy.domain.types;
import uim.platform.data.privacy.domain.entities.archive_request;

/// Port for persisting and querying archive requests.
interface ArchiveRequestRepository : ITenantRepository!(ArchiveRequest, ArchiveRequestId) {

  size_t countByDataSubject(TenantId tenantId, DataSubjectId dataSubjectId);
  ArchiveRequest[] findByDataSubject(TenantId tenantId, DataSubjectId dataSubjectId);
  void removeByDataSubject(TenantId tenantId, DataSubjectId dataSubjectId);

  size_t countByStatus(TenantId tenantId, ArchiveStatus status);
  ArchiveRequest[] findByStatus(TenantId tenantId, ArchiveStatus status);
  void removeByStatus(TenantId tenantId, ArchiveStatus status);
  
}
