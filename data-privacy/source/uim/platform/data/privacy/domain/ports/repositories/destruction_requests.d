/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.domain.ports.repositories.destruction_requests;

import uim.platform.data.privacy.domain.types;
import uim.platform.data.privacy.domain.entities.destruction_request;

/// Port for persisting and querying destruction requests.
interface DestructionRequestRepository {
  bool existsTenant(TenantId tenantId);
  DestructionRequest[] findByTenant(TenantId tenantId);
 
  bool existsId(DestructionRequestId id, TenantId tenantId);
  DestructionRequest findById(DestructionRequestId id, TenantId tenantId);

  DestructionRequest[] findByDataSubject(TenantId tenantId, DataSubjectId dataSubjectId);
  DestructionRequest[] findByStatus(TenantId tenantId, DestructionStatus status);

  void save(DestructionRequest request);
  void update(DestructionRequest request);
  void remove(DestructionRequestId id, TenantId tenantId);
}
