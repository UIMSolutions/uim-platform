/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.authorization_trust.presentation.http.controllers.oauth_client;

import uim.platform.authorization_trust;

mixin(ShowModule!());

@safe:

class OAuthClientController : ManageController {
  private ManageOAuthClientsUseCase usecase;

  this(ManageOAuthClientsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/oauth/clients", &handleCreate);
    router.get("/api/v1/oauth/clients", &handleList);
    router.get("/api/v1/oauth/clients/*", &handleGet);
    router.put("/api/v1/oauth/clients/*", &handleUpdate);
    router.delete_("/api/v1/oauth/clients/*", &handleDelete);
  }

  // POST /api/v1/oauth/clients
  override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto j = req.json;

      CreateOAuthClientRequest r;
      r.tenantId = tenantId;
      r.clientId = j.getString("clientId");
      r.clientSecret = j.getString("clientSecret");
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.clientType = j.getString("clientType");
      r.appId = j.getString("appId");

      auto gtArr = j["grantTypes"];
      if (gtArr.type == Json.Type.array)
        foreach (v; gtArr.byValue)
          r.grantTypes ~= v.get!string;

      auto scArr = j["scopes"];
      if (scArr.type == Json.Type.array)
        foreach (v; scArr.byValue)
          r.scopes ~= v.get!string;

      auto ruArr = j["redirectUris"];
      if (ruArr.type == Json.Type.array)
        foreach (v; ruArr.byValue)
          r.redirectUris ~= v.get!string;

      auto result = usecase.createOAuthClient(r);
      if (result.success)
        res.writeJsonBody(
          Json.emptyObject
            .set("id", result.id)
            .set("message", "OAuth client created successfully"), 201);
      else
        writeError(res, 400, result.message);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  // GET /api/v1/oauth/clients
  protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto appId = AppId(req.params.get("appId", ""));
      auto clients = appId.length > 0
        ? usecase.listOAuthClients(tenantId, appId) : usecase.listOAuthClients(
          tenantId);
      auto jarr = clients.map!(c => c.toJson()).array;

      res.writeJsonBody(
        Json.emptyObject
          .set("items", jarr)
          .set("totalCount", clients.length), 200)
        .set("message", "OAuth clients retrieved successfully");

    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  // GET /api/v1/oauth/clients/{id}
  override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = OAuthClientId(extractIdFromPath(req));

      auto c = usecase.getOAuthClient(tenantId, id);
      if (c.isNull) {
        writeError(res, 404, "OAuth client not found");
        return;
      }
      res.writeJsonBody(
        Json.emptyObject
          .set("id", c.id)
          .set("message", "OAuth client retrieved successfully")
          .set("client", clientToJson(c)), 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  // PUT /api/v1/oauth/clients/{id}
  override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = OAuthClientId(extractIdFromPath(req));

      auto j = req.json;
      UpdateOAuthClientRequest r;
      r.id = id;
      r.tenantId = tenantId;
      r.name = j.getString("name");
      r.description = j.getString("description");

      auto gtArr = j["grantTypes"];
      if (gtArr.type == Json.Type.array)
        foreach (v; gtArr.byValue)
          r.grantTypes ~= v.get!string;

      auto scArr = j["scopes"];
      if (scArr.type == Json.Type.array)
        foreach (v; scArr.byValue)
          r.scopes ~= v.get!string;

      auto ruArr = j["redirectUris"];
      if (ruArr.type == Json.Type.array)
        foreach (v; ruArr.byValue)
          r.redirectUris ~= v.get!string;

      auto result = usecase.update(r);
      if (result.success)
        res.writeJsonBody(
          Json.emptyObject
            .set("id", result.id)
            .set("message", "OAuth client updated successfully"), 200);
      else
        writeError(res, result.message == "OAuth client not found" ? 404 : 400, result.message);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  // DELETE /api/v1/oauth/clients/{id}
  override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = OAuthClientId(extractIdFromPath(req));

      auto result = usecase.deleteOAuthClient(tenantId, id);
      if (result.success)
        res.writeJsonBody(
          Json.emptyObject
            .set("id", id)
            .set("message", "OAuth client deleted successfully"), 200);
      else
        writeError(res, 404, result.message);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

}
