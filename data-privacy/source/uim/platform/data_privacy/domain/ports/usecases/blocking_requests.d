/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data_privacy.domain.ports.usecases.blocking_requests;

// import uim.platform.data_privacy.domain.entities.blocking_request;
// import uim.platform.data_privacy.domain.ports.repositories.blocking_requests;
// import uim.platform.data_privacy.domain.ports.repositories.data_subjects;
// import uim.platform.data_privacy.application.dto;

import uim.platform.data_privacy;

mixin(ShowModule!());

@safe:
interface IManageBlockingRequestsUseCase { 

  UsecaseResult createRequest(CreateBlockingRequest req);
  BlockingRequest getRequest(TenantId tenantId, BlockingRequestId id);
  BlockingRequest[] listRequests(TenantId tenantId);
  BlockingRequest[] listByStatus(TenantId tenantId, BlockingStatus status);
  UsecaseResult updateStatus(UpdateBlockingStatusRequest req);
  UsecaseResult deleteRequest(TenantId tenantId, BlockingRequestId id);
  
}
