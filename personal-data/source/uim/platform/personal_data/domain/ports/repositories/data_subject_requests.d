/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.personal_data.domain.ports.repositories.data_subject_requests;

import uim.platform.personal_data;

mixin(ShowModule!());

@safe:

interface DataSubjectRequestRepository : ITenantRepository!(DataSubjectRequest, DataSubjectRequestId) {

    size_t countByDataSubject(DataSubjectId dataSubjectId);
    DataSubjectRequest[] findByDataSubject(DataSubjectId dataSubjectId);
    void removeByDataSubject(DataSubjectId dataSubjectId);

    size_t countByStatus(RequestStatus status);
    DataSubjectRequest[] findByStatus(RequestStatus status);
    void removeByStatus(RequestStatus status);

    size_t countByAssignee(string assignedTo);
    DataSubjectRequest[] findByAssignee(string assignedTo);
    void removeByAssignee(string assignedTo);

}
