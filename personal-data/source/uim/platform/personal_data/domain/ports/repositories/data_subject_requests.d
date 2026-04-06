/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.personal_data.domain.ports.repositories.data_subject_requests;

import uim.platform.personal_data;

mixin(ShowModule!());

@safe:

interface DataSubjectRequestRepository {
    DataSubjectRequest findById(DataSubjectRequestId id);
    DataSubjectRequest[] findByTenant(TenantId tenantId);
    DataSubjectRequest[] findByDataSubject(DataSubjectId dataSubjectId);
    DataSubjectRequest[] findByStatus(RequestStatus status);
    DataSubjectRequest[] findByAssignee(string assignedTo);
    void save(DataSubjectRequest entity);
    void update(DataSubjectRequest entity);
    void remove(DataSubjectRequestId id);
}
