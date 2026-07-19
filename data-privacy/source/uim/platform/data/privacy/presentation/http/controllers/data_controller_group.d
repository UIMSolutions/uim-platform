/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.presentation.http.controllers.data_controller_group;
// import uim.platform.data.privacy.application.usecases.manage.data_controller_groups;
// import uim.platform.data.privacy.application.dto;

// import uim.platform.data.privacy.domain.entities.data_controller_group;
import uim.platform.data.privacy;
mixin(ShowModule!());

@safe:
class DataControllerGroupController : ManageHttpController {
  private ManageDataControllerGroupsUseCase usecase;

  this(ManageDataControllerGroupsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/controller-groups", &handleCreate);
    router.get("/api/v1/controller-groups", &handleList);
    router.get("/api/v1/controller-groups/*", &handleGet);
    router.put("/api/v1/controller-groups/*", &handleUpdate);
    router.delete_("/api/v1/controller-groups/*", &handleDelete);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    CreateDataControllerGroupRequest r;
    r.tenantId = tenantId;
    r.name = data.getString("name");
    r.description = data.getString("description");
    r.controllerIds = data.getStrings("controllerIds").map!(cid => DataControllerId(cid)).array;

    auto result = usecase.createGroup(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Data controller group created successfully", "Created", 201, responseData);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto items = usecase.listGroups(tenantId);

    auto list = items.map!(item => item.toJson()).array.toJson;

    auto responseData = Json.emptyObject
      .set("count", list.length)
      .set("resources", list);
    return successResponse("Data controller group list retrieved successfully", "Retrieved", 200, responseData);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = DataControllerGroupId(precheck.id);

    auto entry = usecase.getGroup(tenantId, id);
    if (entry.isNull)
      return errorResponse("Data controller group not found", 404);

    auto responseData = entry.toJson();
    return successResponse("Data controller group retrieved successfully", "Retrieved", 200, responseData);
  }

  override protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = DataControllerGroupId(precheck.id);
    auto data = precheck.data;
    UpdateDataControllerGroupRequest r;
    r.groupId = id;
    r.tenantId = tenantId;
    r.name = data.getString("name");
    r.description = data.getString("description");
    r.controllerIds = data.getStrings("controllerIds").map!(cid => DataControllerId(cid)).array;

    auto result = usecase.updateGroup(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Data controller group updated successfully", "Updated", 200, responseData);
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = DataControllerGroupId(precheck.id);

    auto result = usecase.deleteGroup(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Data controller group deleted successfully", "Deleted", 200, responseData);
  }
}

