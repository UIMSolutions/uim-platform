/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.field_service.domain.entities.smartform;

import uim.platform.field_service;

mixin(ShowModule!());

@safe:

struct Smartform {
    SmartformId id;
    TenantId tenantId;
    ServiceCallId serviceCallId;
    ActivityId activityId;
    string name;
    string description;
    SmartformType formType = SmartformType.checklist;
    SmartformStatus status = SmartformStatus.draft;
    string templateId;
    string submittedBy;
    string submittedDate;
    string approvedBy;
    string approvedDate;
    string formData;
    string safetyLabel;
    string signatureData;
    string createdBy;
    string modifiedBy;
    string createdAt;
    string modifiedAt;
}
