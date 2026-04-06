/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.product_development.presentation.http.json_utils;

import uim.platform.product_development;

mixin(ShowModule!());

@safe:

Json productToJson(Product p) {
    import std.conv : to;
    auto j = Json.emptyObject;
    j["id"] = Json(p.id);
    j["tenantId"] = Json(p.tenantId);
    j["name"] = Json(p.name);
    j["description"] = Json(p.description);
    j["productType"] = Json(p.productType.to!string);
    j["status"] = Json(p.status.to!string);
    j["lifecyclePhase"] = Json(p.lifecyclePhase.to!string);
    j["version"] = Json(p.version_);
    j["productNumber"] = Json(p.productNumber);
    j["manufacturer"] = Json(p.manufacturer);
    j["category"] = Json(p.category);
    j["baseUnit"] = Json(p.baseUnit);
    j["weight"] = Json(p.weight);
    j["weightUnit"] = Json(p.weightUnit);
    j["validFrom"] = Json(p.validFrom);
    j["validTo"] = Json(p.validTo);
    j["createdBy"] = Json(p.createdBy);
    j["modifiedBy"] = Json(p.modifiedBy);
    j["createdAt"] = Json(p.createdAt);
    j["modifiedAt"] = Json(p.modifiedAt);
    return j;
}

Json bomToJson(BillOfMaterial b) {
    import std.conv : to;
    auto j = Json.emptyObject;
    j["id"] = Json(b.id);
    j["tenantId"] = Json(b.tenantId);
    j["productId"] = Json(b.productId);
    j["name"] = Json(b.name);
    j["description"] = Json(b.description);
    j["bomType"] = Json(b.bomType.to!string);
    j["version"] = Json(b.version_);
    j["usage"] = Json(b.usage);
    j["plant"] = Json(b.plant);
    j["validFrom"] = Json(b.validFrom);
    j["validTo"] = Json(b.validTo);
    j["baseQuantity"] = Json(b.baseQuantity);
    j["baseUnit"] = Json(b.baseUnit);
    j["isActive"] = Json(b.isActive);
    j["createdBy"] = Json(b.createdBy);
    j["modifiedBy"] = Json(b.modifiedBy);
    j["createdAt"] = Json(b.createdAt);
    j["modifiedAt"] = Json(b.modifiedAt);
    return j;
}

Json changeRequestToJson(ChangeRequest cr) {
    import std.conv : to;
    auto j = Json.emptyObject;
    j["id"] = Json(cr.id);
    j["tenantId"] = Json(cr.tenantId);
    j["productId"] = Json(cr.productId);
    j["title"] = Json(cr.title);
    j["description"] = Json(cr.description);
    j["status"] = Json(cr.status.to!string);
    j["priority"] = Json(cr.priority.to!string);
    j["category"] = Json(cr.category.to!string);
    j["reason"] = Json(cr.reason);
    j["impact"] = Json(cr.impact);
    j["requestedBy"] = Json(cr.requestedBy);
    j["assignedTo"] = Json(cr.assignedTo);
    j["approvedBy"] = Json(cr.approvedBy);
    j["requestedDate"] = Json(cr.requestedDate);
    j["targetDate"] = Json(cr.targetDate);
    j["completedDate"] = Json(cr.completedDate);
    j["affectedDocuments"] = Json(cr.affectedDocuments);
    j["affectedBoms"] = Json(cr.affectedBoms);
    j["createdBy"] = Json(cr.createdBy);
    j["modifiedBy"] = Json(cr.modifiedBy);
    j["createdAt"] = Json(cr.createdAt);
    j["modifiedAt"] = Json(cr.modifiedAt);
    return j;
}

Json documentToJson(Document d) {
    import std.conv : to;
    auto j = Json.emptyObject;
    j["id"] = Json(d.id);
    j["tenantId"] = Json(d.tenantId);
    j["productId"] = Json(d.productId);
    j["name"] = Json(d.name);
    j["description"] = Json(d.description);
    j["documentType"] = Json(d.documentType.to!string);
    j["status"] = Json(d.status.to!string);
    j["version"] = Json(d.version_);
    j["fileName"] = Json(d.fileName);
    j["mimeType"] = Json(d.mimeType);
    j["fileSize"] = Json(d.fileSize);
    j["documentNumber"] = Json(d.documentNumber);
    j["language"] = Json(d.language);
    j["author"] = Json(d.author);
    j["approvedBy"] = Json(d.approvedBy);
    j["validFrom"] = Json(d.validFrom);
    j["validTo"] = Json(d.validTo);
    j["createdBy"] = Json(d.createdBy);
    j["modifiedBy"] = Json(d.modifiedBy);
    j["createdAt"] = Json(d.createdAt);
    j["modifiedAt"] = Json(d.modifiedAt);
    return j;
}

Json specificationToJson(Specification s) {
    import std.conv : to;
    auto j = Json.emptyObject;
    j["id"] = Json(s.id);
    j["tenantId"] = Json(s.tenantId);
    j["productId"] = Json(s.productId);
    j["name"] = Json(s.name);
    j["description"] = Json(s.description);
    j["specificationType"] = Json(s.specificationType.to!string);
    j["status"] = Json(s.status.to!string);
    j["version"] = Json(s.version_);
    j["specificationNumber"] = Json(s.specificationNumber);
    j["property"] = Json(s.property);
    j["targetValue"] = Json(s.targetValue);
    j["unit"] = Json(s.unit);
    j["lowerLimit"] = Json(s.lowerLimit);
    j["upperLimit"] = Json(s.upperLimit);
    j["testMethod"] = Json(s.testMethod);
    j["complianceStandard"] = Json(s.complianceStandard);
    j["approvedBy"] = Json(s.approvedBy);
    j["createdBy"] = Json(s.createdBy);
    j["modifiedBy"] = Json(s.modifiedBy);
    j["createdAt"] = Json(s.createdAt);
    j["modifiedAt"] = Json(s.modifiedAt);
    return j;
}

Json recipeToJson(Recipe r) {
    import std.conv : to;
    auto j = Json.emptyObject;
    j["id"] = Json(r.id);
    j["tenantId"] = Json(r.tenantId);
    j["productId"] = Json(r.productId);
    j["name"] = Json(r.name);
    j["description"] = Json(r.description);
    j["recipeType"] = Json(r.recipeType.to!string);
    j["status"] = Json(r.status.to!string);
    j["version"] = Json(r.version_);
    j["recipeNumber"] = Json(r.recipeNumber);
    j["yield"] = Json(r.yield_);
    j["yieldUnit"] = Json(r.yieldUnit);
    j["batchSize"] = Json(r.batchSize);
    j["batchUnit"] = Json(r.batchUnit);
    j["shelfLife"] = Json(r.shelfLife);
    j["storageConditions"] = Json(r.storageConditions);
    j["ingredients"] = Json(r.ingredients);
    j["instructions"] = Json(r.instructions);
    j["createdBy"] = Json(r.createdBy);
    j["modifiedBy"] = Json(r.modifiedBy);
    j["createdAt"] = Json(r.createdAt);
    j["modifiedAt"] = Json(r.modifiedAt);
    return j;
}

Json collaborationToJson(Collaboration c) {
    import std.conv : to;
    auto j = Json.emptyObject;
    j["id"] = Json(c.id);
    j["tenantId"] = Json(c.tenantId);
    j["productId"] = Json(c.productId);
    j["title"] = Json(c.title);
    j["description"] = Json(c.description);
    j["collaborationType"] = Json(c.collaborationType.to!string);
    j["status"] = Json(c.status.to!string);
    j["assignedTo"] = Json(c.assignedTo);
    j["participants"] = Json(c.participants);
    j["dueDate"] = Json(c.dueDate);
    j["resolvedDate"] = Json(c.resolvedDate);
    j["resolution"] = Json(c.resolution);
    j["relatedDocumentId"] = Json(c.relatedDocumentId);
    j["relatedChangeRequestId"] = Json(c.relatedChangeRequestId);
    j["createdBy"] = Json(c.createdBy);
    j["modifiedBy"] = Json(c.modifiedBy);
    j["createdAt"] = Json(c.createdAt);
    j["modifiedAt"] = Json(c.modifiedAt);
    return j;
}

Json productStructureToJson(ProductStructure ps) {
    import std.conv : to;
    auto j = Json.emptyObject;
    j["id"] = Json(ps.id);
    j["tenantId"] = Json(ps.tenantId);
    j["productId"] = Json(ps.productId);
    j["name"] = Json(ps.name);
    j["description"] = Json(ps.description);
    j["nodeType"] = Json(ps.nodeType.to!string);
    j["parentNodeId"] = Json(ps.parentNodeId);
    j["position"] = Json(ps.position);
    j["sortOrder"] = Json(ps.sortOrder);
    j["quantity"] = Json(ps.quantity);
    j["unit"] = Json(ps.unit);
    j["variantCondition"] = Json(ps.variantCondition);
    j["configurationProfile"] = Json(ps.configurationProfile);
    j["isMandatory"] = Json(ps.isMandatory);
    j["createdBy"] = Json(ps.createdBy);
    j["modifiedBy"] = Json(ps.modifiedBy);
    j["createdAt"] = Json(ps.createdAt);
    j["modifiedAt"] = Json(ps.modifiedAt);
    return j;
}
