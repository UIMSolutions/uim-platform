/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.presentation.http.controllers.data_controller;
// import uim.platform.data.privacy.application.usecases.manage.data_controllers;
// import uim.platform.data.privacy.application.dto;

// import uim.platform.data.privacy.domain.entities.data_controller;
import uim.platform.data.privacy;

// mixin(ShowModule!());

@safe:
class DataControllerController : ManageHttpController {
  private ManageDataControllersUseCase usecase;

  this(ManageDataControllersUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/data-controllers", &handleCreate);
    router.get("/api/v1/data-controllers", &handleList);
    router.get("/api/v1/data-controllers/*", &handleGet);
    router.put("/api/v1/data-controllers/*", &handleUpdate);
    router.delete_("/api/v1/data-controllers/*", &handleDelete);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    CreateDataControllerRequest r;
    r.tenantId = tenantId;
    r.name = data.getString("name");
    r.description = data.getString("description");
    r.legalEntityName = data.getString("legalEntityName");
    r.contactEmail = data.getString("contactEmail");
    r.contactPhone = data.getString("contactPhone");
    r.address = data.getString("address");
    r.country = data.getString("country");
    r.dpoName = data.getString("dpoName");
    r.dpoEmail = data.getString("dpoEmail");

    auto result = usecase.createController(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Data controller created successfully", "Created", 201, responseData);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto items = usecase.listControllers(tenantId);
    auto list = items.map!(item => item.toJson()).array.toJson;

    auto responseData = Json.emptyObject
      .set("count", list.length)
      .set("resources", list);
    return successResponse("Data controller list retrieved successfully", "Retrieved", 200, responseData);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = DataControllerId(precheck.id);

    auto entry = usecase.getController(tenantId, id);
    if (entry.isNull)
      return errorResponse("Data controller not found", 404);

    auto responseData = entry.toJson();
    return successResponse("Data controller retrieved successfully", "Retrieved", 200, responseData);
  }

  override protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto data = precheck.data;

    UpdateDataControllerRequest r;
    r.tenantId = tenantId;
    r.controllerId = DataControllerId(precheck.id);
    r.name = data.getString("name");
    r.description = data.getString("description");
    r.legalEntityName = data.getString("legalEntityName");
    r.contactEmail = data.getString("contactEmail");
    r.contactPhone = data.getString("contactPhone");
    r.address = data.getString("address");
    r.country = data.getString("country");
    r.dpoName = data.getString("dpoName");
    r.dpoEmail = data.getString("dpoEmail");

    auto result = usecase.updateController(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Data controller updated successfully", "Updated", 200, responseData);
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = DataControllerId(precheck.id);

    auto result = usecase.deleteController(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Data controller deleted successfully", "Deleted", 200, responseData);
  }
}
