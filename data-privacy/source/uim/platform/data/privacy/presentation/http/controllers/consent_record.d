/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.presentation.http.controllers.consent_record;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
// import std.conv : to;

// import uim.platform.data.privacy.application.usecases.manage.consent_records;
// import uim.platform.data.privacy.application.dto;
// import uim.platform.data.privacy.domain.types;
// import uim.platform.data.privacy.domain.entities.consent_record;
import uim.platform.data.privacy;

mixin(ShowModule!());

@safe:
class ConsentController : PlatformController {
  private ManageConsentRecordsUseCase uc;

  this(ManageConsentRecordsUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    
    router.post("/api/v1/consents", &handleGrant);
    router.get("/api/v1/consents", &handleList);
    router.get("/api/v1/consents/active", &handleListActive);
    router.get("/api/v1/consents/*", &handleGetById);
    router.post("/api/v1/consents/revoke", &handleRevoke);
    router.delete_("/api/v1/consents/*", &handleDelete);
  }

  private void handleGrant(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      CreateConsentRecordRequest r;
      r.tenantId = req.getTenantId;
      r.dataSubjectId = j.getString("dataSubjectId");
      r.purpose = parsePurpose(j.getString("purpose"));
      r.channel = j.getString("channel");
      r.consentText = j.getString("consentText");
      r.version_ = j.getString("version");
      r.ipAddress = j.getString("ipAddress");
      r.expiresAt = jsonLong(j, "expiresAt");

      auto result = uc.grantConsent(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
            .set("id", Json(result.id))
            .set("message", "Consent granted successfully");

        res.writeJsonBody(resp, 201);
      } else
        writeError(res, 400, result.error);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      TenantId tenantId = req.getTenantId;
      auto subjectParam = req.headers.get("X-Subject-Filter", "");
      auto purposeParam = req.headers.get("X-Purpose-Filter", "");

      ConsentRecord[] items;
      if (subjectParam.length > 0)
        items = uc.listByDataSubject(tenantId, subjectParam);
      else if (purposeParam.length > 0)
        items = uc.listByPurpose(tenantId, parsePurpose(purposeParam));
      else
        items = uc.listConsents(tenantId);

      auto arr = items.map!(e => serialize(e)).array.toJson;

      auto resp = Json.emptyObject
          .set("items", arr)
          .set("totalCount", Json(items.length))
          .set("message", "Consent records retrieved successfully");

      res.writeJsonBody(resp, 200);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private void handleListActive(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      TenantId tenantId = req.getTenantId;
      auto subjectParam = req.headers.get("X-Subject-Filter", "");

      ConsentRecord[] items;
      if (subjectParam.length > 0)
        items = uc.listActiveConsents(tenantId, subjectParam);
      else
        items = uc.listConsents(tenantId);

      auto arr = items.map!(e => serialize(e)).array.toJson;

      auto resp = Json.emptyObject
          .set("items", arr)
          .set("totalCount", Json(items.length))
          .set("message", "Active consent records retrieved successfully");

      res.writeJsonBody(resp, 200);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private void handleGetById(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto id = extractIdFromPath(req.requestURI);
      TenantId tenantId = req.getTenantId;
      auto entry = uc.getConsent(tenantId, id);
      if (entry.isNull) {
        writeError(res, 404, "Consent record not found");
        return;
      }
      res.writeJsonBody(entry.toJson, 200);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private void handleRevoke(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      RevokeConsentRequest r;
      r.id = j.getString("id");
      r.tenantId = req.getTenantId;

      auto result = uc.revokeConsent(r);
      if (result.isSuccess()) {
        auto resp = Json.emptyObject
            .set("id", Json(result.id))
            .set("message", "Consent revoked successfully");

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
      uc.deleteConsent(tenantId, id);
      res.writeJsonBody(Json.emptyObject, 204);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private static Json serialize(const ConsentRecord e) {
    auto cats = Json.emptyArray;
    foreach (c; e.categories)
      cats ~= Json(c.to!string);
    
    return Json.emptyObject
    .set("id", e.id)
    .set("tenantId", e.tenantId)
    .set("dataSubjectId", e.dataSubjectId)
    .set("purpose", e.purpose.to!string)
    .set("status", e.status.to!string)
    .set("channel", e.channel)
    .set("consentText", e.consentText)
    .set("version", e.version_)
    .set("ipAddress", e.ipAddress)
    .set("grantedAt", e.grantedAt)
    .set("revokedAt", e.revokedAt)
    .set("expiresAt", e.expiresAt)
    .set("createdAt", e.createdAt)
    .set("categories", cats);
  }

  private static ProcessingPurpose parsePurpose(string purpose) {
    switch (purpose) {
    case "serviceDelivery":
      return ProcessingPurpose.serviceDelivery;
    case "marketing":
      return ProcessingPurpose.marketing;
    case "analytics":
      return ProcessingPurpose.analytics;
    case "compliance":
      return ProcessingPurpose.compliance;
    case "humanResources":
      return ProcessingPurpose.humanResources;
    case "customerSupport":
      return ProcessingPurpose.customerSupport;
    case "billing":
      return ProcessingPurpose.billing;
    case "security":
      return ProcessingPurpose.security;
    case "research":
      return ProcessingPurpose.research;
    default:
      return ProcessingPurpose.serviceDelivery;
    }
  }
}
