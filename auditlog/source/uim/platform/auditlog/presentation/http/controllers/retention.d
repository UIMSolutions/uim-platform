/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.auditlog.presentation.http.controllers.retention;

// 
// 
// import uim.platform.auditlog.application.usecases.manage.retention;
// import uim.platform.auditlog.application.dto;
// import uim.platform.auditlog.domain.types;
// import uim.platform.auditlog.domain.entities.retention_policy;

import uim.platform.auditlog;

mixin(ShowModule!());

@safe:
class RetentionController : ManageController {
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

  override protected Json listHandler(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    auto tenantId = req.getTenantId;

    auto policies = useCase.listPolicies(tenantId);
    auto arr = policies.map!(p => p.toJson).array.toJson;

    return Json.emptyObject
      .set("statusCode", 200)
      .set("items", arr)
      .set("totalCount", Json(policies.length));
  }

  override protected Json createHandler(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    auto json = req.json;
    auto policyRequest = CreateRetentionPolicyRequest();
    policyRequest.tenantId = req.getTenantId;
    policyRequest.name = json.getString("name");
    policyRequest.description = json.getString("description");
    policyRequest.retentionDays = json.getInteger("retentionDays");
    policyRequest.isDefault = json.getBoolean("isDefault");
    policyRequest.categories = json.getArray("categories").map!(c => c.toString.to!AuditCategory).array;

    auto result = useCase.createPolicy(policyRequest);
    if (result.isFailure()) {
      return Json.emptyObject
        .set("error", result.error)
        .set("statusCode", 400);
    }
    return Json.emptyObject
      .set("id", result.id)
      .set("status", "created")
      .set("statusCode", 201);
  }

  override protected Json getHandler(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    RetentionPolicyId policyId = RetentionPolicyId(extractIdFromPath(req.requestURI));
    auto tenantId = req.getTenantId;

    auto policy = useCase.getPolicy(tenantId, policyId);
    if (policy.isNull) {
      return Json.emptyObject
        .set("error", "Retention policy not found")
        .set("statusCode", 404);
    }
    return policy.toJson
      .set("statusCode", 200);
  }

  override protected Json updateHandler(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    auto json = req.json;
    auto policyRequest = UpdateRetentionPolicyRequest();
    policyRequest.retentionPolicyId = RetentionPolicyId(extractIdFromPath(req.requestURI));
    policyRequest.tenantId = req.getTenantId;
    policyRequest.name = json.getString("name");
    policyRequest.description = json.getString("description");
    policyRequest.retentionDays = json.getInteger("retentionDays");
    policyRequest.categories = json.getArray("categories").map!(c => c.toString.to!AuditCategory).array;

    auto statusStr = json.getString("status");
    if (statusStr == "inactive")
      policyRequest.status = RetentionStatus.inactive;
    else if (statusStr == "expired")
      policyRequest.status = RetentionStatus.expired;
    else
      policyRequest.status = RetentionStatus.active;

    auto result = useCase.updatePolicy(policyRequest);
    if (result.isFailure()) {
      return Json.emptyObject
        .set("error", result.error)
        .set("statusCode", 400);
    }
    return Json.emptyObject
      .set("status", "updated")
      .set("statusCode", 200);
  }

  override protected Json deleteHandler(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    RetentionPolicyId policyId = RetentionPolicyId(extractIdFromPath(req.requestURI));
    auto tenantId = req.getTenantId;

    useCase.deletePolicy(tenantId, policyId);
    return Json.emptyObject
      .set("status", "deleted")
      .set("message", "Retention policy deleted successfully")
      .set("statusCode", 200);
  }

}
