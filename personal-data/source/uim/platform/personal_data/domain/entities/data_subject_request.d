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
}

struct DataSubjectRequest {
    DataSubjectRequestId id;
    TenantId tenantId;
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
    string createdBy;
    string modifiedBy;
    string createdAt;
    string modifiedAt;
}
