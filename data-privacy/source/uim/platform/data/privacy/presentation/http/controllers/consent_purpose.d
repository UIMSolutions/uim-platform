/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.presentation.http.controllers.consent_purpose;

// import uim.platform.data.privacy.application.usecases.manage.consent_purposes;
// import uim.platform.data.privacy.application.dto;
// import uim.platform.data.privacy.domain.types;
// import uim.platform.data.privacy.domain.entities.consent_purpose;
import uim.platform.data.privacy;

mixin(ShowModule!());

@safe:
class ConsentPurposeController : PlatformController {
  private ManageConsentPurposesUseCase uc;

  this(ManageConsentPurposesUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    
    router.post("/api/v1/consent-purposes", &handleCreate);
    router.get("/api/v1/consent-purposes", &handleList);
    router.get("/api/v1/consent-purposes/*", &handleGetById);
    router.put("/api/v1/consent-purposes/*", &handleUpdate);
    router.delete_("/api/v1/consent-purposes/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      CreateConsentPurposeRequest r;
      r.tenantId = req.getTenantId;
      r.controllerId = j.getString("controllerId");
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.purpose = j.getString("purpose");
      r.dataCategories = jsonStrArray(j, "dataCategories");
      r.consentFormTemplate = j.getString("consentFormTemplate");
      r.version_ = j.getString("version");
      r.requiresExplicitConsent = j.getBoolean("requiresExplicitConsent", true);
      r.validFrom = jsonLong(j, "validFrom");
      r.validUntil = jsonLong(j, "validUntil");

      auto result = uc.createPurpose(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        res.writeJsonBody(resp, 201);
      } else
        writeError(res, 400, result.error);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      TenantId tenantId = req.getTenantId;
      auto items = uc.listPurposes(tenantId);

      auto arr = Json.emptyArray;
      foreach (e; items)
        arr ~= serialize(e);

      auto resp = Json.emptyObject;
      resp["items"] = arr;
      resp["totalCount"] = Json(items.length);
      res.writeJsonBody(resp, 200);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private void handleGetById(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      TenantId tenantId = req.getTenantId;
      auto entry = uc.getPurpose(tenantId, id);
      if (entry is null) {
        writeError(res, 404, "Consent purpose not found");
        return;
      }
      res.writeJsonBody(serialize(*entry), 200);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      UpdateConsentPurposeRequest r;
      r.id = extractIdFromPath(req.requestURI);
      r.tenantId = req.getTenantId;
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.consentFormTemplate = j.getString("consentFormTemplate");
      r.version_ = j.getString("version");
      r.requiresExplicitConsent = j.getBoolean("requiresExplicitConsent", true);

      auto result = uc.updatePurpose(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject;
        resp["id"] = Json(result.id);
        res.writeJsonBody(resp, 200);
      } else
        writeError(res, 400, result.error);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      TenantId tenantId = req.getTenantId;
      uc.deletePurpose(tenantId, id);
      res.writeJsonBody(Json.emptyObject, 204);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private static Json serialize(const ConsentPurpose e) {
    auto j = Json.emptyObject;
    j["id"] = Json(e.id);
    j["tenantId"] = Json(e.tenantId);
    j["controllerId"] = Json(e.controllerId);
    j["name"] = Json(e.name);
    j["description"] = Json(e.description);
    j["purpose"] = Json(e.purpose);
    j["status"] = Json(e.status.to!string);
    j["consentFormTemplate"] = Json(e.consentFormTemplate);
    j["version"] = Json(e.version_);
    j["requiresExplicitConsent"] = Json(e.requiresExplicitConsent);
    j["validFrom"] = Json(e.validFrom);
    j["validUntil"] = Json(e.validUntil);
    j["createdAt"] = Json(e.createdAt);
    j["updatedAt"] = Json(e.updatedAt);

    auto cats = Json.emptyArray;
    foreach (c; e.dataCategories) cats ~= Json(c);
    j["dataCategories"] = cats;

    return j;
  }
}
