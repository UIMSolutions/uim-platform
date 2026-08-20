/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data_privacy.domain.ports.usecases.correction_requests;

import uim.platform.data_privacy;

mixin(ShowModule!());

@safe:
interface IManageCorrectionRequestsUseCase { 

  UsecaseResult createRequest(CreateCorrectionRequest req);
  CorrectionRequest getRequest(TenantId tenantId, CorrectionRequestId id);
  CorrectionRequest[] listRequests(TenantId tenantId);
  CorrectionRequest[] listByDataSubject(TenantId tenantId, DataSubjectId subjectId);
  UsecaseResult updateStatus(UpdateCorrectionStatusRequest req);
  UsecaseResult deleteRequest(TenantId tenantId, CorrectionRequestId id);
  
}
