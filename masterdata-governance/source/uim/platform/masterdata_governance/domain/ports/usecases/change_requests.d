/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.masterdata_governance.domain.ports.usecases.change_requests;

import uim.platform.masterdata_governance;

mixin(ShowModule!());

@safe:

interface IManageChangeRequestsUseCase {

    ChangeRequest getChangeRequest(TenantId tenantId, ChangeRequestId id);
    ChangeRequest[] listChangeRequests(TenantId tenantId);
    ChangeRequest[] listChangeRequests(TenantId tenantId, ChangeRequestStatus status);
    ChangeRequest[] listChangeRequests(TenantId tenantId, BusinessPartnerId bpId);
    ChangeRequest[] listChangeRequests(TenantId tenantId, UserId userId);
    UsecaseResult createChangeRequest(ChangeRequestDTO dto);
    UsecaseResult submitChangeRequest(TenantId tenantId, ChangeRequestId id, UserId submittedBy);
    UsecaseResult approveChangeRequest(TenantId tenantId, ChangeRequestId id, UserId approvedBy, string reviewerComments);
    UsecaseResult rejectChangeRequest(TenantId tenantId, ChangeRequestId id, UserId rejectedBy, string reviewerComments);
    UsecaseResult requestRevision(TenantId tenantId, ChangeRequestId id, UserId reviewedBy, string reviewerComments);
    UsecaseResult withdrawChangeRequest(TenantId tenantId, ChangeRequestId id);
    UsecaseResult deleteChangeRequest(TenantId tenantId, ChangeRequestId id);

}
