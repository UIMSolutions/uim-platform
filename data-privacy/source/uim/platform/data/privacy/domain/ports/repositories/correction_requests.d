/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.domain.ports.repositories.correction_requests;

import uim.platform.data.privacy.domain.types;
import uim.platform.data.privacy.domain.entities.correction_request;

/// Port for persisting and querying correction requests.
interface CorrectionRequestRepository {
  bool existsByTenant(TenantId tenantId);
  CorrectionRequest[] findByTenant(TenantId tenantId);
 
  bool existsById(CorrectionRequestId id, TenantId tenantId);
  CorrectionRequest findById(CorrectionRequestId id, TenantId tenantId);
  
  CorrectionRequest[] findByDataSubject(TenantId tenantId, DataSubjectId dataSubjectId);
  CorrectionRequest[] findByStatus(TenantId tenantId, CorrectionStatus status);
  
  void save(CorrectionRequest request);
  void update(CorrectionRequest request);
  void remove(CorrectionRequestId id, TenantId tenantId);
}
