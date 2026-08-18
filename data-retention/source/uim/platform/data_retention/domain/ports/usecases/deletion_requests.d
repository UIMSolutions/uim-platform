/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data_retention.domain.ports.usecases.deletion_requests;

import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

interface IManageDeletionRequestsUseCase { 
    
    UsecaseResult createDeletionRequest(CreateDeletionRequestRequest req);
    UsecaseResult updateDeletionRequest(UpdateDeletionRequestRequest req);
    bool hasDeletionRequest(TenantId tenantId, DeletionRequestId id);
    DeletionRequest getDeletionRequest(TenantId tenantId, DeletionRequestId id);
    DeletionRequest[] listDeletionRequests(TenantId tenantId);
    DeletionRequest[] listDeletionRequestsByStatus(TenantId tenantId, DeletionRequestStatus status);
    UsecaseResult deleteDeletionRequest(TenantId tenantId, DeletionRequestId id);

}
