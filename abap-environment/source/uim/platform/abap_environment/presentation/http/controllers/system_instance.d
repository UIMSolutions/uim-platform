/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.abap_environment.presentation.http.controllers.system_instance;

// ^
// 
// import uim.platform.abap_environment.application.usecases.manage.system_instances;
// import uim.platform.abap_environment.application.dto;
// import uim.platform.abap_environment.domain.entities.system_instance;
// import uim.platform.abap_environment.domain.types;

import uim.platform.abap_environment;

mixin(ShowModule!());
@safe:
class SystemInstanceController : ManageController {
  private ManageSystemInstancesUseCase usecase;

  this(ManageSystemInstancesUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/systems", &handleCreate);
    router.get("/api/v1/systems", &handleList);
    router.get("/api/v1/systems/*", &handleGet);
    router.put("/api/v1/systems/*", &handleUpdate);
    router.delete_("/api/v1/systems/*", &handleDelete);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    autp precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto data = precheck.data;

    CreateSystemInstanceRequest request;
    request.tenantId = tenantId;
    request.subaccountId = data.getString("subaccountId");
    request.name = data.getString("name");
    request.description = data.getString("description");
    request.plan = data.getString("plan");
    request.region = data.getString("region");
    request.sapSystemId = data.getString("sapSystemId");
    request.adminEmail = data.getString("adminEmail");
    request.abapRuntimeSize = getUshort(data, "abapRuntimeSize");
    request.hanaMemorySize = getUshort(data, "hanaMemorySize");
    request.softwareVersion = data.getString("softwareVersion");
    request.stackVersion = data.getString("stackVersion");

    auto result = usecase.createInstance(request);
    if (result.hasError())
      return errorResponse(result.message);

    auto responseData = Json.emptyObject
      .set("id", result.id);

    return successResponse("System instance created", "Created", 201, responseData);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto instances = usecase.listInstances(tenantId);
    auto arr = instances.map!(inst => inst.toJson).array.toJson;

    auto responseData = Json.emptyObject
      .set("items", arr)
      .set("totalCount", instances.length);

    return successResponse("System instances retrieved", "Retrieved", 200, responseData);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = SystemInstanceId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid system instance id", 400);

    auto inst = usecase.getInstance(tenantId, id);
    if (inst.isNull)
      return errorResponse("System instance not found", 404);

    return successResponse("System instance retrieved", "Retrieved", 200, inst.toJson);
  }

  override protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = SystemInstanceId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid system instance id", 400);

    auto data = precheck.data;

    UpdateSystemInstanceRequest request;
    request.tenantId = tenantId;
    request.systemInstanceId = id;
    request.description = data.getString("description");
    request.status = data.getString("status");
    request.abapRuntimeSize = getUshort(data, "abapRuntimeSize");
    request.hanaMemorySize = getUshort(data, "hanaMemorySize");
    request.softwareVersion = data.getString("softwareVersion");

    auto result = usecase.updateInstance(request);
    if (result.hasError())
      return errorResponse(result.message);

    return successResponse("System instance updated", "Updated", 200);
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = SystemInstanceId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid system instance id", 400);

    auto result = usecase.deleteInstance(tenantId, id);
    if (result.hasError())
      return errorResponse(result.message);

    return successResponse("System instance deleted", "Deleted", 200);
  }
}
