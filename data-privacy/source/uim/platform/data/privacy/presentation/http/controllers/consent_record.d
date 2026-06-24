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

// mixin(ShowModule!());

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
    r.tenantId = tenantId;
    r.dataSubjectId = data.getString("dataSubjectId");
    r.purpose = data.getString("purpose");
    r.channel = data.getString("channel");
    r.consentText = data.getString("consentText");
    r.version_ = data.getString("version");
    r.ipAddress = data.getString("ipAddress");
    r.expiresAt = data.getLong("expiresAt");

    auto result = usecase.grantConsent(r);
    if (result.hasError)
      return errorResponse("", 0);

      auto responseData = Json.emptyObject
        .set("id", result.id)
        .set("message", "Consent granted successfully");
      return successResponse("Consent granted successfully", "Created", 201, responseData);
  }

  mixin(HandleTemplate!("handleGrant", "grantHandler"));

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

  mixin(HandleTemplate!("handleListActive", "listActiveHandler"));

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

    auto tenantId = precheck.tenantId; // Assuming tenantId is passed in the request data for revocation
    auto id = ConsentRecordId(precheck.id); // Assuming the ID is passed in the request data for revocation
    if (id.isNull)
      return errorResponse("Invalid consent record ID", 400);

    RevokeConsentRequest r;
    r.tenantId = tenantId;
    r.id = id;

    auto result = usecase.revokeConsent(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Consent revoked successfully", "Updated", 200, responseData);
  }

  mixin(HandleTemplate!("handleRevoke", "revokeHandler"));

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = ConsentRecordId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid consent record ID", 400);

    auto result = usecase.deleteConsent(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Consent deleted successfully", "Deleted", 200, responseData);
  }
}
