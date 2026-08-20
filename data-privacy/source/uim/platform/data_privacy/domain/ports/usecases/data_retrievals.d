/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data_privacy.domain.ports.usecases.data_retrievals;

import uim.platform.data_privacy;

mixin(ShowModule!());

@safe:
interface IManageDataRetrievalsUseCase { 

  UsecaseResult createRequest(CreateDataRetrievalRequest req);
  DataRetrievalRequest getRequest(TenantId tenantId, DataRetrievalRequestId id);
  DataRetrievalRequest[] listRequests(TenantId tenantId);
  DataRetrievalRequest[] listByStatus(TenantId tenantId, RetrievalStatus status);
  UsecaseResult updateStatus(UpdateRetrievalStatusRequest req);
  UsecaseResult deleteRequest(TenantId tenantId, DataRetrievalRequestId id);
  
}
