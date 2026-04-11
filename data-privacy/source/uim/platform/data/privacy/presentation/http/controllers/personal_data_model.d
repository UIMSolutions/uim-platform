/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.presentation.http.controllers.personal_data_model;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
// import std.conv : to;

// import uim.platform.data.privacy.application.usecases.manage.personal_data_models;
// import uim.platform.data.privacy.application.dto;
// import uim.platform.data.privacy.domain.types;
// import uim.platform.data.privacy.domain.entities.personal_data_model;
import uim.platform.data.privacy;

mixin(ShowModule!());

@safe:
class PersonalDataModelController : PlatformController {
  private ManagePersonalDataModelsUseCase uc;

  this(ManagePersonalDataModelsUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    
    router.post("/api/v1/personal-data-models", &handleCreate);
    router.get("/api/v1/personal-data-models", &handleList);
    router.get("/api/v1/personal-data-models/special", &handleListSpecial);
    router.get("/api/v1/personal-data-models/*", &handleGetById);
    router.put("/api/v1/personal-data-models/*", &handleUpdate);
    router.delete_("/api/v1/personal-data-models/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      CreatePersonalDataModelRequest r;
      r.tenantId = req.getTenantId;
      r.fieldName = j.getString("fieldName");
      r.fieldDescription = j.getString("fieldDescription");
      r.category = parseCategory(j.getString("category"));
      r.sensitivity = parseSensitivity(j.getString("sensitivity"));
      r.sourceSystem = j.getString("sourceSystem");
      r.sourceEntity = j.getString("sourceEntity");
      r.subjectType = parseSubjectType(j.getString("subjectType"));
      r.isSpecialCategory = j.getBoolean("isSpecialCategory");
      r.legalReference = j.getString("legalReference");

      auto result = uc.createModel(r);
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
      auto catParam = req.headers.get("X-Category-Filter", "");

      PersonalDataModel[] items;
      if (catParam.length > 0)
        items = uc.listByCategory(tenantId, parseCategory(catParam));
      else
        items = uc.listModels(tenantId);

      auto arr = Json.emptyArray;
      foreach (e; items)
        arr ~= serialize(e);

      auto resp = Json.emptyObject;
      resp["items"] = arr;
      resp["totalCount"] = Json(cast(long) items.length);
      res.writeJsonBody(resp, 200);
    }
    catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private void handleListSpecial(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      TenantId tenantId = req.getTenantId;
      auto items = uc.listSpecialCategories(tenantId);

      auto arr = Json.emptyArray;
      foreach (e; items)
        arr ~= serialize(e);

      auto resp = Json.emptyObject;
      resp["items"] = arr;
      resp["totalCount"] = Json(cast(long) items.length);
      res.writeJsonBody(resp, 200);
    }
    catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private void handleGetById(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      TenantId tenantId = req.getTenantId;
      auto entry = uc.getModel(tenantId, id);
      if (entry is null) {
        writeError(res, 404, "Personal data model not found");
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
      UpdatePersonalDataModelRequest r;
      r.id = extractIdFromPath(req.requestURI);
      r.tenantId = req.getTenantId;
      r.fieldName = j.getString("fieldName");
      r.fieldDescription = j.getString("fieldDescription");
      r.category = parseCategory(j.getString("category"));
      r.sensitivity = parseSensitivity(j.getString("sensitivity"));
      r.sourceSystem = j.getString("sourceSystem");
      r.sourceEntity = j.getString("sourceEntity");
      r.isSpecialCategory = j.getBoolean("isSpecialCategory");
      r.legalReference = j.getString("legalReference");

      auto result = uc.updateModel(r);
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
      uc.deleteModel(tenantId, id);
      res.writeJsonBody(Json.emptyObject, 204);
    }
    catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private static Json serialize(const PersonalDataModel e) {
    auto j = Json.emptyObject;
    j["id"] = Json(e.id);
    j["tenantId"] = Json(e.tenantId);
    j["fieldName"] = Json(e.fieldName);
    j["fieldDescription"] = Json(e.fieldDescription);
    j["category"] = Json(e.category.to!string);
    j["sensitivity"] = Json(e.sensitivity.to!string);
    j["sourceSystem"] = Json(e.sourceSystem);
    j["sourceEntity"] = Json(e.sourceEntity);
    j["subjectType"] = Json(e.subjectType.to!string);
    j["isSpecialCategory"] = Json(e.isSpecialCategory);
    j["legalReference"] = Json(e.legalReference);
    j["createdAt"] = Json(e.createdAt);
    j["updatedAt"] = Json(e.updatedAt);
    return j;
  }

  private static PersonalDataCategory parseCategory(string s) {
    switch (s) {
    case "identification":
      return PersonalDataCategory.identification;
    case "contact":
      return PersonalDataCategory.contact;
    case "financial":
      return PersonalDataCategory.financial;
    case "health":
      return PersonalDataCategory.health;
    case "biometric":
      return PersonalDataCategory.biometric;
    case "ethnic":
      return PersonalDataCategory.ethnic;
    case "political":
      return PersonalDataCategory.political;
    case "religious":
      return PersonalDataCategory.religious;
    case "tradeUnion":
      return PersonalDataCategory.tradeUnion;
    case "genetic":
      return PersonalDataCategory.genetic;
    case "criminal":
      return PersonalDataCategory.criminal;
    case "location":
      return PersonalDataCategory.location;
    case "behavioral":
      return PersonalDataCategory.behavioral;
    default:
      return PersonalDataCategory.identification;
    }
  }

  private static DataSensitivity parseSensitivity(string s) {
    switch (s) {
    case "sensitive":
      return DataSensitivity.sensitive;
    case "highlyConfidential":
      return DataSensitivity.highlyConfidential;
    default:
      return DataSensitivity.standard;
    }
  }

  private static DataSubjectType parseSubjectType(string s) {
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
