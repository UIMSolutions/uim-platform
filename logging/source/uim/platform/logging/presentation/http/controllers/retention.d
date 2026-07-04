/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logging.presentation.http.controllers.retention;
// import uim.platform.logging.application.usecases.manage.retention_policies;


import uim.platform.logging;

mixin(ShowModule!());

@safe:

class RetentionController : ManageHttpController {
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

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
        CreateRetentionPolicyRequest r;
    r.tenantId = tenantId;
    r.name = data.getString("name");
    r.description = data.getString("description");
    r.dataType = data.getString("dataType");
    r.retentionDays = data.getInteger("retentionDays");
    r.maxSizeGB = data.getDouble("maxSizeGB");
    r.isDefault = data.getBoolean("isDefault");
    r.createdBy = UserId(data.getString("createdBy"));

    auto result = usecase.createRetentionPolicy(r);
    if (result.hasError)
      return errorResponse(result.message, 400);
    auto response = Json.emptyObject
      .set("id", RetentionPolicyId(result.id));

    return successResponse("Retention policy created successfully", "Created", 201, response);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
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
      .set("totalCount", policies.length);

    return successResponse("Retention policies retrieved successfully", "Retrieved", 200, resp);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto policyId = RetentionPolicyId(precheck.id);
    auto policy = usecase.getRetentionPolicy(tenantId, policyId);
    if (policy.isNull)
      return errorResponse("Retention policy not found", "Not Found", 404);

    auto response = Json.emptyObject
      .set("id", policy.id)
      .set("name", policy.name)
      .set("description", policy.description)
      .set("retentionDays", policy.retentionDays)
      .set("maxSizeGB", policy.maxSizeGB)
      .set("isDefault", policy.isDefault)
      .set("isActive", policy.isActive);

    return successResponse("Retention policy retrieved successfully", "Retrieved", 200, response);
  }

  override protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto policyId = RetentionPolicyId(precheck.id);
    auto data = precheck.data;
    UpdateRetentionPolicyRequest r;
    r.policyId = policyId;
    r.description = data.getString("description");
    r.retentionDays = data.getInteger("retentionDays");
    r.maxSizeGB = data.getDouble("maxSizeGB");
    r.isDefault = data.getBoolean("isDefault");
    r.isActive = data.getBoolean("isActive", true);
    r.tenantId = tenantId;

    auto result = usecase.updateRetentionPolicy(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto response = Json.emptyObject.set("id", result.id);

    return successResponse("Retention policy updated successfully", "Updated", 200, response);
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto policyId = RetentionPolicyId(precheck.id);
    auto result = usecase.deleteRetentionPolicy(tenantId, policyId);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto response = Json.emptyObject
      .set("id", policyId);

    return successResponse("Retention policy deleted successfully", "Deleted", 200, response);
  }
}
