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
    
    DataSubjectRequest[] findByTenant(TenantId tenantId) {
        DataSubjectRequest[] result;
        foreach (v; findAll)
            if (v.tenantId == tenantId) result ~= v;
        return result;
    }

    DataSubjectRequest[] findByDataSubject(DataSubjectId dataSubjectId) {
        DataSubjectRequest[] result;
        foreach (v; findAll)
            if (v.dataSubjectId == dataSubjectId) result ~= v;
        return result;
    }

    DataSubjectRequest[] findByStatus(RequestStatus status) {
        DataSubjectRequest[] result;
        foreach (v; findAll)
            if (v.status == status) result ~= v;
        return result;
    }

    DataSubjectRequest[] findByAssignee(string assignedTo) {
        DataSubjectRequest[] result;
        foreach (v; findAll)
            if (v.assignedTo == assignedTo) result ~= v;
        return result;
    }

    void save(DataSubjectRequest entity) { store[entity.id] = entity; }
    void update(DataSubjectRequest entity) { store[entity.id] = entity; }
    void remove(DataSubjectRequestId id) { store.removeById(id); }
}
