/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.presentation.http.controllers.legal_ground;

// import vibe.http.server;
// import vibe.http.router;
// import vibe.data.json;
// import std.conv : to;

// import uim.platform.data.privacy.application.usecases.manage.legal_grounds;
// import uim.platform.data.privacy.application.dto;
// import uim.platform.data.privacy.domain.types;
// import uim.platform.data.privacy.domain.entities.legal_ground;
import uim.platform.data.privacy;

mixin(ShowModule!());

@safe:
class LegalGroundController : PlatformController {
  private ManageLegalGroundsUseCase uc;

  this(ManageLegalGroundsUseCase uc) {
    this.uc = uc;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    
    router.post("/api/v1/legal-grounds", &handleCreate);
    router.get("/api/v1/legal-grounds", &handleList);
    router.get("/api/v1/legal-grounds/*", &handleGetById);
    router.put("/api/v1/legal-grounds/*", &handleUpdate);
    router.delete_("/api/v1/legal-grounds/*", &handleDelete);
  }

  private void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto j = req.json;
      CreateLegalGroundRequest r;
      r.tenantId = req.getTenantId;
      r.dataSubjectId = j.getString("dataSubjectId");
      r.basis = parseLegalBasis(j.getString("basis"));
      r.purpose = parsePurpose(j.getString("purpose"));
      r.description = j.getString("description");
      r.legalReference = j.getString("legalReference");
      r.validFrom = jsonLong(j, "validFrom");
      r.validUntil = jsonLong(j, "validUntil");

      auto result = uc.createGround(r);
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
      auto basisParam = req.headers.get("X-Basis-Filter", "");
      auto purposeParam = req.headers.get("X-Purpose-Filter", "");
      auto subjectParam = req.headers.get("X-Subject-Filter", "");

      LegalGround[] items;
      if (basisParam.length > 0)
        items = uc.listByBasis(tenantId, parseLegalBasis(basisParam));
      else if (purposeParam.length > 0)
        items = uc.listByPurpose(tenantId, parsePurpose(purposeParam));
      else if (subjectParam.length > 0)
        items = uc.listByDataSubject(tenantId, subjectParam);
      else
        items = uc.listGrounds(tenantId);

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
      auto entry = uc.getGround(tenantId, id);
      if (entry is null) {
        writeError(res, 404, "Legal ground not found");
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
      UpdateLegalGroundRequest r;
      r.id = extractIdFromPath(req.requestURI);
      r.tenantId = req.getTenantId;
      r.description = j.getString("description");
      r.legalReference = j.getString("legalReference");
      r.isActive = j.getBoolean("isActive", true);
      r.validUntil = jsonLong(j, "validUntil");

      auto result = uc.updateGround(r);
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
      uc.deleteGround(tenantId, id);
      res.writeJsonBody(Json.emptyObject, 204);
    }
    catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  private static Json serialize(const LegalGround e) {
    auto cats = Json.emptyArray;
    foreach (c; e.categories)
      cats ~= Json(c.to!string);

    return Json.emptyObject
      .set("id", e.id)
      .set("tenantId", e.tenantId)
      .set("dataSubjectId", e.dataSubjectId)
      .set("basis", e.basis.to!string)
      .set("purpose", e.purpose.to!string)
      .set("description", e.description)
      .set("legalReference", e.legalReference)
      .set("isActive", e.isActive)
      .set("validFrom", e.validFrom)
      .set("validUntil", e.validUntil)
      .set("createdAt", e.createdAt)
      .set("categories", cats);
  }

  private static LegalBasis parseLegalBasis(string basis) {
    switch (basis) {
    case "consent":
      return LegalBasis.consent;
    case "contract":
      return LegalBasis.contract;
    case "legalObligation":
      return LegalBasis.legalObligation;
    case "vitalInterest":
      return LegalBasis.vitalInterest;
    case "publicTask":
      return LegalBasis.publicTask;
    case "legitimateInterest":
      return LegalBasis.legitimateInterest;
    default:
      return LegalBasis.consent;
    }
  }

  private static ProcessingPurpose parsePurpose(string s) {
    switch (s) {
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
