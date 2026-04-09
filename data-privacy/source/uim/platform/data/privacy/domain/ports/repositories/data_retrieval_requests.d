/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.domain.ports.repositories.data_retrieval_requests;

import uim.platform.data.privacy.domain.types;
import uim.platform.data.privacy.domain.entities.data_retrieval_request;

/// Port for persisting data subject access / retrieval requests.
interface DataRetrievalRequestRepository {
  bool existsByTenant(TenantId tenantId);
  DataRetrievalRequest[] findByTenant(TenantId tenantId);
 
  bool existsById(DataRetrievalRequestId tenantId, id tenantId);
  DataRetrievalRequest findById(DataRetrievalRequestId tenantId, id tenantId);

  DataRetrievalRequest[] findByDataSubject(TenantId tenantId, DataSubjectId dataSubjectId);
  DataRetrievalRequest[] findByStatus(TenantId tenantId, RetrievalStatus status);

  void save(DataRetrievalRequest request);
  void update(DataRetrievalRequest request);
  void remove(DataRetrievalRequestId tenantId, id tenantId);
}
