/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.masterdata_governance.domain.repositories.change_requests;

import uim.platform.masterdata_governance;

// mixin(ShowModule!());

@safe:

interface ChangeRequestRepository : ITentRepository!(ChangeRequest, ChangeRequestId) {

    size_t countByStatus(TenantId tenantId, ChangeRequestStatus status);
    ChangeRequest[] findByStatus(TenantId tenantId, ChangeRequestStatus status);
    void removeByStatus(TenantId tenantId, ChangeRequestStatus status);

    ChangeRequest[] findByBusinessPartner(TenantId tenantId, BusinessPartnerId bpId);
    ChangeRequest[] findByRequestedBy(TenantId tenantId, UserId userId);
    ChangeRequest[] findByReviewedBy(TenantId tenantId, UserId userId);
    ChangeRequest[] findByType(TenantId tenantId, ChangeRequestType requestType);
}
