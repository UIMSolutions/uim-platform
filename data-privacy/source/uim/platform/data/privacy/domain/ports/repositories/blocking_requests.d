/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.domain.ports.repositories.blocking_requests;

import uim.platform.data.privacy.domain.types;
import uim.platform.data.privacy.domain.entities.blocking_request;

/// Port for persisting data blocking / restriction requests.
interface BlockingRequestRepository {
  bool existsByTenant(TenantId tenantId);
  BlockingRequest[] findByTenant(TenantId tenantId);
 
  bool existsById(BlockingRequestId id, TenantId tenantId);
  BlockingRequest findById(BlockingRequestId id, TenantId tenantId);

  BlockingRequest[] findByDataSubject(TenantId tenantId, DataSubjectId dataSubjectId);
  BlockingRequest[] findByStatus(TenantId tenantId, BlockingStatus status);

  void save(BlockingRequest request);
  void update(BlockingRequest request);
  void remove(BlockingRequestId id, TenantId tenantId);
}
