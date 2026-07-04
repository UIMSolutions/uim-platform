/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.presentation.http.controllers.data_subject;

// import uim.platform.data.privacy.application.usecases.manage.data_subjects;
// import uim.platform.data.privacy.application.dto;

// import uim.platform.data.privacy.domain.entities.data_subject;
import uim.platform.data.privacy;

mixin(ShowModule!());

@safe:
class DataSubjectController : ManageHttpController {
  private ManageDataSubjectsUseCase usecase;

  this(ManageDataSubjectsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/data-subjects", &handleCreate);
    router.get("/api/v1/data-subjects", &handleList);
    router.get("/api/v1/data-subjects/*", &handleGet);
    router.put("/api/v1/data-subjects/*", &handleUpdate);
    router.delete_("/api/v1/data-subjects/*", &handleDelete);
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    CreateDataSubjectRequest r;
    r.tenantId = tenantId;
    r.displayName = data.getString("displayName");
    r.email = data.getString("email");
    r.externalId = data.getString("externalId");
    r.sourceSystem = data.getString("sourceSystem");
    r.country = data.getString("country");
    r.subjectType = data.getString("subjectType").toDataSubjectType();

    auto result = usecase.createSubject(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Data subject created successfully", "Created", 201, responseData);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto typeParam = req.headers.get("X-Subject-Type", "");

    DataSubject[] items = typeParam.length > 0
      ? usecase.listByType(tenantId, typeParam.toDataSubjectType()) : usecase.listSubjects(
        tenantId);

    auto list = items.map!(item => item.toJson()).array.toJson;

    auto responseData = Json.emptyObject
      .set("count", list.length)
      .set("resources", list);
    return successResponse("Data subject list retrieved successfully", "Retrieved", 200, responseData);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = DataSubjectId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid data subject ID", 400);

    auto entry = usecase.getSubject(tenantId, id);
    if (entry.isNull)
      return errorResponse("Data subject not found", 404);

    auto responseData = entry.toJson();
    return successResponse("Data subject retrieved successfully", "Retrieved", 200, responseData);
  }

  override protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto data = precheck.data;

    UpdateDataSubjectRequest r;
    r.id = DataSubjectId(precheck.id);
    r.tenantId = tenantId;
    r.displayName = data.getString("displayName");
    r.email = data.getString("email");
    r.sourceSystem = data.getString("sourceSystem");
    r.country = data.getString("country");
    r.subjectType = data.getString("subjectType").toDataSubjectType();
    r.isActive = data.getBoolean("isActive", true);

    auto result = usecase.updateSubject(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Data subject updated successfully", "Updated", 200, responseData);
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = DataSubjectId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid data subject ID", 400);

    auto result = usecase.deleteSubject(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Data subject deleted successfully", "Deleted", 200, responseData);
  }
}
