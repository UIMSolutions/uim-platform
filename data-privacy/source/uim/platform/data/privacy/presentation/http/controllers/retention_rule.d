/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.presentation.http.controllers.retention_rule;

// import uim.platform.data.privacy.application.usecases.manage.retention_rules;
// import uim.platform.data.privacy.application.dto;

// import uim.platform.data.privacy.domain.entities.retention_rule;
import uim.platform.data.privacy;

mixin(ShowModule!());

@safe:
class RetentionRuleController : ManageHttpController {
  private ManageRetentionRulesUseCase usecase;

  this(ManageRetentionRulesUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/retention-rules", &handleCreate);
    router.get("/api/v1/retention-rules", &handleList);
    router.get("/api/v1/retention-rules/*", &handleGet);
    router.put("/api/v1/retention-rules/*", &handleUpdate);
    router.delete_("/api/v1/retention-rules/*", &handleDelete);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    CreateRetentionRuleRequest r;
    r.tenantId = tenantId;
    r.name = data.getString("name");
    r.description = data.getString("description");
    r.purpose = data.getString("purpose");
    r.retentionDays = data.getInteger("retentionDays");
    r.legalReference = data.getString("legalReference");
    r.isDefault = data.getBoolean("isDefault");

    auto result = usecase.createRule(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Retention rule created successfully", "Created", 201, responseData);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto purposeParam = req.headers.get("X-Purpose-Filter", "");

    RetentionRule[] items = purposeParam.length > 0
      ? usecase.listRules(tenantId, purposeParam.toProcessingPurpose) : usecase.listRules(tenantId);

    auto list = items.map!(item => item.toJson()).array.toJson;

    auto responseData = Json.emptyObject
      .set("count", list.length)
      .set("resources", list);
    return successResponse("Retention rules retrieved successfully", "Retrieved", 200, responseData);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = RetentionRuleId(precheck.id);

    auto entry = usecase.getRule(tenantId, id);
    if (entry.isNull) {
      return errorResponse("Retention rule not found", 404);
    }
    auto responseData = entry.toJson();
    return successResponse("Retention rule retrieved successfully", "Retrieved", 200, responseData);

  }

  override protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto data = precheck.data;
    UpdateRetentionRuleRequest r;
    r.id = RetentionRuleId(precheck.id);
    r.tenantId = tenantId;
    r.name = data.getString("name");
    r.description = data.getString("description");
    r.retentionDays = data.getInteger("retentionDays");
    r.legalReference = data.getString("legalReference");
    r.status = data.getString("status");

    auto result = usecase.updateRule(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Retention rule updated successfully", "Updated", 200, responseData);
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = RetentionRuleId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid retention rule ID", 400);

    auto result = usecase.deleteRule(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Retention rule deleted successfully", "Deleted", 200, responseData);
  }
}
