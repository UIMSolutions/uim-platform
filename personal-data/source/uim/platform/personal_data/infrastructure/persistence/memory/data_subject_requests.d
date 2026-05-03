/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.personal_data.infrastructure.persistence.memory.data_subject_requests;

import uim.platform.personal_data;

mixin(ShowModule!());

@safe:

class MemoryDataSubjectRequestRepository :TenantRepository!(DataSubjectRequest, DataSubjectRequestId), DataSubjectRequestRepository {
    
    size_t countByDataSubject(DataSubjectId dataSubjectId) {
        return findByDataSubject(dataSubjectId).length;
    }
    DataSubjectRequest[] findByDataSubject(DataSubjectId dataSubjectId) {
        DataSubjectRequest[] result;
        foreach (v; findAll)
            if (v.dataSubjectId == dataSubjectId) result ~= v;
        return result;
    }
    void removeByDataSubject(DataSubjectId dataSubjectId) {
        findByDataSubject(dataSubjectId).each!(v => store.remove(v));
    }

    size_t countByStatus(RequestStatus status) {
        return findByStatus(status).length;
    }
    DataSubjectRequest[] findByStatus(RequestStatus status) {
        DataSubjectRequest[] result;
        foreach (v; findAll)
            if (v.status == status) result ~= v;
        return result;
    }
    void removeByStatus(RequestStatus status) {
        findByStatus(status).each!(v => store.remove(v));
    }

    size_t countByAssignee(string assignedTo) {
        return findByAssignee(assignedTo).length;
    }
    DataSubjectRequest[] findByAssignee(string assignedTo) {
        DataSubjectRequest[] result;
        foreach (v; findAll)
            if (v.assignedTo == assignedTo) result ~= v;
        return result;
    }
    void removeByAssignee(string assignedTo) {
        findByAssignee(assignedTo).each!(v => store.remove(v));
    }

}
