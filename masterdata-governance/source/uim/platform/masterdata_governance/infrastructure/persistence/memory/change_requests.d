/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.masterdata_governance.infrastructure.persistence.memory.change_requests;

import uim.platform.masterdata_governance;

mixin(ShowModule!());

@safe:

class MemoryChangeRequestRepository
    : TenantRepository!(ChangeRequest, ChangeRequestId), ChangeRequestRepository {

    size_t countByStatus(TenantId tenantId, ChangeRequestStatus status) {
        return findByStatus(tenantId, status).length;
    }

    ChangeRequest[] findByStatus(TenantId tenantId, ChangeRequestStatus status) {
        return findByTenant(tenantId).filter!(e => e.status == status).array;
    }

    void removeByStatus(TenantId tenantId, ChangeRequestStatus status) {
        findByStatus(tenantId, status).each!(e => remove(e));
    }

    ChangeRequest[] findByBusinessPartner(TenantId tenantId, BusinessPartnerId bpId) {
        return findByTenant(tenantId).filter!(e => e.businessPartnerId.value == bpId.value).array;
    }

    ChangeRequest[] findByRequestedBy(TenantId tenantId, UserId userId) {
        return findByTenant(tenantId).filter!(e => e.requestedBy.value == userId.value).array;
    }

    ChangeRequest[] findByReviewedBy(TenantId tenantId, UserId userId) {
        return findByTenant(tenantId).filter!(e => e.reviewedBy.value == userId.value).array;
    }

    ChangeRequest[] findByType(TenantId tenantId, ChangeRequestType requestType) {
        return findByTenant(tenantId).filter!(e => e.requestType == requestType).array;
    }
}
