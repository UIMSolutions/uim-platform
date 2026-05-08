/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logging.presentation.http.controllers.retention;

// import uim.platform.logging.application.usecases.manage.retention_policies;
// import uim.platform.logging.application.dto;

import uim.platform.logging;

mixin(ShowModule!());

@safe:

class RetentionController : PlatformController {
  private ManageRetentionPoliciesUseCase usecase;

  this(ManageRetentionPoliciesUseCase usecase) {
    this.usecase = usecase;
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
      auto tenantId = req.getTenantId;
      auto j = req.json;
      CreateRetentionPolicyRequest r;
      r.tenantId = tenantId;
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.dataType = j.getString("dataType");
      r.retentionDays = j.getInteger("retentionDays");
      r.maxSizeGB = getDouble(j, "maxSizeGB");
      r.isDefault = j.getBoolean("isDefault");
      r.createdBy = UserId(j.getString("createdBy"));

      auto result = usecase.createRetentionPolicy(r);
      if (result.success) {
        auto response = Json.emptyObject
          .set("id", RetentionPolicyId(result.id))
          .set("message", "Retention policy created");

        res.writeJsonBody(response, 201);
      } else {
        writeError(res, 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto policies = usecase.listRetentionPolicies(tenantId);

      auto jarr = Json.emptyArray;
      foreach (p; policies) {
        jarr ~= Json.emptyObject
          .set("id", p.id)
          .set("name", p.name)
          .set("retentionDays", p.retentionDays)
          .set("maxSizeGB", p.maxSizeGB)
          .set("isDefault", p.isDefault)
          .set("isActive", p.isActive);
      }

      auto resp = Json.emptyObject
        .set("items", jarr)
        .set("totalCount", policies.length)
        .set("message", "Retention policies retrieved successfully");

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      TenantId tenantId = req.getTenantId;
      auto policyId = RetentionPolicyId(extractIdFromPath(req.requestURI.to!string));
      auto policy = usecase.getRetentionPolicy(tenantId, policyId);
      if (policy.isNull) {
        writeError(res, 404, "Retention policy not found");
        return;
      }

      auto response = Json.emptyObject
        .set("id", policy.id)
        .set("name", policy.name)
        .set("description", policy.description)
        .set("retentionDays", policy.retentionDays)
        .set("maxSizeGB", policy.maxSizeGB)
        .set("isDefault", policy.isDefault)
        .set("isActive", policy.isActive);

      res.writeJsonBody(response, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto policyId = RetentionPolicyId(extractIdFromPath(req.requestURI.to!string));
      auto j = req.json;

      UpdateRetentionPolicyRequest r;
      r.policyId = policyId;
      r.description = j.getString("description");
      r.retentionDays = j.getInteger("retentionDays");
      r.maxSizeGB = getDouble(j, "maxSizeGB");
      r.isDefault = j.getBoolean("isDefault");
      r.isActive = j.getBoolean("isActive", true);
      r.tenantId = tenantId;

      auto result = usecase.updateRetentionPolicy(r);
      if (result.success) {
        auto response = Json.emptyObject
          .set("id", result.id)
          .set("message", "Retention policy updated");

        res.writeJsonBody(response, 200);
      } else {
        writeError(res, 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      TenantId tenantId = req.getTenantId;
      auto policyId = RetentionPolicyId(extractIdFromPath(req.requestURI.to!string));
      usecase.deleteRetentionPolicy(tenantId, policyId);

      auto response = Json.emptyObject
        .set("id", policyId)
        .set("message", "Retention policy deleted");

      res.writeJsonBody(response, 204);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
