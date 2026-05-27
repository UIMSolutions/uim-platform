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

    if (req is null)
      return errorResponse("Request is required", 400);

    if (requiredTenant()) {
      auto tenantId = precheck.tenantId;
      if (tenantId.isNull)
        return errorResponse("Tenant ID is required", 400);

      precheck["tenantId"] = tenantId.value;
    }

    return precheck
      .set("data", req.json)
      .set("status", "ok")
      .set("message", "Precheck passed")
      .set("code", 200);
  }

}
