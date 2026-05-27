/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.presentation.http.controllers.consent_record;




// import uim.platform.data.privacy.application.usecases.manage.consent_records;
// import uim.platform.data.privacy.application.dto;
// import uim.platform.data.privacy.domain.types;
// import uim.platform.data.privacy.domain.entities.consent_record;
import uim.platform.data.privacy;

mixin(ShowModule!());

@safe:
class ConsentController : ManageController {
  private ManageConsentRecordsUseCase usecase;

  this(ManageConsentRecordsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    
    router.post("/api/v1/consents", &handleGrant);
    router.get("/api/v1/consents", &handleList);
    router.get("/api/v1/consents/active", &handleListActive);
    router.get("/api/v1/consents/*", &handleGet);
    router.post("/api/v1/consents/revoke", &handleRevoke);
    router.delete_("/api/v1/consents/*", &handleDelete);
  }

  protected void handleGrant(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto j = req.json;
      CreateConsentRecordRequest r;
      r.tenantId = tenantId;
      r.dataSubjectId = j.getString("dataSubjectId");
      r.purpose = j.getString("purpose");
      r.channel = j.getString("channel");
      r.consentText = j.getString("consentText");
      r.version_ = j.getString("version");
      r.ipAddress = j.getString("ipAddress");
      r.expiresAt = jsonLong(j, "expiresAt");

      auto result = usecase.grantConsent(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
            .set("id", result.id)
            .set("message", "Consent granted successfully");

        res.writeJsonBody(resp, 201);
      } else
        writeError(res, 400, result.message);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  override protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto subjectParam = req.headers.get("X-Subject-Filter", "");
      auto purposeParam = req.headers.get("X-Purpose-Filter", "");

      ConsentRecord[] items;
      if (subjectParam.length > 0)
        items = usecase.listConsents(tenantId, DataSubjectId(subjectParam));
      else if (purposeParam.length > 0)
        items = usecase.listConsents(tenantId, purposeParam.to!ProcessingPurpose);
      else
        items = usecase.listConsents(tenantId);

      auto arr = items.map!(e => e.toJson).array.toJson;

      auto resp = Json.emptyObject
          .set("items", arr)
          .set("totalCount", items.length)
          .set("message", "Consent records retrieved successfully");

      res.writeJsonBody(resp, 200);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  override protected void handleListActive(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto subjectParam = req.headers.get("X-Subject-Filter", "");

      ConsentRecord[] items;
      if (subjectParam.length > 0)
        items = usecase.listActiveConsents(tenantId, DataSubjectId(subjectParam));
      else
        items = usecase.listConsents(tenantId);

      auto arr = items.map!(e => e.toJson).array.toJson;

      auto resp = Json.emptyObject
          .set("items", arr)
          .set("totalCount", items.length)
          .set("message", "Active consent records retrieved successfully");

      res.writeJsonBody(resp, 200);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto id = ConsentRecordId(precheck.id);

      auto entry = usecase.getConsent(tenantId, id);
      if (entry.isNull) {
        writeError(res, 404, "Consent record not found");
        return;
      }
      auto resp = entry.toJson
        .set("message", "Consent record retrieved successfully");

      res.writeJsonBody(resp, 200);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  protected void handleRevoke(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto j = req.json;
      RevokeConsentRequest r;
      r.id = ConsentRecordId(precheck.id);
      r.tenantId = tenantId;

      auto result = usecase.revokeConsent(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
            .set("id", result.id)
            .set("message", "Consent revoked successfully");

        res.writeJsonBody(resp, 200);
      } else
        writeError(res, 400, result.message);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
        try {
      auto tenantId = precheck.tenantId;
      auto id = ConsentRecordId(precheck.id);

      usecase.deleteConsent(tenantId, id);
      res.writeJsonBody(Json.emptyObject, 204);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }
}
