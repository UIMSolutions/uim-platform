/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.personal_data.domain.ports.usecases.data_subject_requests;

import uim.platform.personal_data;

mixin(ShowModule!());

@safe:

interface IManageDataSubjectRequestsUseCase { 

    CommandResult createDataSubjectRequest(CreateDataSubjectRequestRequest r);
    DataSubjectRequest getDataSubjectRequest(TenantId tenantId, DataSubjectRequestId id);
    DataSubjectRequest[] listDataSubjectRequests(TenantId tenantId);
    DataSubjectRequest[] listDataSubjectRequests(TenantId tenantId, DataSubjectId dataSubjectId);
    DataSubjectRequest[] listDataSubjectRequests(TenantId tenantId, RequestStatus status);
    CommandResult updateDataSubjectRequest(UpdateDataSubjectRequestRequest r);
    CommandResult deleteDataSubjectRequest(TenantId tenantId, DataSubjectRequestId id);

}
