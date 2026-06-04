/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.presentation.http.controllers.consent_record;

// import uim.platform.data.privacy.application.usecases.manage.consent_records;
// import uim.platform.data.privacy.application.dto;

// import uim.platform.data.privacy.domain.entities.consent_record;
import uim.platform.data.privacy;

mixin(ShowModule!());

@safe:
class ConsentController : ManageHttpController {
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

  protected Json grantHandler(HTTPServerRequest req) {
    auto precheck = super.postHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto data = precheck.data;
    CreateConsentRecordRequest r;
    r.tenantId = precheck.tenantId;
    r.dataSubjectId = data.getString("dataSubjectId");
    r.purpose = data.getString("purpose");
    r.channel = data.getString("channel");
    r.consentText = data.getString("consentText");
    r.version_ = data.getString("version");
    r.ipAddress = data.getString("ipAddress");
    r.expiresAt = data.getLong("expiresAt");

    auto result = usecase.grantConsent(r);
    if (result.isSuccess()) {
      auto responseData = Json.emptyObject
        .set("id", result.id)
        .set("message", "Consent granted successfully");
      return successResponse("Consent granted successfully", "Created", 201, responseData);
    } else
      return errorResponse(result.message, 400);
  }

  protected void handleGrant(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto response = grantHandler(req);
      res.writeJsonBody(response, response.code);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

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

    auto list = items.map!(item => item.toJson()).array.toJson;

    auto responseData = Json.emptyObject
      .set("count", list.length)
      .set("resources", list);
    return successResponse("Consent record list retrieved successfully", "Retrieved", 200, responseData);
  }

  protected Json listActiveHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto subjectParam = req.headers.get("X-Subject-Filter", "");

    ConsentRecord[] items = subjectParam.length > 0
      ? usecase.listActiveConsents(tenantId, DataSubjectId(subjectParam)) 
      : usecase.listActiveConsents(tenantId);

    auto list = items.map!(item => item.toJson()).array.toJson;

    auto responseData = Json.emptyObject
      .set("count", list.length)
      .set("resources", list);
    return successResponse("Active consent record list retrieved successfully", "Retrieved", 200, responseData);
  }

  protected void handleListActive(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto response = listActiveHandler(req);
      res.writeJsonBody(response, response.code);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = ConsentRecordId(precheck.id);

    auto entry = usecase.getConsent(tenantId, id);
    if (entry.isNull)
      return errorResponse("Consent record not found", 404);

    auto responseData = entry.toJson();
    return successResponse("Consent record retrieved successfully", "Retrieved", 200, responseData);
  }

  protected Json revokeHandler(HTTPServerRequest req) {
    auto precheck = super.postHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto data = precheck.data;
    RevokeConsentRequest r;
    r.id = ConsentRecordId(precheck.id);
    r.tenantId = precheck.tenantId;

    auto result = usecase.revokeConsent(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Consent revoked successfully", "Updated", 200, responseData);
  }

  protected void handleRevoke(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto response = revokeHandler(req);
      res.writeJsonBody(response, response.code);
    } catch (Exception e)
      writeError(res, 500, "Internal server error");
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = ConsentRecordId(precheck.id);

    auto result = usecase.deleteConsent(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Consent deleted successfully", "Deleted", 200, responseData);
  }
}
