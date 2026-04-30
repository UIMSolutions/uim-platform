/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.integration.automation.presentation.http.controllers.destination;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
// import std.conv : to;

import uim.platform.integration.automation.application.usecases.manage.destinations;
import uim.platform.integration.automation.application.dto;
import uim.platform.integration.automation.domain.types;
import uim.platform.integration.automation.domain.entities.destination;
import uim.platform.integration.automation.presentation.http.json_utils;
import uim.platform.integration.automation.presentation.http.scenario_controller : parseSystemType;

class DestinationController : PlatformController {
  private ManageDestinationsUseCase useCase;

  this(ManageDestinationsUseCase useCase) {
    this.useCase = useCase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    
    router.post("/api/v1/destinations", &handleCreate);
    router.get("/api/v1/destinations", &handleList);
    router.get("/api/v1/destinations/*", &handleGetById);
    router.put("/api/v1/destinations/*", &handleUpdate);
    router.delete_("/api/v1/destinations/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      auto r = CreateDestinationRequest();
      r.tenantId = req.getTenantId;
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.systemId = j.getString("systemId");
      r.destinationType = parseDestinationType(j.getString("destinationType"));
      r.url = j.getString("url");
      r.authenticationType = parseAuthenticationType(j.getString("authenticationType"));
      r.proxyType = parseProxyType(j.getString("proxyType"));
      r.cloudConnectorLocationId = j.getString("cloudConnectorLocationId");
      r.user = j.getString("user");
      r.tokenServiceUrl = j.getString("tokenServiceUrl");
      r.tokenServiceUser = j.getString("tokenServiceUser");
      r.audience = j.getString("audience");
      r.scope_ = j.getString("scope");
      r.createdBy = j.getString("createdBy");

      auto result = useCase.createDestination(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("id", result.id);

        res.writeJsonBody(resp, 201);
      }
      else
      {
        writeError(res, 400, result.error);
      }
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      TenantId tenantId = req.getTenantId;
      auto destinations = useCase.listDestinations(tenantId);

      auto arr = Json.emptyArray;
      foreach (d; destinations)
        arr ~= serializeDestination(d);

      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", destinations.length);
        
      res.writeJsonBody(resp, 200);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGetById(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      TenantId tenantId = req.getTenantId;
      auto dest = useCase.getDestination(tenantId, id);
      if (dest.isNull) {
        writeError(res, 404, "Destination not found");
        return;
      }
      res.writeJsonBody(serializeDestination(*dest), 200);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      auto j = req.json;
      auto r = UpdateDestinationRequest();
      r.id = id;
      r.tenantId = req.getTenantId;
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.systemId = j.getString("systemId");
      r.destinationType = parseDestinationType(j.getString("destinationType"));
      r.url = j.getString("url");
      r.authenticationType = parseAuthenticationType(j.getString("authenticationType"));
      r.proxyType = parseProxyType(j.getString("proxyType"));
      r.cloudConnectorLocationId = j.getString("cloudConnectorLocationId");
      r.user = j.getString("user");
      r.tokenServiceUrl = j.getString("tokenServiceUrl");
      r.tokenServiceUser = j.getString("tokenServiceUser");
      r.audience = j.getString("audience");
      r.scope_ = j.getString("scope");
      r.isEnabled = j.getBoolean("isEnabled", true);

      auto result = useCase.updateDestination(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("id", result.id);
          
        res.writeJsonBody(resp, 200);
      }
      else
      {
        writeError(res, 400, result.error);
      }
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      TenantId tenantId = req.getTenantId;
      auto result = useCase.deleteDestination(tenantId, id);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        res.writeJsonBody(resp, 200);
      }
      else
      {
        writeError(res, 404, result.error);
      }
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private static Json serializeDestination(const Destination d) {
    return Json.emptyObject
    .set("id", d.id)
    .set("tenantId", d.tenantId)
    .set("name", d.name)
    .set("description", d.description)
    .set("systemId", d.systemId)
    .set("destinationType", d.destinationType.to!string)
    .set("url", d.url)
    .set("authenticationType", d.authenticationType.to!string)
    .set("proxyType", d.proxyType.to!string)
    .set("cloudConnectorLocationId", d.cloudConnectorLocationId)
    .set("user", d.user)
    .set("tokenServiceUrl", d.tokenServiceUrl)
    .set("audience", d.audience)
    .set("scope", d.scope_)
    .set("isEnabled", d.isEnabled)
    .set("createdBy", d.createdBy)
    .set("createdAt", d.createdAt)
    .set("updatedAt", d.updatedAt);
  }
}

DestinationType parseDestinationType(string s) {
  switch (s) {
  case "http":
    return DestinationType.http;
  case "rfc":
    return DestinationType.rfc;
  case "odata":
    return DestinationType.odata;
  case "soap":
    return DestinationType.soap;
  case "restApi":
    return DestinationType.restApi;
  default:
    return DestinationType.http;
  }
}

AuthenticationType parseAuthenticationType(string s) {
  switch (s) {
  case "basic":
    return AuthenticationType.basic;
  case "oauth2ClientCredentials":
    return AuthenticationType.oauth2ClientCredentials;
  case "oauth2Saml":
    return AuthenticationType.oauth2Saml;
  case "certificate":
    return AuthenticationType.certificate;
  case "samlBearer":
    return AuthenticationType.samlBearer;
  case "principalPropagation":
    return AuthenticationType.principalPropagation;
  case "noAuthentication":
    return AuthenticationType.noAuthentication;
  default:
    return AuthenticationType.basic;
  }
}

ProxyType parseProxyType(string s) {
  switch (s) {
  case "internet":
    return ProxyType.internet;
  case "onPremise":
    return ProxyType.onPremise;
  case "privateLink":
    return ProxyType.privateLink;
  default:
    return ProxyType.internet;
  }
}
