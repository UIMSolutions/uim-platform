/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.service.presentation.controllers.manage;

import uim.platform.service;

mixin(ShowModule!());

@safe:

class ManageController : PlatformController {
  this() {
    super();
  }

  this(Json initData) {
    super(initData);
  }

  this(Json[string] initData) {
    super(initData);
  }

  override bool initialize(Json[string] initData = null) {
    if (!super.initialize(initData)) {
      return false;
    }
    // Additional initialization logic for the ManageController
    return true;
  }

  protected Json createHandler(Json data) {
    Json response = Json.emptyObject;
    response.set("message", "Create handler not implemented");
    return response;
  }
  
  protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto response = createHandler(req.json);
      res.writeJsonBody(response, 201);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
}
