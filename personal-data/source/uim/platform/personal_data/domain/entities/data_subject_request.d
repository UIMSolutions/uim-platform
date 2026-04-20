/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.personal_data.domain.entities.data_subject_request;

import uim.platform.personal_data;

mixin(ShowModule!());

@safe:

struct ProcessingComment {
    string author;
    string comment;
    string createdAt;

    Json toJson() const {
        return Json.emptyObject
            .set("author", author)
            .set("comment", comment)
            .set("createdAt", createdAt);
    }
}

struct DataSubjectRequest {
    mixin TenantEntity!(DataSubjectRequestId);

    DataSubjectId dataSubjectId;
    RequestType requestType;
    RequestStatus status;
    RequestPriority priority;
    string description;
    string[] applicationIds;
    string[] dataCategoryIds;
    ProcessingComment[] comments;
    string assignedTo;
    string dueDate;
    string completedAt;
    string rejectionReason;

    Json toJson() const {
        auto j = entityToJson
            .set("dataSubjectId", dataSubjectId.value)
            .set("requestType", requestType)
            .set("status", status)
            .set("priority", priority)
            .set("description", description)
            .set("applicationIds", applicationIds)
            .set("dataCategoryIds", dataCategoryIds)
            .set("comments", comments.map!(c => c.toJson()).array)
            .set("assignedTo", assignedTo)
            .set("dueDate", dueDate)
            .set("completedAt", completedAt)
            .set("rejectionReason", rejectionReason);

        return j;
    }
}
