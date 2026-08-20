/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data_privacy.domain.ports.usecases.deletion_requests;

// import uim.platform.data_privacy.domain.entities.deletion_request;
// import uim.platform.data_privacy.domain.ports.repositories.deletion_requests;
// import uim.platform.data_privacy.domain.ports.repositories.data_subjects;
// import uim.platform.data_privacy.application.dto;

import uim.platform.data_privacy;

mixin(ShowModule!());

@safe:
interface IManageDeletionRequestsUseCase { 

  UsecaseResult createRequest(CreateDeletionRequest req);
  DeletionRequest getRequest(TenantId tenantId, DeletionRequestId id);
  DeletionRequest[] listRequests(TenantId tenantId);
  DeletionRequest[] listByStatus(TenantId tenantId, DeletionStatus status);
  DeletionRequest[] listByDataSubject(TenantId tenantId, DataSubjectId subjectId);
  UsecaseResult updateStatus(UpdateDeletionStatusRequest req);
  UsecaseResult deleteRequest(TenantId tenantId, DeletionRequestId id);
  
}
