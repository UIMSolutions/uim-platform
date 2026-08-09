/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.domain.ports.usescases.correction_requests;

import uim.platform.data.privacy;

mixin(ShowModule!());

@safe:
interface IManageCorrectionRequestsUseCase { 

  CommandResult createRequest(CreateCorrectionRequest req);
  CorrectionRequest getRequest(TenantId tenantId, CorrectionRequestId id);
  CorrectionRequest[] listRequests(TenantId tenantId);
  CorrectionRequest[] listByDataSubject(TenantId tenantId, DataSubjectId subjectId);
  CommandResult updateStatus(UpdateCorrectionStatusRequest req);
  CommandResult deleteRequest(TenantId tenantId, CorrectionRequestId id);
  
}
