/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.asset_strategy_performance.presentation.http.json_utils;

import uim.platform.asset_strategy_performance;

mixin(ShowModule!());

@safe:

Json equipmentToJson(Equipment e) {
    import std.conv : to;
    auto j = Json.emptyObject;
    j["id"] = Json(e.id);
    j["tenantId"] = Json(e.tenantId);
    j["modelId"] = Json(e.modelId);
    j["locationId"] = Json(e.locationId);
    j["serialNumber"] = Json(e.serialNumber);
    j["name"] = Json(e.name);
    j["description"] = Json(e.description);
    j["status"] = Json(e.status.to!string);
    j["manufacturer"] = Json(e.manufacturer);
    j["operatorId"] = Json(e.operatorId);
    j["installationDate"] = Json(e.installationDate);
    j["commissioningDate"] = Json(e.commissioningDate);
    j["warrantyEndDate"] = Json(e.warrantyEndDate);
    j["criticality"] = Json(e.criticality);
    j["maintenanceStrategy"] = Json(e.maintenanceStrategy);
    j["lastMaintenanceDate"] = Json(e.lastMaintenanceDate);
    j["nextMaintenanceDate"] = Json(e.nextMaintenanceDate);
    j["firmwareVersion"] = Json(e.firmwareVersion);
    j["createdBy"] = Json(e.createdBy);
    j["modifiedBy"] = Json(e.modifiedBy);
    j["createdAt"] = Json(e.createdAt);
    j["modifiedAt"] = Json(e.modifiedAt);
    return j;
}

Json modelToJson(Model m) {
    import std.conv : to;
    auto j = Json.emptyObject;
    j["id"] = Json(m.id);
    j["tenantId"] = Json(m.tenantId);
    j["name"] = Json(m.name);
    j["description"] = Json(m.description);
    j["manufacturer"] = Json(m.manufacturer);
    j["category"] = Json(m.category.to!string);
    j["version"] = Json(m.version_);
    j["modelNumber"] = Json(m.modelNumber);
    j["templateId"] = Json(m.templateId);
    j["isoStandard"] = Json(m.isoStandard);
    j["isPublished"] = Json(m.isPublished);
    j["createdBy"] = Json(m.createdBy);
    j["modifiedBy"] = Json(m.modifiedBy);
    j["createdAt"] = Json(m.createdAt);
    j["modifiedAt"] = Json(m.modifiedAt);
    return j;
}

Json locationToJson(Location l) {
    import std.conv : to;
    auto j = Json.emptyObject;
    j["id"] = Json(l.id);
    j["tenantId"] = Json(l.tenantId);
    j["name"] = Json(l.name);
    j["description"] = Json(l.description);
    j["locationType"] = Json(l.locationType.to!string);
    j["status"] = Json(l.status.to!string);
    j["parentLocationId"] = Json(l.parentLocationId);
    j["latitude"] = Json(l.latitude);
    j["longitude"] = Json(l.longitude);
    j["address"] = Json(l.address);
    j["building"] = Json(l.building);
    j["floor"] = Json(l.floor);
    j["room"] = Json(l.room);
    j["createdBy"] = Json(l.createdBy);
    j["modifiedBy"] = Json(l.modifiedBy);
    j["createdAt"] = Json(l.createdAt);
    j["modifiedAt"] = Json(l.modifiedAt);
    return j;
}

Json failureModeToJson(FailureMode fm) {
    import std.conv : to;
    auto j = Json.emptyObject;
    j["id"] = Json(fm.id);
    j["tenantId"] = Json(fm.tenantId);
    j["modelId"] = Json(fm.modelId);
    j["equipmentId"] = Json(fm.equipmentId);
    j["name"] = Json(fm.name);
    j["description"] = Json(fm.description);
    j["severity"] = Json(fm.severity.to!string);
    j["category"] = Json(fm.category.to!string);
    j["cause"] = Json(fm.cause);
    j["effect"] = Json(fm.effect);
    j["detection"] = Json(fm.detection);
    j["mitigation"] = Json(fm.mitigation);
    j["riskPriorityNumber"] = Json(fm.riskPriorityNumber);
    j["occurrenceProbability"] = Json(fm.occurrenceProbability);
    j["detectability"] = Json(fm.detectability);
    j["createdBy"] = Json(fm.createdBy);
    j["modifiedBy"] = Json(fm.modifiedBy);
    j["createdAt"] = Json(fm.createdAt);
    j["modifiedAt"] = Json(fm.modifiedAt);
    return j;
}

Json assessmentToJson(Assessment a) {
    import std.conv : to;
    auto j = Json.emptyObject;
    j["id"] = Json(a.id);
    j["tenantId"] = Json(a.tenantId);
    j["equipmentId"] = Json(a.equipmentId);
    j["modelId"] = Json(a.modelId);
    j["locationId"] = Json(a.locationId);
    j["name"] = Json(a.name);
    j["description"] = Json(a.description);
    j["assessmentType"] = Json(a.assessmentType.to!string);
    j["status"] = Json(a.status.to!string);
    j["templateId"] = Json(a.templateId);
    j["score"] = Json(a.score);
    j["riskLevel"] = Json(a.riskLevel);
    j["likelihood"] = Json(a.likelihood);
    j["consequence"] = Json(a.consequence);
    j["assessedBy"] = Json(a.assessedBy);
    j["approvedBy"] = Json(a.approvedBy);
    j["assessmentDate"] = Json(a.assessmentDate);
    j["nextReviewDate"] = Json(a.nextReviewDate);
    j["createdBy"] = Json(a.createdBy);
    j["modifiedBy"] = Json(a.modifiedBy);
    j["createdAt"] = Json(a.createdAt);
    j["modifiedAt"] = Json(a.modifiedAt);
    return j;
}

Json instructionToJson(Instruction i) {
    import std.conv : to;
    auto j = Json.emptyObject;
    j["id"] = Json(i.id);
    j["tenantId"] = Json(i.tenantId);
    j["modelId"] = Json(i.modelId);
    j["equipmentId"] = Json(i.equipmentId);
    j["name"] = Json(i.name);
    j["description"] = Json(i.description);
    j["instructionType"] = Json(i.instructionType.to!string);
    j["priority"] = Json(i.priority.to!string);
    j["version"] = Json(i.version_);
    j["steps"] = Json(i.steps);
    j["safetyNotes"] = Json(i.safetyNotes);
    j["requiredTools"] = Json(i.requiredTools);
    j["estimatedDuration"] = Json(i.estimatedDuration);
    j["publishedBy"] = Json(i.publishedBy);
    j["effectiveDate"] = Json(i.effectiveDate);
    j["createdBy"] = Json(i.createdBy);
    j["modifiedBy"] = Json(i.modifiedBy);
    j["createdAt"] = Json(i.createdAt);
    j["modifiedAt"] = Json(i.modifiedAt);
    return j;
}

Json functionToJson(Function f) {
    import std.conv : to;
    auto j = Json.emptyObject;
    j["id"] = Json(f.id);
    j["tenantId"] = Json(f.tenantId);
    j["equipmentId"] = Json(f.equipmentId);
    j["modelId"] = Json(f.modelId);
    j["locationId"] = Json(f.locationId);
    j["name"] = Json(f.name);
    j["description"] = Json(f.description);
    j["status"] = Json(f.status.to!string);
    j["operatingContext"] = Json(f.operatingContext);
    j["performanceStandard"] = Json(f.performanceStandard);
    j["failureDefinition"] = Json(f.failureDefinition);
    j["redundancy"] = Json(f.redundancy);
    j["createdBy"] = Json(f.createdBy);
    j["modifiedBy"] = Json(f.modifiedBy);
    j["createdAt"] = Json(f.createdAt);
    j["modifiedAt"] = Json(f.modifiedAt);
    return j;
}

Json indicatorToJson(Indicator ind) {
    import std.conv : to;
    auto j = Json.emptyObject;
    j["id"] = Json(ind.id);
    j["tenantId"] = Json(ind.tenantId);
    j["equipmentId"] = Json(ind.equipmentId);
    j["modelId"] = Json(ind.modelId);
    j["name"] = Json(ind.name);
    j["description"] = Json(ind.description);
    j["indicatorType"] = Json(ind.indicatorType.to!string);
    j["status"] = Json(ind.status.to!string);
    j["value"] = Json(ind.value_);
    j["unit"] = Json(ind.unit);
    j["thresholdWarning"] = Json(ind.thresholdWarning);
    j["thresholdCritical"] = Json(ind.thresholdCritical);
    j["measuredAt"] = Json(ind.measuredAt);
    j["createdBy"] = Json(ind.createdBy);
    j["createdAt"] = Json(ind.createdAt);
    j["modifiedAt"] = Json(ind.modifiedAt);
    return j;
}
