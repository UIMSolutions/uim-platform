/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.product_development.domain.entities.change_request;

import uim.platform.product_development;

mixin(ShowModule!());

@safe:

struct ChangeRequest {
    ChangeRequestId id;
    TenantId tenantId;
    string productId;
    string title;
    string description;
    ChangeRequestStatus status = ChangeRequestStatus.draft;
    ChangeRequestPriority priority = ChangeRequestPriority.medium;
    ChangeCategory category = ChangeCategory.designChange;
    string reason;
    string impact;
    string requestedBy;
    string assignedTo;
    string approvedBy;
    string requestedDate;
    string targetDate;
    string completedDate;
    string affectedDocuments;
    string affectedBoms;
    string createdBy;
    string modifiedBy;
    string createdAt;
    string modifiedAt;
}
