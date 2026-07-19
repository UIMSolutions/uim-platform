/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.presentation.http.controllers.business_process;
// import uim.platform.data.privacy.application.usecases.manage.business_processes;
// import uim.platform.data.privacy.application.dto;

// import uim.platform.data.privacy.domain.entities.business_process;
import uim.platform.data.privacy;

mixin(ShowModule!());

@safe:
class BusinessProcessController : ManageHttpController {
  private ManageBusinessProcessesUseCase usecase;

  this(ManageBusinessProcessesUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/business-processes", &handleCreate);
    router.get("/api/v1/business-processes", &handleList);
    router.get("/api/v1/business-processes/*", &handleGet);
    router.put("/api/v1/business-processes/*", &handleUpdate);
    router.delete_("/api/v1/business-processes/*", &handleDelete);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    CreateBusinessProcessRequest r;
    r.tenantId = tenantId;
    r.name = data.getString("name");
    r.description = data.getString("description");
    r.controllerId = data.getString("controllerId");
    r.purposes = data.getStrings("purposes");
    r.legalBases = data.getStrings("legalBases");
    r.owner = data.getString("owner");

    auto result = usecase.createProcess(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Business process created successfully", "Created", 201, responseData);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto items = usecase.listProcesses(tenantId);
    auto list = items.map!(item => item.toJson()).array.toJson;

    auto responseData = Json.emptyObject
      .set("count", list.length)
      .set("resources", list);
    return successResponse("Business process list retrieved successfully", "Retrieved", 200, responseData);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = BusinessProcessId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid business process ID", 400);

    auto entry = usecase.getProcess(tenantId, id);
    if (entry.isNull)
      return errorResponse("Business process not found", 404);

    auto responseData = entry.toJson();
    return successResponse("Business process retrieved successfully", "Retrieved", 200, responseData);
  }

  override protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto data = precheck.data;

    UpdateBusinessProcessRequest r;
    r.processId = BusinessProcessId(precheck.id);
    r.tenantId = tenantId;
    r.name = data.getString("name");
    r.description = data.getString("description");
    r.purposes = data.getStrings("purposes");
    r.legalBases = data.getStrings("legalBases");
    r.owner = data.getString("owner");

    auto result = usecase.updateProcess(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Business process updated successfully", "Updated", 200, responseData);
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = BusinessProcessId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid business process ID", 400);

    auto result = usecase.deleteProcess(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Business process deleted successfully", "Deleted", 200, responseData);
  }
}
