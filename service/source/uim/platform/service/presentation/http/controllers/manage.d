/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.service.presentation.http.controllers.manage;

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

    _requiredTenant = initData.getBoolean("requiredTenant", true);
    return true;
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
      auto tenantId = req.getTenantId;
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

  // #region list
  protected Json listHandler(HTTPServerRequest req) {
    auto precheck = precheckHandler(req);
    if (hasError(precheck))
      return precheck; // Return error response from precheck

    return precheck
      .set("status", "ok")
      .set("message", "List handler not implemented")
      .set("code", 200);
  }

  protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto response = listHandler(req);
      res.writeJsonBody(response, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
  // #endregion list

  // #region create
  protected Json createHandler(HTTPServerRequest req) {
    auto precheck = precheckHandler(req);
    if (precheck.hasError)
      return precheck; // Return error response from precheck

    return precheck
      .set("status", "ok")
      .set("message", "Create handler not implemented")
      .set("code", 201);
  }

  protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto response = createHandler(req);
      res.writeJsonBody(response, 201);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
  // #endregion create

  // #region get
  protected Json getHandler(HTTPServerRequest req) {
    auto precheck = precheckHandler(req);
    if (precheck.hasError)
      return precheck; // Return error response from precheck

    return precheck
      .set("status", "ok")
      .set("message", "Get handler not implemented")
      .set("code", 200);
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

  // #region update
  protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = precheckHandler(req);
    if (precheck.hasError)
      return precheck; // Return error response from precheck 

    auto id = extractIdFromPath(req.requestURI);
    if (id.isEmpty)
      return errorResponse("ID is required", 400);

    return precheck
      .set("id", id)
      .set("status", "ok")
      .set("message", "Update handler not implemented")
      .set("code", 200);
  }

  protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto response = updateHandler(req);
      res.writeJsonBody(response, 200);
    } catch (Exception e) {
      writeError(res, 500, "Internal server error");
    }
  }
  // #endregion update

  // #region delete
  protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = precheckHandler(req);
    if (precheck.hasError)
      return precheck; // Return error response from precheck

    auto id = extractIdFromPath(req.requestURI);
    if (id.isEmpty)
      return errorResponse("ID is required", 400);

    return precheck
      .set("id", id)
      .set("status", "ok")
      .set("message", "Delete handler not implemented")
      .set("code", 200);
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
}
///
unittest {
  auto controller = new ManageController();
  assert(controller.requiredTenant() == true);
  // 
  auto controllerWithInit = new ManageController(Json.emptyObject.set("requiredTenant", false));
  assert(controllerWithInit.requiredTenant() == false);
  // 
  Json[string] initData = ["requiredTenant": Json(true)];
  auto controllerWithInit2 = new ManageController(initData);
  assert(controllerWithInit2.requiredTenant() == true);

  // Test listHandler
  auto listResponse = controller.listHandler(null);
  assert(listResponse.getString("status") == "error");
  // // assert(listResponse.getString("message") == "Tenant ID is required");

  // // Make a List request
  // // auto response = requestHTTP("http://localhost:8080/api/users",
  // //     (scope req) {
  // //         req.method = HTTPMethod.GET;
  // //     }
  // // );

  listResponse = controllerWithInit.listHandler(null);
  // // assert(listResponse.getString("status") == "ok");
  // // assert(listResponse.getString("message") == "Precheck passed");

  // // Test createHandler
  auto createResponse = controller.createHandler(null);
  assert(createResponse.getString("status") == "error");
  // // assert(createResponse.getString("message") == "Tenant ID is required");

  createResponse = controllerWithInit.createHandler(null);
  // // assert(createResponse.getString("status") == "error");
  // // assert(createResponse.getString("message") == "Request body is required");

  // // Test getHandler
  auto getResponse = controller.getHandler(null);
  assert(getResponse.getString("status") == "error");
  // // assert(getResponse.getString("message") == "Tenant ID is required");

  // getResponse = controllerWithInit.getHandler(null);
  // // assert(getResponse.getString("status") == "ok");
  // // assert(getResponse.getString("message") == "Get handler not implemented");

  // // Test updateHandler
  auto updateResponse = controller.updateHandler(null);
  assert(updateResponse.getString("status") == "error");
  // // assert(updateResponse.getString("message") == "Tenant ID is required");

  updateResponse = controllerWithInit.updateHandler(null);
  assert(updateResponse.getString("status") == "error");
  // // assert(updateResponse.getString("message") == "Request body is required");

  // // Test deleteHandler
  // auto deleteResponse = controller.deleteHandler(null);
  // // assert(deleteResponse.getString("status") == "error");
  // // assert(deleteResponse.getString("message") == "Tenant ID is required");

  // deleteResponse = controllerWithInit.deleteHandler(null);
  // // assert(deleteResponse.getString("status") == "ok");
  // // assert(deleteResponse.getString("message") == "Delete handler not implemented");

  // HTTPServerRequest req;
  // // req.headers["X-Tenant-Id"] = "tenant1";

  // // writeln(req);

  // listResponse = controller.listHandler(req);
  // //  assert(listResponse.getString("status") == "ok");
  // //  assert(listResponse.getString("message") == "Precheck passed");

}
