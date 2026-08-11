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
    CommandResult createChangeRequest(ChangeRequestDTO dto);
    CommandResult submitChangeRequest(TenantId tenantId, ChangeRequestId id, UserId submittedBy);
    CommandResult approveChangeRequest(TenantId tenantId, ChangeRequestId id, UserId approvedBy, string reviewerComments);
    CommandResult rejectChangeRequest(TenantId tenantId, ChangeRequestId id, UserId rejectedBy, string reviewerComments);
    CommandResult requestRevision(TenantId tenantId, ChangeRequestId id, UserId reviewedBy, string reviewerComments);
    CommandResult withdrawChangeRequest(TenantId tenantId, ChangeRequestId id);
    CommandResult deleteChangeRequest(TenantId tenantId, ChangeRequestId id);

}
