/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.connectivity.presentation.http.controllers.access_rule;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
// // import std.conv : to;

// import uim.platform.connectivity.application.usecases.manage.access_rules;
// import uim.platform.connectivity.application.dto;
// import uim.platform.connectivity.domain.entities.access_rule;
import uim.platform.connectivity;

mixin(ShowModule!());

@safe:
class AccessRuleController : SAPController {
  private ManageAccessRulesUseCase uc;

  this(ManageAccessRulesUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/access-rules", &handleCreate);
    router.get("/api/v1/access-rules", &handleList);
    router.get("/api/v1/access-rules/*", &handleGetById);
    router.put("/api/v1/access-rules/*", &handleUpdate);
    router.delete_("/api/v1/access-rules/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try
    {
      auto j = req.json;
      auto r = CreateAccessRuleRequest();
      r.connectorId = j.getString("connectorId");
      r.tenantId = req.headers.get("X-Tenant-Id", "");
      r.description = j.getString("description");
      r.protocol = j.getString("protocol");
      r.virtualHost = j.getString("virtualHost");
      r.virtualPort = jsonUshort(j, "virtualPort");
      r.urlPathPrefix = j.getString("urlPathPrefix");
      r.policy = j.getString("policy");
      r.principalPropagation = j.getBoolean("principalPropagation");

      auto result = uc.createRule(r);
      if (result.success)
      {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        res.writeJsonBody(resp, 201);
      }
      else
      {
        writeError(res, 400, result.error);
      }
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try
    {
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      auto rules = uc.listByTenant(tenantId);

      auto arr = Json.emptyArray;
      foreach (ref r; rules)
        arr ~= serializeRule(r);

      auto resp = Json.emptyObject;
      resp["items"] = arr;
      resp["totalCount"] = Json(cast(long) rules.length);
      res.writeJsonBody(resp, 200);
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGetById(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try
    {
      auto id = extractIdFromPath(req.requestURI);
      auto rule = uc.getRule(id);
      if (rule.id.length == 0)
      {
        writeError(res, 404, "Access rule not found");
        return;
      }
      res.writeJsonBody(serializeRule(rule), 200);
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try
    {
      auto id = extractIdFromPath(req.requestURI);
      auto j = req.json;
      auto r = UpdateAccessRuleRequest();
      r.description = j.getString("description");
      r.urlPathPrefix = j.getString("urlPathPrefix");
      r.policy = j.getString("policy");
      r.principalPropagation = j.getBoolean("principalPropagation");

      auto result = uc.updateRule(id, r);
      if (result.success)
      {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        res.writeJsonBody(resp, 200);
      }
      else
      {
        writeError(res, result.error == "Access rule not found" ? 404 : 400, result.error);
      }
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try
    {
      auto id = extractIdFromPath(req.requestURI);
      auto result = uc.deleteRule(id);
      if (result.success)
      {
        auto resp = Json.emptyObject;
        resp["deleted"] = Json(true);
        res.writeJsonBody(resp, 200);
      }
      else
      {
        writeError(res, 404, result.error);
      }
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  private static Json serializeRule(ref const AccessRule r) {
    auto j = Json.emptyObject;
    j["id"] = Json(r.id);
    j["connectorId"] = Json(r.connectorId);
    j["tenantId"] = Json(r.tenantId);
    j["description"] = Json(r.description);
    j["protocol"] = Json(r.protocol.to!string);
    j["virtualHost"] = Json(r.virtualHost);
    j["virtualPort"] = Json(cast(long) r.virtualPort);
    j["urlPathPrefix"] = Json(r.urlPathPrefix);
    j["policy"] = Json(r.policy.to!string);
    j["principalPropagation"] = Json(r.principalPropagation);
    j["createdAt"] = Json(r.createdAt);
    j["updatedAt"] = Json(r.updatedAt);
    return j;
  }
}
