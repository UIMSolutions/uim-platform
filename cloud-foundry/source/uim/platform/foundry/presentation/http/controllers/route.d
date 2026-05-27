/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.foundry.presentation.http.controllers.route;






// import uim.platform.foundry.application.usecases.manage.routes;
// import uim.platform.foundry.application.dto;
// import uim.platform.foundry.domain.types;
// import uim.platform.foundry.domain.entities.route;
// import uim.platform.foundry.domain.entities.cf_domain;
import uim.platform.foundry;

mixin(ShowModule!());

@safe:

class RouteController : ManageController {
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

  override protected void handleCreate(Route(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto data = precheck.data;
      auto r = CreateRouteRequest();
      r.tenantId = tenantId;
      r.spaceId = data.getString("spaceId");
      r.domainId = data.getString("domainId");
      r.host = data.getString("host");
      r.path = data.getString("path");
      r.port = data.getInteger("port");
      r.protocol = parseRouteProtocol(data.getString("protocol"));
      r.createdBy = UserId(data.getString("createdBy"));

      auto result = useCase.createRoute(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Route created successfully");
          
        res.writeJsonBody(resp, 201);
      } else
        writeError(res, 400, result.message);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleListRoutes(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto items = useCase.listRoutes(tenantId);

      auto arr = items.map!(r => r.toJson).array.toJson;
      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", items.length);

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleRoute(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto id = RouteId(precheck.id);
      auto tenantId = precheck.tenantId;
      auto r = useCase.getRoute(tenantId, id);
      if (r.isNull) {
        writeError(res, 404, "Route not found");
        return;
      }
      res.writeJsonBody(r.toJson, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleDeleteRoute(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto id = RouteId(precheck.id);
      auto tenantId = precheck.tenantId;
      auto result = useCase.deleteRoute(tenantId, id);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("id", result.id);

        res.writeJsonBody(resp, 200);
      } else
        writeError(res, 404, result.message);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleMapRoute(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto data = precheck.data;
      auto r = MapRouteRequest();
      r.routeId = RouteId(precheck.id);
      r.tenantId = tenantId;
      r.appId = data.getString("appId");

      auto result = useCase.mapRoute(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("id", result.id);

        res.writeJsonBody(resp, 200);
      } else
        writeError(res, 400, result.message);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected void handleUnmapRoute(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto routeId = RouteId(precheck.id);
      auto data = precheck.data;
      auto r = MapRouteRequest();
      r.routeId = routeId;
      r.tenantId = tenantId;
      r.appId = data.getString("appId");

      auto result = useCase.unmapRoute(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("id", result.id);

        res.writeJsonBody(resp, 200);
      } else
        writeError(res, 400, result.message);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  // --- Domains ---

  override protected void handleCreate(Domain(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto data = precheck.data;
      auto r = CreateDomainRequest();
      r.tenantId = tenantId;
      r.ownerOrgId = data.getString("ownerOrgId");
      r.name = data.getString("name");
      r.scope_ = parseDomainScope(data.getString("scope"));
      r.isInternal = j.getBoolean("isInternal");
      r.createdBy = UserId(data.getString("createdBy"));

      auto result = useCase.createDomain(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Domain created successfully")  ;

        res.writeJsonBody(resp, 201);
      } else
        writeError(res, 400, result.message);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleListDomains(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto items = useCase.listDomains(tenantId);

      auto arr = items.map!(d => d.toJson).array.toJson;

      auto resp = Json.emptyObject
        .set("items", arr)
        .set("totalCount", items.length)
        .set("message", "Domains retrieved successfully");

      res.writeJsonBody(resp, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  override protected void handleDeleteDomain(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto id = DomainId(precheck.id);
      auto tenantId = precheck.tenantId;
      auto result = useCase.deleteDomain(tenantId, id);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("id", result.id)
          .set("message", "Domain deleted successfully");

        res.writeJsonBody(resp, 200);
      } else
        writeError(res, 404, result.message);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
 
}
