/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.presentation.http.controllers.business_subprocess;
// import uim.platform.data.privacy.application.usecases.manage.business_subprocesses;
// import uim.platform.data.privacy.application.dto;

// import uim.platform.data.privacy.domain.entities.business_subprocess;
import uim.platform.data.privacy;
mixin(ShowModule!());

@safe:
class BusinessSubprocessController : ManageHttpController {
  private ManageBusinessSubprocessesUseCase usecase;

  this(ManageBusinessSubprocessesUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/business-subprocesses", &handleCreate);
    router.get("/api/v1/business-subprocesses", &handleList);
    router.get("/api/v1/business-subprocesses/*", &handleGet);
    router.put("/api/v1/business-subprocesses/*", &handleUpdate);
    router.delete_("/api/v1/business-subprocesses/*", &handleDelete);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    CreateBusinessSubprocessRequest r;
    r.tenantId = tenantId;
    r.parentProcessId = BusinessProcessId(data.getString("parentProcessId"));
    r.name = data.getString("name");
    r.description = data.getString("description");
    r.purposes = data.getStrings("purposes");
    r.dataCategories = data.getStrings("dataCategories");
    r.owner = data.getString("owner");

    auto result = usecase.createSubprocess(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Business subprocess created successfully", "Created", 201, responseData);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto items = usecase.listSubprocesses(tenantId);
    auto list = items.map!(item => item.toJson()).array.toJson;

    auto responseData = Json.emptyObject
      .set("count", list.length)
      .set("resources", list);
    return successResponse("Business subprocess list retrieved successfully", "Retrieved", 200, responseData);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = BusinessSubprocessId(precheck.id);

    auto entry = usecase.getSubprocess(tenantId, id);
    if (entry.isNull)
      return errorResponse("Business subprocess not found", 404);

    auto responseData = entry.toJson();
    return successResponse("Business subprocess retrieved successfully", "Retrieved", 200, responseData);
  }

  override protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto data = precheck.data;
    
    UpdateBusinessSubprocessRequest r;
    r.tenantId = tenantId;
    r.subprocessId = BusinessSubprocessId(precheck.id);
    r.name = data.getString("name");
    r.description = data.getString("description");
    r.purposes = data.getStrings("purposes");
    r.dataCategories = data.getStrings("dataCategories");
    r.owner = data.getString("owner");

    auto result = usecase.updateSubprocess(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Business subprocess updated successfully", "Updated", 200, responseData);
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = BusinessSubprocessId(precheck.id);

    auto result = usecase.deleteSubprocess(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Business subprocess deleted successfully", "Deleted", 200, responseData);
  }
}
