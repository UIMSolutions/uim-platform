/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.personal_data.infrastructure.persistence.memory.data_subject_requests;

import uim.platform.personal_data;

mixin(ShowModule!());

@safe:

class MemoryDataSubjectRequestRepository : TenantRepository!(DataSubjectRequest, DataSubjectRequestId), DataSubjectRequestRepository {
    
    size_t countByDataSubject(TenantId tenantId, DataSubjectId dataSubjectId) {
        return findByDataSubject(tenantId, dataSubjectId).length;
    }
    DataSubjectRequest[] findByDataSubject(TenantId tenantId, DataSubjectId dataSubjectId) {
        DataSubjectRequest[] result;
        foreach (v; findByTenant(tenantId))
            if (v.dataSubjectId == dataSubjectId) result ~= v;
        return result;
    }
    void removeByDataSubject(TenantId tenantId, DataSubjectId dataSubjectId) {
        findByDataSubject(tenantId, dataSubjectId).each!(v => store.remove(v));
    }

    size_t countByStatus(TenantId tenantId, RequestStatus status) {
        return findByStatus(tenantId, status).length;
    }
    DataSubjectRequest[] filterByStatus(DataSubjectRequest[] requests, RequestStatus status) {
        return requests.filter!(v => v.status == status).array;
    }
    DataSubjectRequest[] findByStatus(TenantId tenantId, RequestStatus status) {
        return filterByStatus(findByTenant(tenantId), status);
    }

    void removeByStatus(TenantId tenantId, RequestStatus status) {
        findByStatus(tenantId, status).each!(v => store.remove(v));
    }

    size_t countByAssignee(TenantId tenantId, string assignedTo) {
        return findByAssignee(tenantId, assignedTo).length;
    }
    DataSubjectRequest[] findByAssignee(TenantId tenantId, string assignedTo) {
        DataSubjectRequest[] result;
        foreach (v; findByTenant(tenantId))
            if (v.assignedTo == assignedTo) result ~= v;
        return result;
    }
    void removeByAssignee(TenantId tenantId, string assignedTo) {
        findByAssignee(tenantId, assignedTo).each!(v => store.remove(v));
    }

}
