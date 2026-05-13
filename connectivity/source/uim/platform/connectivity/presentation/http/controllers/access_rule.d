/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.connectivity.presentation.http.controllers.access_rule;




// 

// import uim.platform.connectivity.application.usecases.manage.access_rules;
// import uim.platform.connectivity.application.dto;
// import uim.platform.connectivity.domain.entities.access_rule;
import uim.platform.connectivity;

mixin(ShowModule!());

@safe:
class AccessRuleController : PlatformController {
  private ManageAccessRulesUseCase usecase;

  this(ManageAccessRulesUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/access-rules", &handleCreate);
    router.get("/api/v1/access-rules", &handleList);
    router.get("/api/v1/access-rules/*", &handleGet);
    router.put("/api/v1/access-rules/*", &handleUpdate);
    router.delete_("/api/v1/access-rules/*", &handleDelete);
  }

  protected void handleCreate((scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;

      auto j = req.json;
      auto r = CreateAccessRuleRequest();
      r.connectorId = j.getString("connectorId");
      r.tenantId = tenantId;
      r.description = j.getString("description");
      r.protocol = j.getString("protocol");
      r.virtualHost = j.getString("virtualHost");
      r.virtualPort = getUshort(j, "virtualPort");
      r.urlPathPrefix = j.getString("urlPathPrefix");
      r.policy = j.getString("policy");
      r.principalPropagation = j.getBoolean("principalPropagation");

      auto result = usecase.createAccessRule(r);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Access rule created");

        res.writeJsonBody(resp, 201);
      } else {
        writeError(res, 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleGetList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;

      auto rules = usecase.listAccessRules(tenantId);
      auto arr = rules.map!(r => r.toJson).array.toJson;

      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", Json(rules.length))
        .set("message", "Access rules retrieved successfully");

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto id = RuleId(extractIdFromPath(req.requestURI));
      
      auto rule = usecase.getAccessRule(tenantId, id);
      if (rule.isNull) {
        writeError(res, 404, "Access rule not found");
        return;
      }
      res.writeJsonBody(rule.toJson, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto id = RuleId(extractIdFromPath(req.requestURI));
      auto j = req.json;
      auto r = UpdateAccessRuleRequest();
      r.tenantId = tenantId;
      r.description = j.getString("description");
      r.urlPathPrefix = j.getString("urlPathPrefix");
      r.policy = j.getString("policy");
      r.principalPropagation = j.getBoolean("principalPropagation");

      auto result = usecase.updateAccessRule(r);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Access rule updated");

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, result.error == "Access rule not found" ? 404 : 400, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleGetDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = RuleId(extractIdFromPath(req.requestURI));
      auto result = usecase.deleteAccessRule(tenantId, id);
      if (result.success) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Access rule deleted");

        res.writeJsonBody(resp, 200);
      } else {
        writeError(res, 404, result.error);
      }
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
