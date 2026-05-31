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
class DataSubjectController : ManageController {
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
    ScanJobDTO dto;
    dto.tenantId = tenantId;
    CreateDataSubjectRequest r;
    r.tenantId = tenantId;
    r.displayName = data.getString("displayName");
    r.email = data.getString("email");
    r.externalId = data.getString("externalId");
    r.sourceSystem = data.getString("sourceSystem");
    r.country = data.getString("country");
    r.subjectType = parseSubjectType(data.getString("subjectType"));

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
      ? usecase.listByType(tenantId, parseSubjectType(typeParam)) : usecase.listSubjects(
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

    auto entry = usecase.getSubject(tenantId, id);
    if (item.isNull)
      return errorResponse("Scan job not found", 404);

    auto responseData = serialize(entry);
    return successResponse("Data subject retrieved successfully", "Retrieved", 200, responseData);
  }

  override protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    UpdateDataSubjectRequest r;
    r.id = DataSubjectId(precheck.id);
    r.tenantId = tenantId;
    r.displayName = data.getString("displayName");
    r.email = data.getString("email");
    r.sourceSystem = data.getString("sourceSystem");
    r.country = data.getString("country");
    r.subjectType = parseSubjectType(data.getString("subjectType"));
    r.isActive = data.getBoolean("isActive", true);

    auto result = usecase.updateSubject(r);
    if (result.isSuccess()) {
      auto resp = Json.emptyObject
        .set("id", result.id)
        .set("message", "Data subject updated successfully");

      res.writeJsonBody(resp, 200);
    } else
      writeError(res, 400, result.message);
  }
 catch (Exception e)
    writeError(res, 500, "Internal server error");
}

override protected Json deleteHandler(HTTPServerRequest req) {
  auto precheck = super.deleteHandler(req);
  if (precheck.hasError)
    return precheck;

  auto tenantId = precheck.tenantId;
  auto id = DataSubjectId(precheck.id);

  usecase.deleteSubject(tenantId, id);
  res.writeJsonBody(Json.emptyObject, 204);
}
 catch (Exception e)
  writeError(res, 500, "Internal server error");
}

private static Json serialize(const DataSubject e) {
  return Json.emptyObject
    .set("id", e.id)
    .set("tenantId", e.tenantId)
    .set("subjectType", e.subjectType.to!string)
    .set("externalId", e.externalId)
    .set("displayName", e.displayName)
    .set("email", e.email)
    .set("sourceSystem", e.sourceSystem)
    .set("country", e.country)
    .set("isActive", e.isActive)
    .set("createdAt", e.createdAt)
    .set("updatedAt", e.updatedAt);
}

private static DataSubjectType parseSubjectType(string type) {
  switch (type) {
  case "employee":
    return DataSubjectType.employee;
  case "customer":
    return DataSubjectType.customer;
  case "vendor":
    return DataSubjectType.vendor;
  case "partner":
    return DataSubjectType.partner;
  case "applicant":
    return DataSubjectType.applicant;
  default:
    return DataSubjectType.naturalPerson;
  }
}
}
