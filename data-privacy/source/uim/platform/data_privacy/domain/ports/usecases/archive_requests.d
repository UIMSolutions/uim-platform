/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data_privacy.domain.ports.usecases.archive_requests;

import uim.platform.data_privacy;

mixin(ShowModule!());

@safe:
interface IManageArchiveRequestsUseCase { 

  UsecaseResult createRequest(CreateArchiveRequest req);
  ArchiveRequest getRequest(TenantId tenantId, ArchiveRequestId requestId);
  ArchiveRequest[] listRequests(TenantId tenantId);
  ArchiveRequest[] listByDataSubject(TenantId tenantId, DataSubjectId subjectId);
  UsecaseResult updateStatus(UpdateArchiveStatusRequest req);
  UsecaseResult deleteRequest(TenantId tenantId, ArchiveRequestId requestId);

}
