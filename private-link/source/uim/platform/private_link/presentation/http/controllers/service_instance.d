/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.private_link.presentation.http.controllers.service_instance;
import uim.platform.private_link;
mixin(ShowModule!());

@safe:
/// HTTP controller for private link service instance lifecycle management.
class ServiceInstanceController : ManageHttpController {
  private ManageServiceInstancesUseCase usecase;

  this(ManageServiceInstancesUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    router.post("/api/v1/service-instances", &handleCreate);
    router.get("/api/v1/service-instances", &handleList);
    router.get("/api/v1/service-instances/*", &handleGet);
    router.put("/api/v1/service-instances/*", &handleUpdate);
    router.delete_("/api/v1/service-instances/*", &handleDelete);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto tenantId = precheck.tenantId;
    auto items = usecase.listInstances(tenantId).map!(i => i.toJson).array;
    return successResponse("Service instances retrieved successfully", 200, Json.emptyObject
      .set("items", items)
      .set("totalCount", items.length));
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto tenantId = precheck.tenantId;
    auto data = precheck.data;
    auto r = CreateServiceInstanceRequest();
    r.tenantId = tenantId;
    r.name = data.getString("name");
    r.description = data.getString("description");
    r.resourceId = data.getString("resourceId");
    r.iaasProvider = data.getString("iaasProvider");
    r.plan = data.getString("plan");
    r.region = data.getString("region");
    r.subaccountId = data.getString("subaccountId");

    auto result = usecase.createInstance(r);
    if (result.hasError())
      return errorResponse(result.message, 400);

    return successResponse("Service instance created successfully", 201, Json.emptyObject.set("id", result.id));
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto tenantId = precheck.tenantId;
    auto id = ServiceInstanceId(precheck.id);
    auto inst = usecase.getInstance(tenantId, id);
    if (inst.id.value.length == 0)
      return errorResponse("Service instance not found", 404);

    return successResponse("Service instance retrieved successfully", 200, inst.toJson);
  }

  override protected Json updateHandler(HTTPServerRequest req) {
    auto tenantId = precheck.tenantId;
    auto id = ServiceInstanceId(precheck.id);
    auto data = precheck.data;
    auto r = UpdateServiceInstanceRequest();
    r.tenantId = tenantId;
    r.instanceId = id;
    r.description = data.getString("description");
    r.statusMessage = data.getString("statusMessage");

    auto result = usecase.updateInstance(r);
    if (result.hasError())
      return errorResponse(result.message, result.message == "Service instance not found" ? 404 : 400);
    
    return successResponse("Service instance updated successfully", 200, Json.emptyObject.set("id", result.id));
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto tenantId = precheck.tenantId;
    auto id = ServiceInstanceId(precheck.id);
    auto result = usecase.deleteInstance(tenantId, id);
    if (result.hasError()) 
      return errorResponse(result.message, result.message == "Service instance not found" ? 404 : 400);
    
    return successResponse("Service instance deleted successfully", 200, Json.emptyObject.set("id", result.id));
  }
}
