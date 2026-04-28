/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.presentation.http.controllers.data_subject;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
// import std.conv : to;

// import uim.platform.data.privacy.application.usecases.manage.data_subjects;
// import uim.platform.data.privacy.application.dto;
// import uim.platform.data.privacy.domain.types;
// import uim.platform.data.privacy.domain.entities.data_subject;
import uim.platform.data.privacy;

mixin(ShowModule!());

@safe:
class DataSubjectController : PlatformController {
  private ManageDataSubjectsUseCase uc;

  this(ManageDataSubjectsUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    
    router.post("/api/v1/data-subjects", &handleCreate);
    router.get("/api/v1/data-subjects", &handleList);
    router.get("/api/v1/data-subjects/*", &handleGetById);
    router.put("/api/v1/data-subjects/*", &handleUpdate);
    router.delete_("/api/v1/data-subjects/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      CreateDataSubjectRequest r;
      r.tenantId = req.getTenantId;
      r.displayName = j.getString("displayName");
      r.email = j.getString("email");
      r.externalId = j.getString("externalId");
      r.sourceSystem = j.getString("sourceSystem");
      r.country = j.getString("country");
      r.subjectType = parseSubjectType(j.getString("subjectType"));

      auto result = uc.createSubject(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        res.writeJsonBody(resp, 201);
      }
      else
        writeError(res, 400, result.error);
    }
    catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      TenantId tenantId = req.getTenantId;
      auto typeParam = req.headers.get("X-Subject-Type", "");

      DataSubject[] items;
      if (typeParam.length > 0)
        items = uc.listByType(tenantId, parseSubjectType(typeParam));
      else
        items = uc.listSubjects(tenantId);

      auto arr = Json.emptyArray;
      foreach (e; items)
        arr ~= serialize(e);

      auto resp = Json.emptyObject;
      resp["items"] = arr;
      resp["totalCount"] = Json(items.length);
      res.writeJsonBody(resp, 200);
    }
    catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private void handleGetById(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      TenantId tenantId = req.getTenantId;
      auto entry = uc.getSubject(tenantId, id);
      if (entry.isNull) {
        writeError(res, 404, "Data subject not found");
        return;
      }
      res.writeJsonBody(serialize(*entry), 200);
    }
    catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      UpdateDataSubjectRequest r;
      r.id = extractIdFromPath(req.requestURI);
      r.tenantId = req.getTenantId;
      r.displayName = j.getString("displayName");
      r.email = j.getString("email");
      r.sourceSystem = j.getString("sourceSystem");
      r.country = j.getString("country");
      r.subjectType = parseSubjectType(j.getString("subjectType"));
      r.isActive = j.getBoolean("isActive", true);

      auto result = uc.updateSubject(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        res.writeJsonBody(resp, 200);
      }
      else
        writeError(res, 400, result.error);
    }
    catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      TenantId tenantId = req.getTenantId;
      uc.deleteSubject(tenantId, id);
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
    switch (s) {
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
