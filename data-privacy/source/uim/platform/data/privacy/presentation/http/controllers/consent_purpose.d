/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.presentation.http.controllers.consent_purpose;
// import uim.platform.data.privacy.application.usecases.manage.consent_purposes;
// import uim.platform.data.privacy.application.dto;

// import uim.platform.data.privacy.domain.entities.consent_purpose;
import uim.platform.data.privacy;

mixin(ShowModule!());

@safe:
class ConsentPurposeController : ManageController {
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

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    ScanJobDTO dto;
    dto.tenantId = tenantId;
    CreateConsentPurposeRequest r;
    r.tenantId = tenantId;
    r.controllerId = DataControllerId(data.getString("controllerId"));
    r.name = data.getString("name");
    r.description = data.getString("description");
    r.purpose = data.getString("purpose");
    r.dataCategories = data.getStrings("dataCategories");
    r.consentFormTemplate = data.getString("consentFormTemplate");
    r.version_ = data.getString("version");
    r.requiresExplicitConsent = data.getBoolean("requiresExplicitConsent", true);
    r.validFrom = jsonLong(j, "validFrom");
    r.validUntil = jsonLong(j, "validUntil");

    auto result = usecase.createPurpose(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Consent purpose created successfully", "Created", 201, responseData);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto items = usecase.listPurposes(tenantId);
    auto list = items.map!(item => item.toJson()).array.toJson;

    auto responseData = Json.emptyObject
      .set("count", list.length)
      .set("resources", list);
    return successResponse("Consent purpose list retrieved successfully", "Retrieved", 200, responseData);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = ConsentPurposeId(precheck.id);
    if (id.isNull)
      return errorResponse("Invalid consent purpose ID", 400);

    auto entry = usecase.getPurpose(tenantId, id);
    if (entry.isNull)
      return errorResponse("Consent purpose not found", 404);

    auto responseData = entry.toJson();
    return successResponse("Consent purpose retrieved successfully", "Retrieved", 200, responseData);
  }

  override protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
    UpdateConsentPurposeRequest r;
    r.tenantId = tenantId;
    r.purposeId = ConsentPurposeId(precheck.id);

    r.name = data.getString("name");
    r.description = data.getString("description");
    r.consentFormTemplate = data.getString("consentFormTemplate");
    r.version_ = data.getString("version");
    r.requiresExplicitConsent = data.getBoolean("requiresExplicitConsent", true);

    auto result = usecase.updatePurpose(r);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Consent purpose updated successfully", "Updated", 200, responseData);
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = ConsentPurposeId(precheck.id);

    auto result = usecase.deletePurpose(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Consent purpose deleted successfully", "Deleted", 200, responseData);
  }
}
