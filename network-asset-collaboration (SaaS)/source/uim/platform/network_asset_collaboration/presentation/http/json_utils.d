/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.network_asset_collaboration.presentation.http.json_utils;

import uim.platform.network_asset_collaboration;

mixin(ShowModule!());

@safe:

Json equipmentToJson(Equipment e) {
    import std.conv : to;
    auto j = Json.emptyObject;
    j["id"] = Json(e.id);
    j["tenantId"] = Json(e.tenantId);
    j["modelId"] = Json(e.modelId);
    j["serialNumber"] = Json(e.serialNumber);
    j["name"] = Json(e.name);
    j["description"] = Json(e.description);
    j["status"] = Json(e.status.to!string);
    j["manufacturer"] = Json(e.manufacturer);
    j["operatorCompanyId"] = Json(e.operatorCompanyId);
    j["location"] = Json(e.location);
    j["latitude"] = Json(e.latitude);
    j["longitude"] = Json(e.longitude);
    j["installationDate"] = Json(e.installationDate);
    j["commissioningDate"] = Json(e.commissioningDate);
    j["warrantyEndDate"] = Json(e.warrantyEndDate);
    j["batchNumber"] = Json(e.batchNumber);
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
    j["imageUrl"] = Json(m.imageUrl);
    j["isPublished"] = Json(m.isPublished);
    j["createdBy"] = Json(m.createdBy);
    j["modifiedBy"] = Json(m.modifiedBy);
    j["createdAt"] = Json(m.createdAt);
    j["modifiedAt"] = Json(m.modifiedAt);
    return j;
}

Json companyProfileToJson(CompanyProfile cp) {
    import std.conv : to;
    auto j = Json.emptyObject;
    j["id"] = Json(cp.id);
    j["tenantId"] = Json(cp.tenantId);
    j["name"] = Json(cp.name);
    j["description"] = Json(cp.description);
    j["companyType"] = Json(cp.companyType.to!string);
    j["status"] = Json(cp.status.to!string);
    j["industry"] = Json(cp.industry);
    j["website"] = Json(cp.website);
    j["contactEmail"] = Json(cp.contactEmail);
    j["contactPhone"] = Json(cp.contactPhone);
    j["addressStreet"] = Json(cp.addressStreet);
    j["addressCity"] = Json(cp.addressCity);
    j["addressState"] = Json(cp.addressState);
    j["addressCountry"] = Json(cp.addressCountry);
    j["addressPostalCode"] = Json(cp.addressPostalCode);
    j["createdBy"] = Json(cp.createdBy);
    j["modifiedBy"] = Json(cp.modifiedBy);
    j["createdAt"] = Json(cp.createdAt);
    j["modifiedAt"] = Json(cp.modifiedAt);
    return j;
}

Json documentToJson(Document d) {
    import std.conv : to;
    auto j = Json.emptyObject;
    j["id"] = Json(d.id);
    j["tenantId"] = Json(d.tenantId);
    j["equipmentId"] = Json(d.equipmentId);
    j["modelId"] = Json(d.modelId);
    j["name"] = Json(d.name);
    j["description"] = Json(d.description);
    j["documentType"] = Json(d.documentType.to!string);
    j["status"] = Json(d.status.to!string);
    j["version"] = Json(d.version_);
    j["fileName"] = Json(d.fileName);
    j["fileSize"] = Json(d.fileSize);
    j["mimeType"] = Json(d.mimeType);
    j["language"] = Json(d.language);
    j["uploadedBy"] = Json(d.uploadedBy);
    j["createdBy"] = Json(d.createdBy);
    j["modifiedBy"] = Json(d.modifiedBy);
    j["createdAt"] = Json(d.createdAt);
    j["modifiedAt"] = Json(d.modifiedAt);
    return j;
}

Json announcementToJson(Announcement a) {
    import std.conv : to;
    auto j = Json.emptyObject;
    j["id"] = Json(a.id);
    j["tenantId"] = Json(a.tenantId);
    j["title"] = Json(a.title);
    j["description"] = Json(a.description);
    j["announcementType"] = Json(a.announcementType.to!string);
    j["severity"] = Json(a.severity.to!string);
    j["status"] = Json(a.status.to!string);
    j["publisherId"] = Json(a.publisherId);
    j["effectiveDate"] = Json(a.effectiveDate);
    j["expiryDate"] = Json(a.expiryDate);
    j["createdBy"] = Json(a.createdBy);
    j["modifiedBy"] = Json(a.modifiedBy);
    j["createdAt"] = Json(a.createdAt);
    j["modifiedAt"] = Json(a.modifiedAt);
    return j;
}

Json failureModeToJson(FailureMode fm) {
    import std.conv : to;
    auto j = Json.emptyObject;
    j["id"] = Json(fm.id);
    j["tenantId"] = Json(fm.tenantId);
    j["modelId"] = Json(fm.modelId);
    j["name"] = Json(fm.name);
    j["description"] = Json(fm.description);
    j["severity"] = Json(fm.severity.to!string);
    j["cause"] = Json(fm.cause);
    j["effect"] = Json(fm.effect);
    j["detection"] = Json(fm.detection);
    j["mitigation"] = Json(fm.mitigation);
    j["riskPriorityNumber"] = Json(fm.riskPriorityNumber);
    j["createdBy"] = Json(fm.createdBy);
    j["modifiedBy"] = Json(fm.modifiedBy);
    j["createdAt"] = Json(fm.createdAt);
    j["modifiedAt"] = Json(fm.modifiedAt);
    return j;
}

Json sparePartToJson(SparePart sp) {
    auto j = Json.emptyObject;
    j["id"] = Json(sp.id);
    j["tenantId"] = Json(sp.tenantId);
    j["modelId"] = Json(sp.modelId);
    j["equipmentId"] = Json(sp.equipmentId);
    j["partNumber"] = Json(sp.partNumber);
    j["name"] = Json(sp.name);
    j["description"] = Json(sp.description);
    j["manufacturer"] = Json(sp.manufacturer);
    j["category"] = Json(sp.category);
    j["quantity"] = Json(sp.quantity);
    j["unit"] = Json(sp.unit);
    j["leadTimeDays"] = Json(sp.leadTimeDays);
    j["isCritical"] = Json(sp.isCritical);
    j["createdBy"] = Json(sp.createdBy);
    j["modifiedBy"] = Json(sp.modifiedBy);
    j["createdAt"] = Json(sp.createdAt);
    j["modifiedAt"] = Json(sp.modifiedAt);
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
