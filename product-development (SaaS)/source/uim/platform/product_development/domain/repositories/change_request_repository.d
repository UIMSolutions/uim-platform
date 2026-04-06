/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.product_development.domain.repositories.change_request_repository;

import uim.platform.product_development;

mixin(ShowModule!());

@safe:

interface ChangeRequestRepository {
    ChangeRequest[] findAll();
    ChangeRequest* findById(ChangeRequestId id);
    ChangeRequest[] findByTenant(TenantId tenantId);
    ChangeRequest[] findByProduct(string productId);
    ChangeRequest[] findByStatus(ChangeRequestStatus status);
    ChangeRequest[] findByAssignee(string assignedTo);
    void save(ChangeRequest cr);
    void update(ChangeRequest cr);
    void remove(ChangeRequestId id);
}
