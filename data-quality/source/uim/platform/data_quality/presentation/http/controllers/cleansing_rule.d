/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data_quality.presentation.http.controllers.cleansing_rule;




// import uim.platform.data_quality.application.usecases.manage.cleansing_rules;
// import uim.platform.data_quality.application.dto;
// import uim.platform.data_quality.domain.types;
// import uim.platform.data_quality.domain.entities.cleansing_rule;
import uim.platform.data_quality;

mixin(ShowModule!());

@safe:
class CleansingRuleController : ManageController {
  private ManageCleansingRulesUseCase usecase;

  this(ManageCleansingRulesUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/cleansing-rules", &handleCreate);
    router.get("/api/v1/cleansing-rules", &handleList);
    router.get("/api/v1/cleansing-rules/*", &handleGet);
    router.put("/api/v1/cleansing-rules/*", &handleUpdate);
    router.delete_("/api/v1/cleansing-rules/*", &handleDelete);
  }

  override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
      auto r = CreateCleansingRuleRequest();
      r.tenantId = tenantId;
      r.name = data.getString("name");
      r.description = data.getString("description");
      r.datasetPattern = data.getString("datasetPattern");
      r.fieldName = data.getString("fieldName");
      r.action = data.getString("action");
      r.findPattern = data.getString("findPattern");
      r.replaceWith = data.getString("replaceWith");
      r.defaultValue = data.getString("defaultValue");
      r.lookupDataset = data.getString("lookupDataset");
      r.lookupField = data.getString("lookupField");
      r.trimWhitespace = data.getBoolean("trimWhitespace");
      r.normalizeCase = data.getBoolean("normalizeCase");
      r.caseMode = data.getString("caseMode");
      r.removeDiacritics = data.getBoolean("removeDiacritics");
      r.category = data.getString("category");
      r.priority = data.getInteger("priority");

      auto result = usecase.createCleansingRule(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Cleansing rule created successfully");

        res.writeJsonBody(resp, 201);
      } else {
        writeError(res, 400, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      auto rules = usecase.listCleansingRules(tenantId);
      auto arr = rules.map!(r => r.toJson).array.toJson;

      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", Json(rules.length))
        .set("message", "Cleansing rules retrieved successfully");

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto id = precheck.id;
      auto rule = usecase.getCleansingRule(tenantId, id);
      if (rule.isNull) {
        writeError(res, 404, "Cleansing rule not found");
        return;
      }
      res.writeJsonBody(rule.toJson, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      auto r = UpdateCleansingRuleRequest();
      r.id = precheck.id;
      r.tenantId = tenantId;
      r.name = data.getString("name");
      r.description = data.getString("description");
      r.datasetPattern = data.getString("datasetPattern");
      r.fieldName = data.getString("fieldName");
      r.action = data.getString("action");
      r.status = data.getString("status");
      r.findPattern = data.getString("findPattern");
      r.replaceWith = data.getString("replaceWith");
      r.defaultValue = data.getString("defaultValue");
      r.lookupDataset = data.getString("lookupDataset");
      r.lookupField = data.getString("lookupField");
      r.trimWhitespace = data.getBoolean("trimWhitespace");
      r.normalizeCase = data.getBoolean("normalizeCase");
      r.caseMode = data.getString("caseMode");
      r.removeDiacritics = data.getBoolean("removeDiacritics");
      r.category = data.getString("category");
      r.priority = data.getInteger("priority");

      auto result = usecase.update(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Cleansing rule updated successfully");

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 400, result.message);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      auto id = precheck.id;

      auto result = usecase.deleteCleansingRule(tenantId, id);
      if (result.isSuccess())
        res.writeJsonBody(Json.emptyObject, 204);
      else
        writeError(res, 404, result.message);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

}
