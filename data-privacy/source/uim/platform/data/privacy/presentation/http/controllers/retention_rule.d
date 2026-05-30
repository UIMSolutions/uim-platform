/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.presentation.http.controllers.retention_rule;




// import uim.platform.data.privacy.application.usecases.manage.retention_rules;
// import uim.platform.data.privacy.application.dto;
// import uim.platform.data.privacy.domain.types;
// import uim.platform.data.privacy.domain.entities.retention_rule;
import uim.platform.data.privacy;

mixin(ShowModule!());

@safe:
class RetentionRuleController : ManageController {
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
        ScanJobDTO dto;
        dto.tenantId = tenantId;
      CreateRetentionRuleRequest r;
      r.tenantId = tenantId;
      r.name = data.getString("name");
      r.description = data.getString("description");
      r.purpose = data.getString("purpose");
      r.retentionDays = data.getInteger("retentionDays");
      r.legalReference = data.getString("legalReference");
      r.isDefault = data.getBoolean("isDefault");

      auto result = usecase.createRule(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Retention rule created successfully");

        res.writeJsonBody(resp, 201);
      } else
        writeError(res, 400, result.message);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      auto purposeParam = req.headers.get("X-Purpose-Filter", "");

      RetentionRule[] items = purposeParam.length > 0 
        ? usecase.listRules(tenantId, purposeParam.toProcessingPurpose)
        : usecase.listRules(tenantId);

      auto arr = items.map!(e => e.toJson).array.toJson;

      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", items.length)
        .set("message", "Retention rules retrieved successfully");

      res.writeJsonBody(resp, 200);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto id = RetentionRuleId(precheck.id);

      auto entry = usecase.getRule(tenantId, id);
      if (entry.isNull) {
        writeError(res, 404, "Retention rule not found");
        return;
      }
      res.writeJsonBody(entry.toJson, 200);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
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
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Retention rule updated successfully");

        res.writeJsonBody(resp, 200);
      } else
        writeError(res, 400, result.message);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      auto id = RetentionRuleId(precheck.id);

      usecase.deleteRule(tenantId, id);
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

}
