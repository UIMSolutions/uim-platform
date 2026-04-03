module uim.platform.foundry.presentation.http.controllers.route;

import vibe.http.server;
import vibe.http.router;
import vibe.data.json;
import std.conv : to;

import uim.platform.foundry.application.usecases.manage_routes;
import uim.platform.foundry.application.dto;
import uim.platform.foundry.domain.types;
import uim.platform.foundry.domain.entities.route;
import uim.platform.foundry.domain.entities.cf_domain;
import uim.platform.foundry.presentation.http.json_utils;

class RouteController
{
  private ManageRoutesUseCase useCase;

  this(ManageRoutesUseCase useCase)
  {
    this.useCase = useCase;
  }

  override void registerRoutes(URLRouter router)
  {
    // Routes
    router.post("/api/v1/routes", &handleCreateRoute);
    router.get("/api/v1/routes", &handleListRoutes);
    router.post("/api/v1/routes/map/*", &handleMapRoute);
    router.post("/api/v1/routes/unmap/*", &handleUnmapRoute);
    router.get("/api/v1/routes/*", &handleGetRoute);
    router.delete_("/api/v1/routes/*", &handleDeleteRoute);
    // Domains
    router.post("/api/v1/domains", &handleCreateDomain);
    router.get("/api/v1/domains", &handleListDomains);
    router.delete_("/api/v1/domains/*", &handleDeleteDomain);
  }

  // --- Routes ---

  private void handleCreateRoute(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto j = req.json;
      auto r = CreateRouteRequest();
      r.tenantId = req.headers.get("X-Tenant-Id", "");
      r.spaceId = j.getString("spaceId");
      r.domainId = j.getString("domainId");
      r.host = j.getString("host");
      r.path = j.getString("path");
      r.port = j.getInteger("port");
      r.protocol = parseRouteProtocol(j.getString("protocol"));
      r.createdBy = j.getString("createdBy");

      auto result = useCase.createRoute(r);
      if (result.isSuccess())
      {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        res.writeJsonBody(resp, 201);
      }
      else
        writeError(res, 400, result.error);
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleListRoutes(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      auto items = useCase.listRoutes(tenantId);

      auto arr = Json.emptyArray;
      foreach (ref r; items)
        arr ~= serializeRoute(r);

      auto resp = Json.emptyObject;
      resp["items"] = arr;
      resp["totalCount"] = Json(cast(long) items.length);
      res.writeJsonBody(resp, 200);
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGetRoute(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto id = extractIdFromPath(req.requestURI);
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      auto r = useCase.getRoute(id, tenantId);
      if (r is null)
      {
        writeError(res, 404, "Route not found");
        return;
      }
      res.writeJsonBody(serializeRoute(*r), 200);
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleDeleteRoute(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto id = extractIdFromPath(req.requestURI);
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      auto result = useCase.deleteRoute(id, tenantId);
      if (result.isSuccess())
      {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        res.writeJsonBody(resp, 200);
      }
      else
        writeError(res, 404, result.error);
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleMapRoute(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto routeId = extractIdFromPath(req.requestURI);
      auto j = req.json;
      auto r = MapRouteRequest();
      r.routeId = routeId;
      r.tenantId = req.headers.get("X-Tenant-Id", "");
      r.appId = j.getString("appId");

      auto result = useCase.mapRoute(r);
      if (result.isSuccess())
      {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        res.writeJsonBody(resp, 200);
      }
      else
        writeError(res, 400, result.error);
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleUnmapRoute(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto routeId = extractIdFromPath(req.requestURI);
      auto j = req.json;
      auto r = MapRouteRequest();
      r.routeId = routeId;
      r.tenantId = req.headers.get("X-Tenant-Id", "");
      r.appId = j.getString("appId");

      auto result = useCase.unmapRoute(r);
      if (result.isSuccess())
      {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        res.writeJsonBody(resp, 200);
      }
      else
        writeError(res, 400, result.error);
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  // --- Domains ---

  private void handleCreateDomain(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto j = req.json;
      auto r = CreateDomainRequest();
      r.tenantId = req.headers.get("X-Tenant-Id", "");
      r.ownerOrgId = j.getString("ownerOrgId");
      r.name = j.getString("name");
      r.scope_ = parseDomainScope(j.getString("scope"));
      r.isInternal = j.getBoolean("isInternal");
      r.createdBy = j.getString("createdBy");

      auto result = useCase.createDomain(r);
      if (result.isSuccess())
      {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        res.writeJsonBody(resp, 201);
      }
      else
        writeError(res, 400, result.error);
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleListDomains(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      auto items = useCase.listDomains(tenantId);

      auto arr = Json.emptyArray;
      foreach (ref d; items)
        arr ~= serializeDomain(d);

      auto resp = Json.emptyObject;
      resp["items"] = arr;
      resp["totalCount"] = Json(cast(long) items.length);
      res.writeJsonBody(resp, 200);
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleDeleteDomain(scope HTTPServerRequest req, scope HTTPServerResponse res)
  {
    try
    {
      auto id = extractIdFromPath(req.requestURI);
      auto tenantId = req.headers.get("X-Tenant-Id", "");
      auto result = useCase.deleteDomain(id, tenantId);
      if (result.isSuccess())
      {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        res.writeJsonBody(resp, 200);
      }
      else
        writeError(res, 404, result.error);
    }
    catch (Exception e)
    {
      writeError(res, 500, "Internal server error");
    }
  }

  // --- Serializers ---

  private static Json serializeRoute(ref const Route r)
  {
    auto j = Json.emptyObject;
    j["id"] = Json(r.id);
    j["spaceId"] = Json(r.spaceId);
    j["domainId"] = Json(r.domainId);
    j["tenantId"] = Json(r.tenantId);
    j["host"] = Json(r.host);
    j["path"] = Json(r.path);
    j["port"] = Json(r.port);
    j["protocol"] = Json(r.protocol.to!string);
    j["mappedAppIds"] = toJsonArray(r.mappedAppIds);
    j["createdBy"] = Json(r.createdBy);
    j["createdAt"] = Json(r.createdAt);
    j["updatedAt"] = Json(r.updatedAt);
    return j;
  }

  private static Json serializeDomain(ref const CfDomain d)
  {
    auto j = Json.emptyObject;
    j["id"] = Json(d.id);
    j["ownerOrgId"] = Json(d.ownerOrgId);
    j["tenantId"] = Json(d.tenantId);
    j["name"] = Json(d.name);
    j["scope"] = Json(d.scope_.to!string);
    j["isInternal"] = Json(d.isInternal);
    j["createdBy"] = Json(d.createdBy);
    j["createdAt"] = Json(d.createdAt);
    j["updatedAt"] = Json(d.updatedAt);
    return j;
  }
}
