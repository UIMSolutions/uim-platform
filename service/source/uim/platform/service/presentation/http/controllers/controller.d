/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.service.presentation.http.controllers.controller;

import uim.platform.service;

mixin(ShowModule!());

@safe:

class PlatformController {
  this() {
    initialize();
  }

  this(Json initData) {
    if (initData.isObject) {
      initialize(initData.toMap);
    }
  }

  this(Json[string] initData) {
    initialize(initData);
  }

  bool initialize(Json[string] initData = null) {
    // Initialization logic for the controller

    _requiredTenant = initData.getBoolean("requiredTenant", true);
    return true;
  }

  void registerRoutes(URLRouter router) {
    // Register HTTP routes and handlers here
  }

  protected bool _requiredTenant = true; // Tenant is required for manage controllers
  bool requiredTenant() {
    return _requiredTenant;
  }

  Json precheckHandler(HTTPServerRequest req) {
    auto precheck = Json.emptyObject;

    // writeln("Precheck: Checking request validity for path ", req.requestPath);
    // writeln("Precheck: Request method ", req.method);
    // writeln("Precheck: Request headers ", req.headers);
    // writeln("Precheck: Request params ", req.params);
    // writeln("Precheck: Request query ", req.query);
    // writeln("Precheck: Request body ", req.json);

    if (req is null)
      return errorResponse("Request is required", 400);

    if (requiredTenant()) {
      auto tenantId = TenantId(req.headers.get("X-Tenant-Id", "default"));
      if (tenantId.isNull)
        return errorResponse("Tenant ID is required", 400);

      precheck["tenantId"] = tenantId.value;
    }

    return precheck
      .set("path", req.requestPath.to!string)
      .set("method", req.method.to!string)
      // .set("headers", req.headers.toMap)
      // .set("params", req.params.toMap)
      // .set("query", req.query.toMap)
      .set("data", req.json)
      .set("status", "ok")
      .set("message", "Precheck passed")
      .set("code", 200);
  }

  // #region get
  protected Json getHandler(HTTPServerRequest req) {
    auto precheck = precheckHandler(req);
    // writeln("Precheck result in listHandler: ", precheck);
    if (hasError(precheck))
      return precheck; // Return error response from precheck

    return successResponse(precheck, "Get handler not implemented", 200);
  }

  protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto response = getHandler(req);
      res.writeJsonBody(response, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
  // #endregion get

// #region post
  protected Json headHandler(HTTPServerRequest req) {
    auto precheck = precheckHandler(req);
    if (hasError(precheck))
      return precheck; // Return error response from precheck

    return successResponse(precheck, "Head handler not implemented", 200);
  }

  protected void handleHead(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto response = headHandler(req);
      res.writeJsonBody(response, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
  // #endregion head}

  // #region post
  protected Json postHandler(HTTPServerRequest req) {
    auto precheck = precheckHandler(req);
    if (hasError(precheck))
      return precheck; // Return error response from precheck

    return successResponse(precheck, "Post handler not implemented", 201);
  }

  protected void handlePost(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto response = postHandler(req);
      res.writeJsonBody(response, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
  // #endregion post

  // #region put
  protected Json putHandler(HTTPServerRequest req) {
    auto precheck = precheckHandler(req);
    if (hasError(precheck))
      return precheck; // Return error response from precheck

    return successResponse(precheck, "Put handler not implemented", 200);
  }

  protected void handlePut(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto response = putHandler(req);
      res.writeJsonBody(response, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
  // #endregion put

  // #region delete
  protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = precheckHandler(req);
    if (hasError(precheck))
      return precheck; // Return error response from precheck

    return successResponse(precheck, "Delete handler not implemented", 200);
  }

  protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto response = deleteHandler(req);
      res.writeJsonBody(response, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
  // #endregion delete

  // #region connect
  protected Json connectHandler(HTTPServerRequest req) {
    auto precheck = precheckHandler(req);
    if (hasError(precheck))
      return precheck; // Return error response from precheck

    return successResponse(precheck, "Connect handler not implemented", 200);
  }

  protected void handleConnect(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto response = connectHandler(req);
      res.writeJsonBody(response, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
  // #endregion connect

  // #region trace
  protected Json traceHandler(HTTPServerRequest req) {
    auto precheck = precheckHandler(req);
    if (hasError(precheck))
      return precheck; // Return error response from precheck

    return successResponse(precheck, "Trace handler not implemented", 200);
  }

  protected void handleTrace(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto response = traceHandler(req);
      res.writeJsonBody(response, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
  // #endregion trace

  // #region patch
  protected Json patchHandler(HTTPServerRequest req) {
    auto precheck = precheckHandler(req);
    if (hasError(precheck))
      return precheck; // Return error response from precheck

    return successResponse(precheck, "Patch handler not implemented", 200);
  }

  protected void handlePatch(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto response = patchHandler(req);
      res.writeJsonBody(response, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
  // #endregion patch
} 