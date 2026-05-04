/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.presentation.http.controllers.retention_rule;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
// import std.conv : to;

// import uim.platform.data.privacy.application.usecases.manage.retention_rules;
// import uim.platform.data.privacy.application.dto;
// import uim.platform.data.privacy.domain.types;
// import uim.platform.data.privacy.domain.entities.retention_rule;
import uim.platform.data.privacy;

mixin(ShowModule!());

@safe:
class RetentionRuleController : PlatformController {
  private ManageRetentionRulesUseCase uc;

  this(ManageRetentionRulesUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/retention-rules", &handleCreate);
    router.get("/api/v1/retention-rules", &handleList);
    router.get("/api/v1/retention-rules/*", &handleGetById);
    router.put("/api/v1/retention-rules/*", &handleUpdate);
    router.delete_("/api/v1/retention-rules/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      CreateRetentionRuleRequest r;
      r.tenantId = req.getTenantId;
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.purpose = parsePurpose(j.getString("purpose"));
      r.retentionDays = j.getInteger("retentionDays");
      r.legalReference = j.getString("legalReference");
      r.isDefault = j.getBoolean("isDefault");

      auto result = uc.createRule(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Retention rule created successfully");

        res.writeJsonBody(resp, 201);
      } else
        writeError(res, 400, result.error);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      TenantId tenantId = req.getTenantId;
      auto purposeParam = req.headers.get("X-Purpose-Filter", "");

      RetentionRule[] items;
      if (purposeParam.length > 0)
        items = uc.listByPurpose(tenantId, parsePurpose(purposeParam));
      else
        items = uc.listRules(tenantId);

      auto arr = items.map!(e => e.toJson).array.toJson;

      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", items.length)
        .set("message", "Retention rules retrieved successfully");

      res.writeJsonBody(resp, 200);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private void handleGetById(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      TenantId tenantId = req.getTenantId;
      auto entry = uc.getRule(tenantId, id);
      if (entry.isNull) {
        writeError(res, 404, "Retention rule not found");
        return;
      }
      res.writeJsonBody(entry.toJson, 200);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      UpdateRetentionRuleRequest r;
      r.id = extractIdFromPath(req.requestURI);
      r.tenantId = req.getTenantId;
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.retentionDays = j.getInteger("retentionDays");
      r.legalReference = j.getString("legalReference");
      r.status = parseRuleStatus(j.getString("status"));

      auto result = uc.updateRule(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Retention rule updated successfully");

        res.writeJsonBody(resp, 200);
      } else
        writeError(res, 400, result.error);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      TenantId tenantId = req.getTenantId;
      uc.deleteRule(tenantId, id);
      res.writeJsonBody(Json.emptyObject, 204);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private static Json serialize(const RetentionRule e) {
    auto cats = e.categories.map!(c => Json(c.to!string)).array.toJson;

    return Json.emptyObject
      .set("id", e.id)
      .set("tenantId", e.tenantId)
      .set("name", e.name)
      .set("description", e.description)
      .set("purpose", e.purpose.to!string)
      .set("retentionDays", e.retentionDays)
      .set("legalReference", e.legalReference)
      .set("status", e.status.to!string)
      .set("isDefault", e.isDefault)
      .set("createdAt", e.createdAt)
      .set("updatedAt", e.updatedAt)
      .set("categories", cats);
  }

  private static ProcessingPurpose parsePurpose(string purpose) {
    switch (purpose) {
    case "serviceDelivery":
      return ProcessingPurpose.serviceDelivery;
    case "marketing":
      return ProcessingPurpose.marketing;
    case "analytics":
      return ProcessingPurpose.analytics;
    case "compliance":
      return ProcessingPurpose.compliance;
    case "humanResources":
      return ProcessingPurpose.humanResources;
    case "customerSupport":
      return ProcessingPurpose.customerSupport;
    case "billing":
      return ProcessingPurpose.billing;
    case "security":
      return ProcessingPurpose.security;
    case "research":
      return ProcessingPurpose.research;
    default:
      return ProcessingPurpose.serviceDelivery;
    }
  }

  private static RetentionRuleStatus parseRuleStatus(string s) {
    switch (s) {
    case "inactive":
      return RetentionRuleStatus.inactive;
    case "expired":
      return RetentionRuleStatus.expired;
    default:
      return RetentionRuleStatus.active;
    }
  }
}
