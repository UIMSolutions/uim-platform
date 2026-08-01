/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.personal_data.infrastructure.persistence.repositories.data_subject_requests;

import uim.platform.personal_data;

mixin(ShowModule!());

@safe:

class DataSubjectRequestRepository : TenantRepository!(DataSubjectRequest, DataSubjectRequestId), DataSubjectRequestRepository {
    
    // #region ByDataSubject
    size_t countByDataSubject(TenantId tenantId, DataSubjectId dataSubjectId) {
        return findByDataSubject(tenantId, dataSubjectId).length;
    }

    DataSubjectRequest[] filterByDataSubject(DataSubjectRequest[] requests, DataSubjectId dataSubjectId) {
        return requests.filter!(v => v.dataSubjectId == dataSubjectId).array;
    }
    
    DataSubjectRequest[] findByDataSubject(TenantId tenantId, DataSubjectId dataSubjectId) {
        return filterByDataSubject(findByTenant(tenantId), dataSubjectId);
    }
    
    void removeByDataSubject(TenantId tenantId, DataSubjectId dataSubjectId) {
        findByDataSubject(tenantId, dataSubjectId).each!(v => remove(v));
    }
    // #endregion ByDataSubject

    // #region ByStatus
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
        findByStatus(tenantId, status).each!(v => remove(v));
    }
    // #endregion ByStatus

    // #region ByAssignee
    size_t countByAssignee(TenantId tenantId, string assignedTo) {
        return findByAssignee(tenantId, assignedTo).length;
    }

    DataSubjectRequest[] filterByAssignee(DataSubjectRequest[] requests, string assignedTo) {
        return requests.filter!(v => v.assignedTo == assignedTo).array;
    }

    DataSubjectRequest[] findByAssignee(TenantId tenantId, string assignedTo) {
        return filterByAssignee(findByTenant(tenantId), assignedTo);
    }

    void removeByAssignee(TenantId tenantId, string assignedTo) {
        findByAssignee(tenantId, assignedTo).each!(v => remove(v));
    }
    // #endregion ByAssignee

}
