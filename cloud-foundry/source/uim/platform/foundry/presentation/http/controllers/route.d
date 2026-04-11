/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.foundry.presentation.http.controllers.route;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
// import std.conv : to;

import uim.platform.foundry.application.usecases.manage.routes;
import uim.platform.foundry.application.dto;
import uim.platform.foundry.domain.types;
import uim.platform.foundry.domain.entities.route;
import uim.platform.foundry.domain.entities.cf_domain;

class RouteController : PlatformController {
  private ManageRoutesUseCase useCase;

  this(ManageRoutesUseCase useCase) {
    this.useCase = useCase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    
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

  private void handleCreateRoute(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      auto r = CreateRouteRequest();
      r.tenantId = req.getTenantId;
      r.spaceId = j.getString("spaceId");
      r.domainId = j.getString("domainId");
      r.host = j.getString("host");
      r.path = j.getString("path");
      r.port = j.getInteger("port");
      r.protocol = parseRouteProtocol(j.getString("protocol"));
      r.createdBy = j.getString("createdBy");

      auto result = useCase.createRoute(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        res.writeJsonBody(resp, 201);
      }
      else
        writeError(res, 400, result.error);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleListRoutes(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      TenantId tenantId = req.getTenantId;
      auto items = useCase.listRoutes(tenantId);

      auto arr = Json.emptyArray;
      foreach (r; items)
        arr ~= serializeRoute(r);

      auto resp = Json.emptyObject;
      resp["items"] = arr;
      resp["totalCount"] = Json(items.length);
      res.writeJsonBody(resp, 200);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleGetRoute(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      TenantId tenantId = req.getTenantId;
      auto r = useCase.getRoute(tenantId, id);
      if (r is null) {
        writeError(res, 404, "Route not found");
        return;
      }
      res.writeJsonBody(serializeRoute(*r), 200);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleDeleteRoute(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      TenantId tenantId = req.getTenantId;
      auto result = useCase.deleteRoute(tenantId, id);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        res.writeJsonBody(resp, 200);
      }
      else
        writeError(res, 404, result.error);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleMapRoute(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto routeId = extractIdFromPath(req.requestURI);
      auto j = req.json;
      auto r = MapRouteRequest();
      r.routeId = routeId;
      r.tenantId = req.getTenantId;
      r.appId = j.getString("appId");

      auto result = useCase.mapRoute(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        res.writeJsonBody(resp, 200);
      }
      else
        writeError(res, 400, result.error);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleUnmapRoute(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto routeId = extractIdFromPath(req.requestURI);
      auto j = req.json;
      auto r = MapRouteRequest();
      r.routeId = routeId;
      r.tenantId = req.getTenantId;
      r.appId = j.getString("appId");

      auto result = useCase.unmapRoute(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        res.writeJsonBody(resp, 200);
      }
      else
        writeError(res, 400, result.error);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  // --- Domains ---

  private void handleCreateDomain(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      auto r = CreateDomainRequest();
      r.tenantId = req.getTenantId;
      r.ownerOrgId = j.getString("ownerOrgId");
      r.name = j.getString("name");
      r.scope_ = parseDomainScope(j.getString("scope"));
      r.isInternal = j.getBoolean("isInternal");
      r.createdBy = j.getString("createdBy");

      auto result = useCase.createDomain(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        res.writeJsonBody(resp, 201);
      }
      else
        writeError(res, 400, result.error);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleListDomains(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      TenantId tenantId = req.getTenantId;
      auto items = useCase.listDomains(tenantId);

      auto arr = Json.emptyArray;
      foreach (d; items)
        arr ~= serializeDomain(d);

      auto resp = Json.emptyObject;
      resp["items"] = arr;
      resp["totalCount"] = Json(items.length);
      res.writeJsonBody(resp, 200);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  private void handleDeleteDomain(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      TenantId tenantId = req.getTenantId;
      auto result = useCase.deleteDomain(tenantId, id);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        res.writeJsonBody(resp, 200);
      }
      else
        writeError(res, 404, result.error);
    }
    catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  // --- Serializers ---

  private static Json serializeRoute(const Route r) {
    return Json.emptyObject
      .set("id", r.id)
      .set("spaceId", r.spaceId)
      .set("domainId", r.domainId)
      .set("tenantId", r.tenantId)
      .set("host", r.host)
      .set("path", r.path)
      .set("port", r.port)
      .set("protocol", r.protocol.to!string)
      .set("mappedAppIds", toJsonArray(r.mappedAppIds))
      .set("createdBy", r.createdBy)
      .set("createdAt", r.createdAt)
      .set("updatedAt", r.updatedAt);
  }

  private static Json serializeDomain(const CfDomain d) {
    return Json.emptyObject
      .set("id", d.id)
      .set("ownerOrgId", d.ownerOrgId)
      .set("tenantId", d.tenantId)
      .set("name", d.name)
      .set("scope", d.scope_.to!string)
      .set("isInternal", d.isInternal)
      .set("createdBy", d.createdBy)
      .set("createdAt", d.createdAt)
      .set("updatedAt", d.updatedAt);
  }
}
