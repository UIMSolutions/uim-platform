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

class RouteController : ManageHttpController {
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

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    auto r = CreateRouteRequest();
    r.tenantId = precheck.tenantId;
    r.spaceId = data.getString("spaceId");
    r.domainId = data.getString("domainId");
    r.host = data.getString("host");
    r.path = data.getString("path");
    r.port = data.getInteger("port");
    r.protocol = parseRouteProtocol(data.getString("protocol"));
    r.createdBy = UserId(data.getString("createdBy"));

    auto result = useCase.createRoute(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Route created successfully", 201, responseData);
  }

  protected Json listRoutesHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto items = useCase.listRoutes(tenantId);
    auto list = items.map!(item => item.toJson()).array.toJson;

    auto responseData = Json.emptyObject
      .set("count", list.length)
      .set("resources", list);
    return successResponse("Route list retrieved successfully", 200, responseData);
  }

  override protected void handleListRoutes(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto response = listRoutesHandler(req);
      res.writeJsonBody(response, response.code);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected Json getRouteHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = RouteId(precheck.id);

    auto r = useCase.getRoute(tenantId, id);
    if (r.isNull)
      return errorResponse("Route not found", 404);

    auto responseData = r.toJson();
    return successResponse("Route retrieved successfully", 200, responseData);
  }

  protected void handleRoute(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto response = getRouteHandler(req);
      res.writeJsonBody(response, response.code);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected Json deleteRouteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = RouteId(precheck.id);

    auto result = useCase.deleteRoute(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 404);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Route deleted successfully", 200, responseData);
  }

  override protected void handleDeleteRoute(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto response = deleteRouteHandler(req);
      res.writeJsonBody(response, response.code);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected Json mapRouteHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto routeId = RouteId(precheck.id);
    auto data = precheck.data;

    MapRouteRequest r;
    r.routeId = routeId;
    r.tenantId = precheck.tenantId;
    r.appId = data.getString("appId");

    auto result = useCase.mapRoute(r);
    if (result.isError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Route mapped to app successfully", 200, responseData);
  }

  protected void handleMapRoute(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto response = mapRouteHandler(req);
      res.writeJsonBody(response, response.code);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }

  protected Json unmapRouteHandler(HTTPServerRequest req) {
    auto precheck = super.postHandler(req);
    if (precheck.hasError)
      return precheck;
    auto tenantId = precheck.tenantId;

    auto routeId = RouteId(precheck.id);
    auto data = precheck.data;
    auto r = MapRouteRequest();
    r.routeId = routeId;
    r.tenantId = precheck.tenantId;
    r.appId = data.getString("appId");

    auto result = useCase.unmapRoute(r);
    if (result.isSuccess()) {
      auto resp = Json.emptyObject
        .set("id", result.id);

      return successResponse("Route unmapped from app successfully", 200, resp);
    }
    protected void handleUnmapRoute(scope HTTPServerRequest req, scope HTTPServerResponse res) {
      try {
        auto response = unmapRouteHandler(req);
        res.writeJsonBody(response, response.code);
      } catch (Exception e) {
        writeError(res, 500, "Internal server error");
      }
    }

    // --- Domains ---

    override protected Json createHandler(HTTPServerRequest req) {
      auto precheck = super.createHandler(req);
      if (precheck.hasError)
        return precheck;

      auto tenantId = precheck.tenantId;

      auto data = precheck.data;
      auto r = CreateDomainRequest();
      r.tenantId = precheck.tenantId;
      r.ownerOrgId = data.getString("ownerOrgId");
      r.name = data.getString("name");
      r.scope_ = parseDomainScope(data.getString("scope"));
      r.isInternal = data.getBoolean("isInternal");
      r.createdBy = UserId(data.getString("createdBy"));

      auto result = useCase.createDomain(r);
      if (result.hasError)
        return errorResponse(result.message, 400);

      auto responseData = Json.emptyObject.set("id", result.id);
      return successResponse("Domain created successfully", 201, responseData);
    }

    protected Json listDomainsHandler(HTTPServerRequest req) {
      auto precheck = super.listHandler(req);
      if (precheck.hasError)
        return precheck;

      auto tenantId = precheck.tenantId;

      auto items = useCase.listDomains(tenantId);
      auto list = items.map!(item => item.toJson()).array.toJson;

      auto responseData = Json.emptyObject
        .set("count", list.length)
        .set("resources", list);
      return successResponse("Domain list retrieved successfully", 200, responseData);
    }
    protected void handleListDomains(scope HTTPServerRequest req, scope HTTPServerResponse res) {
      try {
        auto response = listDomainsHandler(req);
        res.writeJsonBody(response, response.code);
      } catch (Exception e) {
        writeError(res, 500, "Internal server error");
      }
    }

    protected Json deleteDomainHandler(HTTPServerRequest req) {
      auto precheck = super.deleteHandler(req);
      if (precheck.hasError)
        return precheck;

      auto tenantId = precheck.tenantId;
      auto id = DomainId(precheck.id);
      if (id.isNull)
        return errorResponse("Invalid domain ID", 400);

      auto result = useCase.deleteDomain(tenantId, id);
      if (result.hasError)
        return errorResponse(result.message, 400);

      auto responseData = Json.emptyObject.set("id", result.id);
      return successResponse("Domain deleted successfully", 200, responseData);
    }

    protected void handleDeleteDomain(scope HTTPServerRequest req, scope HTTPServerResponse res) {
      try {
        auto response = deleteDomainHandler(req);
        res.writeJsonBody(response, response.code);
      } catch (Exception e) {
        writeError(res, 500, "Internal server error");
      }

    }
