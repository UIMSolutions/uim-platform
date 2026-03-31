module presentation.http.destination;

import vibe.http.server;
import vibe.http.router;
import vibe.data.json;
import std.conv : to;

import application.usecases.manage_destinations;
import application.dto;
import domain.types;
import domain.entities.destination;
import presentation.http.json_utils;
import presentation.http.scenario_controller : parseSystemType;

class DestinationController
{
  private ManageDestinationsUseCase useCase;

  this(ManageDestinationsUseCase useCase)
  {
    this.useCase = useCase;
  }

  void registerRoutes(URLRouter router)
  {
    router.post("/api/v1/destinations", &handleCreate);
    router.get("/api/v1/destinations", &handleList);
    router.get("/api/v1/destinations/*", &handleGetById);
    router.put("/api/v1/destinations/*", &handleUpdate);
    router.delete_("/api/v1/destinations/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto j = req.json;
      auto r = CreateDestinationRequest();
      r.tenantId = req.headers.get("X-Tenant-Id", "");
      r.name = jsonStr(j, "name");
      r.description = jsonStr(j, "description");
      r.systemId = jsonStr(j, "systemId");
      r.destinationType = parseDestinationType(jsonStr(j, "destinationType"));
      r.url = jsonStr(j, "url");
      r.authenticationType = parseAuthenticationType(jsonStr(j, "authenticationType"));
      r.proxyType = parseProxyType(jsonStr(j, "proxyType"));
      r.cloudConnectorLocationId = jsonStr(j, "cloudConnectorLocationId");
      r.user = jsonStr(j, "user");
      r.tokenServiceUrl = jsonStr(j, "tokenServiceUrl");
      r.tokenServiceUser = jsonStr(j, "tokenServiceUser");
      r.audience = jsonStr(j, "audience");
      r.scope_ = jsonStr(j, "scope");
      r.createdBy = jsonStr(j, "createdBy");

      auto result = useCase.createDestination(r);
      if (result.isSuccess())
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

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      auto destinations = useCase.listDestinations(tenantId);

      auto arr = Json.emptyArray;
      foreach (ref d; destinations)
        arr ~= serializeDestination(d);

      auto resp = Json.emptyObject;
      resp["items"] = arr;
      resp["totalCount"] = Json(cast(long) destinations.length);
      res.writeJsonBody(resp, 200);
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGetById(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto id = extractIdFromPath(req.requestURI);
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      auto dest = useCase.getDestination(id, tenantId);
      if (dest is null)
      {
        writeError(res, 404, "Destination not found");
        return;
      }
      res.writeJsonBody(serializeDestination(*dest), 200);
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto id = extractIdFromPath(req.requestURI);
      auto j = req.json;
      auto r = UpdateDestinationRequest();
      r.id = id;
      r.tenantId = req.headers.get("X-Tenant-Id", "");
      r.name = jsonStr(j, "name");
      r.description = jsonStr(j, "description");
      r.systemId = jsonStr(j, "systemId");
      r.destinationType = parseDestinationType(jsonStr(j, "destinationType"));
      r.url = jsonStr(j, "url");
      r.authenticationType = parseAuthenticationType(jsonStr(j, "authenticationType"));
      r.proxyType = parseProxyType(jsonStr(j, "proxyType"));
      r.cloudConnectorLocationId = jsonStr(j, "cloudConnectorLocationId");
      r.user = jsonStr(j, "user");
      r.tokenServiceUrl = jsonStr(j, "tokenServiceUrl");
      r.tokenServiceUser = jsonStr(j, "tokenServiceUser");
      r.audience = jsonStr(j, "audience");
      r.scope_ = jsonStr(j, "scope");
      r.isEnabled = jsonBool(j, "isEnabled", true);

      auto result = useCase.updateDestination(r);
      if (result.isSuccess())
      {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        res.writeJsonBody(resp, 200);
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

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto id = extractIdFromPath(req.requestURI);
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      auto result = useCase.deleteDestination(id, tenantId);
      if (result.isSuccess())
      {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
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

  private static Json serializeDestination(ref const Destination d)
  {
    auto j = Json.emptyObject;
    j["id"] = Json(d.id);
    j["tenantId"] = Json(d.tenantId);
    j["name"] = Json(d.name);
    j["description"] = Json(d.description);
    j["systemId"] = Json(d.systemId);
    j["destinationType"] = Json(d.destinationType.to!string);
    j["url"] = Json(d.url);
    j["authenticationType"] = Json(d.authenticationType.to!string);
    j["proxyType"] = Json(d.proxyType.to!string);
    j["cloudConnectorLocationId"] = Json(d.cloudConnectorLocationId);
    j["user"] = Json(d.user);
    j["tokenServiceUrl"] = Json(d.tokenServiceUrl);
    j["audience"] = Json(d.audience);
    j["scope"] = Json(d.scope_);
    j["isEnabled"] = Json(d.isEnabled);
    j["createdBy"] = Json(d.createdBy);
    j["createdAt"] = Json(d.createdAt);
    j["updatedAt"] = Json(d.updatedAt);
    return j;
  }
}

DestinationType parseDestinationType(string s)
{
  switch (s)
  {
    case "http": return DestinationType.http;
    case "rfc": return DestinationType.rfc;
    case "odata": return DestinationType.odata;
    case "soap": return DestinationType.soap;
    case "restApi": return DestinationType.restApi;
    default: return DestinationType.http;
  }
}

AuthenticationType parseAuthenticationType(string s)
{
  switch (s)
  {
    case "basic": return AuthenticationType.basic;
    case "oauth2ClientCredentials": return AuthenticationType.oauth2ClientCredentials;
    case "oauth2Saml": return AuthenticationType.oauth2Saml;
    case "certificate": return AuthenticationType.certificate;
    case "samlBearer": return AuthenticationType.samlBearer;
    case "principalPropagation": return AuthenticationType.principalPropagation;
    case "noAuthentication": return AuthenticationType.noAuthentication;
    default: return AuthenticationType.basic;
  }
}

ProxyType parseProxyType(string s)
{
  switch (s)
  {
    case "internet": return ProxyType.internet;
    case "onPremise": return ProxyType.onPremise;
    case "privateLink": return ProxyType.privateLink;
    default: return ProxyType.internet;
  }
}
