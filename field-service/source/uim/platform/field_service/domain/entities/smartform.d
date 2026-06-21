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
    mixin TenantEntity!SmartformId;

    ServiceCallId serviceCallId;
    ActivityId activityId;
    string name;
    string description;
    SmartformType formType = SmartformType.checklist;
    SmartformStatus status = SmartformStatus.draft;
    string templateId;
    UserId submittedBy;
    string submittedDate;
    UserId approvedBy;
    string approvedDate;
    string formData;
    string safetyLabel;
    string signatureData;

    Json toJson() const {
        return entityToJson
            .set("serviceCallId", serviceCallId)
            .set("activityId", activityId)
            .set("name", name)
            .set("description", description)
            .set("formType", formType.to!string)
            .set("status", status.to!string)
            .set("templateId", templateId)
            .set("submittedBy", submittedBy)
            .set("submittedDate", submittedDate)
            .set("approvedBy", approvedBy)
            .set("approvedDate", approvedDate)
            .set("formData", formData)
            .set("safetyLabel", safetyLabel)
            .set("signatureData", signatureData);
    }
}
