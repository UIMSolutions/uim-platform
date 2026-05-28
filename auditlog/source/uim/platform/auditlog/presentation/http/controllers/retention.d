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

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError) 
      return precheck; // Return error response from super if tenant ID is missing or invalid

    auto tenantId = precheck.tenantId;
    auto policies = useCase.listPolicies(tenantId);
    auto arr = policies.map!(p => p.toJson).array.toJson;

    return successResponse("Retention policies retrieved successfully", 200,
      Json.emptyObject
        .set("items", arr)
        .set("totalCount", Json(policies.length)));
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError) 
      return precheck;

    auto tenantId = precheck.tenantId;
    auto data = precheck.data;

    CreateRetentionPolicyRequest policyRequest;
    policyRequest.tenantId = tenantId;
    policyRequest.name = data.getString("name");
    policyRequest.description = data.getString("description");
    policyRequest.retentionDays = data.getInteger("retentionDays");
    policyRequest.isDefault = data.getBoolean("isDefault");
    policyRequest.categories = data.getArray("categories")
      .map!(c => c.toString.to!AuditCategory).array;

    auto result = useCase.createPolicy(policyRequest);
    if (result.hasError()) {
      return errorResponse(result.message, 400);
    }
    return successResponse("Retention policy created", 201, 
      Json.emptyObject.set("id", result.id).set("status", "created"));
  }

  override protected Json getHandler(HTTPServerRequest req) {
    RetentionPolicyId policyId = RetentionPolicyId(precheck.id);
    auto precheck = super.getHandler(req);
    if (precheck.hasError) 
      return precheck;

    auto tenantId = precheck.tenantId;

    auto policy = useCase.getPolicy(tenantId, policyId);
    if (policy.isNull) {
      return errorResponse("Retention policy not found", 404);
    }
    return successResponse("Retention policy retrieved successfully", 200, policy.toJson);
  }

  override protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError) 
      return precheck;

    auto tenantId = precheck.tenantId;
    auto data = precheck.data;

    UpdateRetentionPolicyRequest policyRequest;
    policyRequest.retentionPolicyId = RetentionPolicyId(precheck.id);
    policyRequest.tenantId = tenantId;
    policyRequest.name = data.getString("name");
    policyRequest.description = data.getString("description");
    policyRequest.retentionDays = data.getInteger("retentionDays");
    policyRequest.categories = data.getArray("categories")
      .map!(c => c.toString.to!AuditCategory).array;

    switch (data.getString("status", "")) {
        case "inactive": policyRequest.status = RetentionStatus.inactive; break;
        case "expired":  policyRequest.status = RetentionStatus.expired;  break;
        default:         policyRequest.status = RetentionStatus.active;   break;
    }

    auto result = useCase.updatePolicy(policyRequest);
    if (result.hasError()) {
      return errorResponse(result.message, 400);
    }
    return successResponse("Retention policy updated", 200, 
      Json.emptyObject.set("status", "updated"));
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError) return precheck;

    useCase.deletePolicy(precheck.tenantId, RetentionPolicyId(precheck.id);
    return successResponse("Retention policy deleted successfully", 200, 
      Json.emptyObject.set("status", "deleted"));
  }
}
