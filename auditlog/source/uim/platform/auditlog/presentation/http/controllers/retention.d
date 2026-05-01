/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.auditlog.presentation.http.controllers.retention;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
// // import std.conv : to;
// 
// import uim.platform.auditlog.application.usecases.manage.retention;
// import uim.platform.auditlog.application.dto;
// import uim.platform.auditlog.domain.types;
// import uim.platform.auditlog.domain.entities.retention_policy;

import uim.platform.auditlog;

mixin(ShowModule!());

@safe:
class RetentionController : PlatformController {
  private ManageRetentionUseCase useCase;

  this(ManageRetentionUseCase useCase) {
    this.useCase = useCase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/retention", &handleCreate);
    router.get("/api/v1/retention", &handleList);
    router.get("/api/v1/retention/*", &handleGet);
    router.put("/api/v1/retention/*", &handleUpdate);
    router.delete_("/api/v1/retention/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto json = req.json;
      auto policyRequest = CreateRetentionPolicyRequest();
      policyRequest.tenantId = req.getTenantId;
      policyRequest.name = json.getString("name");
      policyRequest.description = json.getString("description");
      policyRequest.retentionDays = json.getInteger("retentionDays");
      policyRequest.isDefault = json.getBoolean("isDefault");
      policyRequest.categories = parseCategoryArray(json);

      auto result = useCase.createPolicy(policyRequest);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("id", Json(result.id));
        res.writeJsonBody(resp, 201);
      } else {
        writeError(res, 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      TenantId tenantId = req.getTenantId;
      auto policies = useCase.listPolicies(tenantId);
      auto arr = policies.map!(p => serializePolicy(p)).array;

      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", Json(policies.length));
        
      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      RetentionPolicyId policyId = extractIdFromPath(req.requestURI);
      TenantId tenantId = req.getTenantId;
      if (!useCase.existsPolicy(tenantId, policyId)) {
        writeError(res, 404, "Retention policy not found");
        return;
      }
      auto policy = useCase.getPolicy(tenantId, policyId);
      res.writeJsonBody(serializePolicy(policy), 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto json = req.json;
      auto policyRequest = UpdateRetentionPolicyRequest();
      policyRequest.id = extractIdFromPath(req.requestURI);
      policyRequest.tenantId = req.getTenantId;
      policyRequest.name = json.getString("name");
      policyRequest.description = json.getString("description");
      policyRequest.retentionDays = json.getInteger("retentionDays");
      policyRequest.categories = parseCategoryArray(json);

      auto statusStr = json.getString("status");
      if (statusStr == "inactive")
        policyRequest.status = RetentionStatus.inactive;
      else if (statusStr == "expired")
        policyRequest.status = RetentionStatus.expired;
      else
        policyRequest.status = RetentionStatus.active;

      auto result = useCase.updatePolicy(policyRequest);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("status", "updated");
        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 404, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      RetentionPolicyId policyId = extractIdFromPath(req.requestURI);
      TenantId tenantId = req.getTenantId;
      useCase.deletePolicy(tenantId, policyId);
      auto resp = Json.emptyObject
        .set("status", "deleted");
      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private static Json serializePolicy(const RetentionPolicy policy) {
    auto j = Json.emptyObject
      .set("id", policy.id)
      .set("tenantId", policy.tenantId)
      .set("name", policy.name)
      .set("description", policy.description)
      .set("retentionDays", policy.retentionDays)
      .set("status", policy.status.to!string)
      .set("isDefault", policy.isDefault)
      .set("createdAt", policy.createdAt)
      .set("updatedAt", policy.updatedAt);

    if (policy.categories.length > 0) {
      auto cats = policy.categories.map!(cat => categoryToString(cat)).array.toJson;
      j["categories"] = cats;
    }
    return j;
  }

  private static AuditCategory[] parseCategoryArray(Json j) {
    auto cats = getStringArray(j, "categories");
    return cats.map!(c => toAuditCategory(c)).array;
  }



  private static string categoryToString(AuditCategory c) {
    final switch (c) {
    case AuditCategory.securityEvents:
      return "audit.security-events";
    case AuditCategory.configuration:
      return "audit.configuration";
    case AuditCategory.dataAccess:
      return "audit.data-access";
    case AuditCategory.dataModification:
      return "audit.data-modification";
    }
  }
}
