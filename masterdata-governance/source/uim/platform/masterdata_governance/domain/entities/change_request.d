/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.masterdata_governance.domain.entities.change_request;

import uim.platform.masterdata_governance;

// mixin(ShowModule!());

@safe:

struct ChangeRequest {
    mixin TenantEntity!(ChangeRequestId);

    BusinessPartnerId businessPartnerId;
    ChangeRequestStatus status = ChangeRequestStatus.draft;
    ChangeRequestType requestType = ChangeRequestType.update;

    string subject;
    string description;
    string changedFields;
    string proposedValues;
    string currentValues;
    string comments;
    string reviewerComments;

    UserId requestedBy;
    UserId reviewedBy;
    UserId decidedBy;

    string dueDate;
    long submittedAt;
    long reviewStartedAt;
    long decidedAt;

    int priority;
    string externalReference;

    Json toJson() const {
        return entityToJson
            .set("businessPartnerId", businessPartnerId.value)
            .set("status", status.to!string)
            .set("requestType", requestType.to!string)
            .set("subject", subject)
            .set("description", description)
            .set("changedFields", changedFields)
            .set("proposedValues", proposedValues)
            .set("currentValues", currentValues)
            .set("comments", comments)
            .set("reviewerComments", reviewerComments)
            .set("requestedBy", requestedBy.value)
            .set("reviewedBy", reviewedBy.value)
            .set("decidedBy", decidedBy.value)
            .set("dueDate", dueDate)
            .set("submittedAt", submittedAt)
            .set("reviewStartedAt", reviewStartedAt)
            .set("decidedAt", decidedAt)
            .set("priority", priority)
            .set("externalReference", externalReference);
    }
}
