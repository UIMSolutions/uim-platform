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
  private ManageConsentPurposesUseCase usecase;

  this(ManageConsentPurposesUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);

    router.post("/api/v1/consent-purposes", &handleCreate);
    router.get("/api/v1/consent-purposes", &handleList);
    router.get("/api/v1/consent-purposes/*", &handleGet);
    router.put("/api/v1/consent-purposes/*", &handleUpdate);
    router.delete_("/api/v1/consent-purposes/*", &handleDelete);
  }

  protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto j = req.json;
      CreateConsentPurposeRequest r;
      r.tenantId = tenantId;
      r.controllerId = DataControllerId(j.getString("controllerId"));
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.purpose = j.getString("purpose").to!ProcessingPurpose;
      r.dataCategories = getStrings(j, "dataCategories").map!(c => c.to!PersonalDataCategory).array.toJson;
      r.consentFormTemplate = j.getString("consentFormTemplate");
      r.version_ = j.getString("version");
      r.requiresExplicitConsent = j.getBoolean("requiresExplicitConsent", true);
      r.validFrom = jsonLong(j, "validFrom");
      r.validUntil = jsonLong(j, "validUntil");

      auto result = usecase.createPurpose(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
            .set("id", result.id)
            .set("message", "Consent purpose created successfully");
            
        res.writeJsonBody(resp, 201);
      } else
        writeError(res, 400, result.error);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  protected void handleGetList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      
      auto items = usecase.listPurposes(tenantId);
      auto arr = items.map!(e => e.toJson).array.toJson;

      auto resp = Json.emptyObject
          .set("items", arr)
          .set("totalCount", items.length)
          .set("message", "Consent purposes retrieved successfully");

      res.writeJsonBody(resp, 200);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto id = ConsentPurposeId(extractIdFromPath(req.requestURI));
      auto tenantId = req.getTenantId;
      auto entry = usecase.getPurpose(tenantId, id);
      if (entry.isNull) {
        writeError(res, 404, "Consent purpose not found");
        return;
      }
      res.writeJsonBody(entry.toJson, 200);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto j = req.json;
      UpdateConsentPurposeRequest r;
      r.id = extractIdFromPath(req.requestURI);
      r.tenantId = tenantId;
      r.name = j.getString("name");
      r.description = j.getString("description");
      r.consentFormTemplate = j.getString("consentFormTemplate");
      r.version_ = j.getString("version");
      r.requiresExplicitConsent = j.getBoolean("requiresExplicitConsent", true);

      auto result = usecase.updatePurpose(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
          .set("id", result.id);
          
        res.writeJsonBody(resp, 200);
      } else
        writeError(res, 400, result.error);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = req.getTenantId;
      auto id = ConsentPurposeId(extractIdFromPath(req.requestURI));
      auto tenantId = req.getTenantId;
      usecase.deletePurpose(tenantId, id);
      res.writeJsonBody(Json.emptyObject, 204);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

}
