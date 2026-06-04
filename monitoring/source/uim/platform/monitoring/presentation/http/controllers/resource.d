/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.monitoring.presentation.http.controllers.resource;

// import uim.platform.monitoring.application.usecases.manage.monitored_resources;
// import uim.platform.monitoring.application.dto;
// import uim.platform.monitoring.domain.entities.monitored_resource;
// import uim.platform.monitoring.domain.types;
// import uim.platform.monitoring.presentation.http
import uim.platform.monitoring;

mixin(ShowModule!());

@safe:
class ResourceController : ManageHttpController {
  private ManageMonitoredResourcesUseCase usecase;

  this(ManageMonitoredResourcesUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/resources", &handleCreate);
    router.get("/api/v1/resources", &handleList);
    router.get("/api/v1/resources/*", &handleGet);
    router.put("/api/v1/resources/*", &handleUpdate);
    router.delete_("/api/v1/resources/*", &handleDelete);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    ScanJobDTO dto;
    dto.tenantId = tenantId;
    RegisterResourceRequest r;
    r.tenantId = tenantId;
    r.subaccountId = SubaccountId(req.headers.get("X-Subaccount-Id", ""));
    r.name = data.getString("name");
    r.description = data.getString("description");
    r.resourceType = data.getString("resourceType");
    r.url = data.getString("url");
    r.runtime = data.getString("runtime");
    r.region = data.getString("region");
    r.instanceCount = data.getInteger("instanceCount");
    r.tags = data.getStrings("tags");
    r.registeredBy = UserId(req.headers.get("X-User-Id", ""));

    auto result = usecase.register(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Resource registered successfully", "Created", 201, responseData);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto resources = usecase.listResources(tenantId);

    auto list = resources.map!(item => item.toJson()).array.toJson;

    auto responseData = Json.emptyObject
      .set("count", list.length)
      .set("resources", list);
    return successResponse("Resource list retrieved successfully", "Retrieved", 200, responseData);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = MonitoredResourceId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid resource ID", 400);

    auto item = usecase.existsResource(tenantId, id);
    if (item.isNull)
      return errorResponse("Scan job not found", 404);

    auto responseData = item.toJson();
    return successResponse("Resource retrieved successfully", "Retrieved", 200, responseData);
  }

  override protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = MonitoredResourceId(precheck.id);
    auto data = precheck.data;
    UpdateResourceRequest r;
    r.tenantId = tenantId;
    r.resourceId = id;
    r.description = data.getString("description");
    r.url = data.getString("url");
    r.runtime = data.getString("runtime");
    r.state = data.getString("state");
    r.instanceCount = data.getInteger("instanceCount");
    r.tags = data.getStrings("tags");

    auto result = usecase.updateResource(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Resource updated successfully", "Updated", 200, responseData);
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = MonitoredResourceId(precheck.id);

    auto result = usecase.deleteMonitoredResource(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Resource deleted successfully", "Deleted", 200, responseData);
  }
}
