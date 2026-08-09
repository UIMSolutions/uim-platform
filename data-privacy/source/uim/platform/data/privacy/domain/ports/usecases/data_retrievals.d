/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.domain.ports.usescases.data_retrievals;

import uim.platform.data.privacy;

mixin(ShowModule!());

@safe:
interface IManageDataRetrievalsUseCase { 

  CommandResult createRequest(CreateDataRetrievalRequest req);
  DataRetrievalRequest getRequest(TenantId tenantId, DataRetrievalRequestId id);
  DataRetrievalRequest[] listRequests(TenantId tenantId);
  DataRetrievalRequest[] listByStatus(TenantId tenantId, RetrievalStatus status);
  CommandResult updateStatus(UpdateRetrievalStatusRequest req);
  CommandResult deleteRequest(TenantId tenantId, DataRetrievalRequestId id);
  
}
