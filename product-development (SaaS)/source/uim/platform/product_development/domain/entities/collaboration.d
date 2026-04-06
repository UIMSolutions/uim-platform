/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.product_development.domain.entities.collaboration;

import uim.platform.product_development;

mixin(ShowModule!());

@safe:

struct Collaboration {
    CollaborationId id;
    TenantId tenantId;
    string productId;
    string title;
    string description;
    CollaborationType collaborationType = CollaborationType.designReview;
    CollaborationStatus status = CollaborationStatus.open;
    string assignedTo;
    string participants;
    string dueDate;
    string resolvedDate;
    string resolution;
    string relatedDocumentId;
    string relatedChangeRequestId;
    string createdBy;
    string modifiedBy;
    string createdAt;
    string modifiedAt;
}
