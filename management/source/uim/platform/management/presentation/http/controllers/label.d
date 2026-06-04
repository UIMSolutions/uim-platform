/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.presentation.http.controllers.label;

// 
// import uim.platform.management.application.usecases.manage.labels;
// import uim.platform.management.application.dto;
// import uim.platform.management.domain.entities.label;
// import uim.platform.management.domain.types;
import uim.platform.management;

mixin(ShowModule!());
@safe:
class LabelController : ManageHttpController {
  private ManageLabelsUseCase usecase;

  this(ManageLabelsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/labels", &handleCreate);
    router.get("/api/v1/labels", &handleList);
    router.get("/api/v1/labels/*", &handleGet);
    router.put("/api/v1/labels/*", &handleUpdate);
    router.delete_("/api/v1/labels/*", &handleDelete);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    CreateLabelRequest r;
    r.tenantId = tenantId;
    r.resourceType = data.getString("resourceType");
    r.resourceId = data.getString("resourceId");
    r.key = data.getString("key");
    r.values = data.getStrings("values");
    r.createdBy = UserId(req.headers.get("X-User-Id", ""));

    auto result = usecase.createLabel(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Label created successfully", "Created", 201, responseData);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto resourceType = req.params.get("resourceType");
    auto resourceId = req.params.get("resourceId");
    auto key = req.params.get("key");

    Label[] items;
    if (resourceType.length > 0 && !resourceId.isEmpty)
      items = usecase.listLabels(tenantId, resourceType, resourceId);
    else if (resourceType.length > 0 && key.length > 0)
      items = usecase.listLabelsByKey(tenantId, resourceType, key);

    auto list = items.map!(item => item.toJson()).array.toJson;

    auto responseData = Json.emptyObject
      .set("count", items.length)
      .set("resources", list);
    return successResponse("Label list retrieved successfully", "Retrieved", 200, responseData);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = LabelId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid label ID", 400);

    auto label = usecase.getLabel(tenantId, id);
    if (label.isNull)
      return errorResponse("Label not found", 404);

    auto responseData = label.toJson();
    return successResponse("Label retrieved successfully", "Retrieved", 200, responseData);
  }

  override protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto id = LabelId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid label ID", 400);

    auto data = precheck.data;
    UpdateLabelRequest r;
    r.tenantId = tenantId;
    r.values = data.getStrings("values");

    auto result = usecase.updateLabel(tenantId, id, r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Label updated successfully", "Updated", 200, responseData);
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = LabelId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid label ID", 400);

    auto result = usecase.deleteLabel(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Label deleted successfully", "Deleted", 200, responseData);
  }
}
