/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.directory.presentation.http.controllers.api_client;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
import uim.platform.identity.directory.application.usecases.manage.api_clients;
import uim.platform.identity.directory.application.dto;
import uim.platform.identity.directory.domain.entities.api_client;
import uim.platform.identity_authentication.presentation.http.json_utils;

/// HTTP controller for API client management.
class ApiClientController {
  private ManageApiClientsUseCase useCase;

  this(ManageApiClientsUseCase useCase)
  {
    this.useCase = useCase;
  }

  override void registerRoutes(URLRouter router)
  {
    router.post("/api/v1/api-clients", &handleCreate);
    router.get("/api/v1/api-clients", &handleList);
    router.get("/api/v1/api-clients/*", &handleGet);
    router.delete_("/api/v1/api-clients/*", &handleRevoke);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto j = req.json;
      auto createReq = CreateApiClientRequest(req.headers.get("X-Tenant-Id", ""),
          j.getString("name"), j.getString("description"), jsonStrArray(j,
            "scopes"), cast(long) jsonLong(j, "expiresAt"),);

      auto result = useCase.createClient(createReq);
      auto response = Json.emptyObject;

      if (result.isSuccess())
      {
        response["clientId"] = Json(result.clientId);
        response["clientSecret"] = Json(result.clientSecret);
        res.writeJsonBody(response, 201);
      }
      else
      {
        response["error"] = Json(result.error);
        res.writeJsonBody(response, 400);
      }
    }
    catch (Exception e)
    {
      auto errRes = Json.emptyObject;
      errRes["error"] = Json("Internal server error");
      res.writeJsonBody(errRes, 500);
    }
  }

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      auto clients = useCase.listClients(tenantId);
      auto response = Json.emptyObject;
      response["totalResults"] = Json(cast(long) clients.length);

      // Serialize without clientSecret
      auto arr = Json.emptyArray;
      foreach (c; clients)
      {
        auto j = toJsonValue(c);
        j.remove("clientSecret");
        arr ~= j;
      }
      response["resources"] = arr;
      res.writeJsonBody(response, 200);
    }
    catch (Exception e)
    {
      auto errRes = Json.emptyObject;
      errRes["error"] = Json("Internal server error");
      res.writeJsonBody(errRes, 500);
    }
  }

  private void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto clientId = extractIdFromPath(req.requestURI);
      auto client = useCase.getClient(clientId);
      if (client == ApiClient.init)
      {
        auto errRes = Json.emptyObject;
        errRes["error"] = Json("API client not found");
        res.writeJsonBody(errRes, 404);
        return;
      }
      auto response = toJsonValue(client);
      response.remove("clientSecret");
      res.writeJsonBody(response, 200);
    }
    catch (Exception e)
    {
      auto errRes = Json.emptyObject;
      errRes["error"] = Json("Internal server error");
      res.writeJsonBody(errRes, 500);
    }
  }

  private void handleRevoke(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto clientId = extractIdFromPath(req.requestURI);
      auto error = useCase.revokeClient(clientId);
      if (error.length > 0)
      {
        auto errRes = Json.emptyObject;
        errRes["error"] = Json(error);
        res.writeJsonBody(errRes, 404);
      }
      else
      {
        auto resp = Json.emptyObject;
        resp["status"] = Json("revoked");
        res.writeJsonBody(resp, 200);
      }
    }
    catch (Exception e)
    {
      auto errRes = Json.emptyObject;
      errRes["error"] = Json("Internal server error");
      res.writeJsonBody(errRes, 500);
    }
  }
}
