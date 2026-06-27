/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.personal_data.domain.ports.repositories.data_subject_requests;

import uim.platform.personal_data;

// mixin(ShowModule!());

@safe:

interface DataSubjectRequestRepository : ITenantRepository!(DataSubjectRequest, DataSubjectRequestId) {

    size_t countByDataSubject(TenantId tenantId, DataSubjectId dataSubjectId);
    DataSubjectRequest[] findByDataSubject(TenantId tenantId, DataSubjectId dataSubjectId);
    void removeByDataSubject(TenantId tenantId, DataSubjectId dataSubjectId);

    size_t countByStatus(TenantId tenantId, RequestStatus status);
    DataSubjectRequest[] findByStatus(TenantId tenantId, RequestStatus status);
    void removeByStatus(TenantId tenantId, RequestStatus status);

    size_t countByAssignee(TenantId tenantId, string assignedTo);
    DataSubjectRequest[] findByAssignee(TenantId tenantId, string assignedTo);
    void removeByAssignee(TenantId tenantId, string assignedTo);

}
