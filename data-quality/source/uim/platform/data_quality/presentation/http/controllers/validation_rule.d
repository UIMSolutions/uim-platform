/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data_quality.presentation.http.controllers.validation_rule;





// import uim.platform.data_quality.application.usecases.manage.validation_rules;
// import uim.platform.data_quality.application.dto;
// import uim.platform.data_quality.domain.types;
// import uim.platform.data_quality.domain.entities.validation_rule;
import uim.platform.data_quality;

mixin(ShowModule!());

@safe:
class ValidationRuleController : ManageController {
  private ManageValidationRulesUseCase usecase;

  this(ManageValidationRulesUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/validation-rules", &handleCreate);
    router.get("/api/v1/validation-rules", &handleList);
    router.get("/api/v1/validation-rules/*", &handleGet);
    router.put("/api/v1/validation-rules/*", &handleUpdate);
    router.delete_("/api/v1/validation-rules/*", &handleDelete);
  }

  override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
      auto r = CreateValidationRuleRequest();
      r.tenantId = tenantId;
      r.name = data.getString("name");
      r.description = data.getString("description");
      r.datasetPattern = data.getString("datasetPattern");
      r.fieldName = data.getString("fieldName");
      r.ruleType = parseRuleType(data.getString("ruleType"));
      r.severity = data.getString("severity").to;
      r.pattern = data.getString("pattern");
      r.minValue = data.getString("minValue");
      r.maxValue = data.getString("maxValue");
      r.allowedValues = data.getStrings("allowedValues");
      r.expression = data.getString("expression");
      r.referenceDataset = data.getString("referenceDataset");
      r.crossFieldName = data.getString("crossFieldName");
      r.category = data.getString("category");
      r.priority = data.getInteger("priority");

      auto result = usecase.create(r);
      if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Validation rule created successfully", 201, responseData);
  }

  override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      auto rules = usecase.listByTenant(tenantId);
      auto list = rules.map!(item => item.toJson()).array.toJson;

        auto responseData = Json.emptyObject
            .set("count", list.length)
            .set("resources", list);
        return successResponse("", 0, responseData);
  }

  override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      auto id = precheck.id;
      auto rule = usecase.getById(tenantId, id);
      if (rule.isNull) {
        writeError(res, 404, "Validation rule not found");
        return;
      }
      res.writeJsonBody(rule.toJson, 200);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      auto data = precheck.data;
      auto r = UpdateValidationRuleRequest();
      r.id = precheck.id;
      r.tenantId = tenantId;
      r.name = data.getString("name");
      r.description = data.getString("description");
      r.datasetPattern = data.getString("datasetPattern");
      r.fieldName = data.getString("fieldName");
      r.ruleType = parseRuleType(data.getString("ruleType"));
      r.severity = data.getString("severity").toRuleSeverity;
      r.status = parseRuleStatus(data.getString("status"));
      r.pattern = data.getString("pattern");
      r.minValue = data.getString("minValue");
      r.maxValue = data.getString("maxValue");
      r.allowedValues = data.getStrings("allowedValues");
      r.expression = data.getString("expression");
      r.referenceDataset = data.getString("referenceDataset");
      r.crossFieldName = data.getString("crossFieldName");
      r.category = data.getString("category");
      r.priority = data.getInteger("priority");

      auto result = usecase.update(r);
      if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Validation rule updated successfully", 200, responseData);
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      auto id = precheck.id;
      auto tenantId = precheck.tenantId;
      auto result = usecase.deleteValidationRule(tenantId, id);
     if (result.hasError)
            return errorResponse(result.message, 400);

        auto responseData = Json.emptyObject.set("id", result.id);
        return successResponse("Validation rule deleted successfully", 200, responseData);
  }
