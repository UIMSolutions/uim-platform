/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.presentation.http.retention_rule;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
// import std.conv : to;

import uim.platform.data.privacy.application.usecases.manage.retention_rules;
import uim.platform.data.privacy.application.dto;
import uim.platform.data.privacy.domain.types;
import uim.platform.data.privacy.domain.entities.retention_rule;

class RetentionRuleController {
  private ManageRetentionRulesUseCase uc;

  this(ManageRetentionRulesUseCase uc)
  {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router)
  {
    router.post("/api/v1/retention-rules", &handleCreate);
    router.get("/api/v1/retention-rules", &handleList);
    router.get("/api/v1/retention-rules/*", &handleGetById);
    router.put("/api/v1/retention-rules/*", &handleUpdate);
    router.delete_("/api/v1/retention-rules/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto j = req.json;
      CreateRetentionRuleRequest r;
      r.tenantId = req.headers.get("X-Tenant-Id", "");
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.purpose = parsePurpose(j.getString("purpose"));
      r.retentionDays = j.getInteger("retentionDays");
      r.legalReference = j.getString("legalReference");
      r.isDefault = j.getBoolean("isDefault");

      auto result = uc.createRule(r);
      if (result.isSuccess())
      {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        res.writeJsonBody(resp, 201);
      }
      else
        writeError(res, 400, result.error);
    }
    catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      auto purposeParam = req.headers.get("X-Purpose-Filter", "");

      RetentionRule[] items;
      if (purposeParam.length > 0)
        items = uc.listByPurpose(tenantId, parsePurpose(purposeParam));
      else
        items = uc.listRules(tenantId);

      auto arr = Json.emptyArray;
      foreach (ref e; items)
        arr ~= serialize(e);

      auto resp = Json.emptyObject;
      resp["items"] = arr;
      resp["totalCount"] = Json(cast(long) items.length);
      res.writeJsonBody(resp, 200);
    }
    catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private void handleGetById(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto id = extractIdFromPath(req.requestURI);
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      auto entry = uc.getRule(id, tenantId);
      if (entry is null)
      {
        writeError(res, 404, "Retention rule not found");
        return;
      }
      res.writeJsonBody(serialize(*entry), 200);
    }
    catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto j = req.json;
      UpdateRetentionRuleRequest r;
      r.id = extractIdFromPath(req.requestURI);
      r.tenantId = req.headers.get("X-Tenant-Id", "");
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.retentionDays = j.getInteger("retentionDays");
      r.legalReference = j.getString("legalReference");
      r.status = parseRuleStatus(j.getString("status"));

      auto result = uc.updateRule(r);
      if (result.isSuccess())
      {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        res.writeJsonBody(resp, 200);
      }
      else
        writeError(res, 400, result.error);
    }
    catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto id = extractIdFromPath(req.requestURI);
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      uc.deleteRule(id, tenantId);
      res.writeJsonBody(Json.emptyObject, 204);
    }
    catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private static Json serialize(ref const RetentionRule e)
  {
    auto j = Json.emptyObject;
    j["id"] = Json(e.id);
    j["tenantId"] = Json(e.tenantId);
    j["name"] = Json(e.name);
    j["description"] = Json(e.description);
    j["purpose"] = Json(e.purpose.to!string);
    j["retentionDays"] = Json(cast(long) e.retentionDays);
    j["legalReference"] = Json(e.legalReference);
    j["status"] = Json(e.status.to!string);
    j["isDefault"] = Json(e.isDefault);
    j["createdAt"] = Json(e.createdAt);
    j["updatedAt"] = Json(e.updatedAt);

    auto cats = Json.emptyArray;
    foreach (ref c; e.categories)
      cats ~= Json(c.to!string);
    j["categories"] = cats;

    return j;
  }

  private static ProcessingPurpose parsePurpose(string s)
  {
    switch (s)
    {
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

  private static RetentionRuleStatus parseRuleStatus(string s)
  {
    switch (s)
    {
    case "inactive":
      return RetentionRuleStatus.inactive;
    case "expired":
      return RetentionRuleStatus.expired;
    default:
      return RetentionRuleStatus.active;
    }
  }
}
