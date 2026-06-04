/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.health_fhir.presentation.http.controllers.condition;
import uim.platform.health_fhir;

mixin(ShowModule!());

@safe:

class ConditionController : ManageHttpController {
  private ManageConditionsUseCase usecase;

  this(ManageConditionsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    router.get("/fhir/R4/Condition", &handleList);
    router.get("/fhir/R4/Condition/*", &handleGet);
    router.post("/fhir/R4/Condition", &handleCreate);
    router.put("/fhir/R4/Condition/*", &handleUpdate);
    router.delete_("/fhir/R4/Condition/*", &handleDelete);
  }

  private static void writeFhirError(scope HTTPServerResponse res, int status, string msg) {
    res.writeJsonBody(
      Json.emptyObject.set("resourceType", "OperationOutcome")
        .set("issue", Json.emptyArray ~= Json.emptyObject
          .set("severity", "error").set("code", "processing").set("diagnostics", msg)),
        status
    );
  }

  override protected Json createHandler(HTTPServerRequest req) {
    auto precheck = super.createHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;

    auto data = precheck.data;
        CreateConditionRequest r;
    r.tenantId = tenantId;
    r.conditionId = ConditionId(precheck.id);
    r.note_ = data.getString("note");
    r.onsetDateTime_ = data.getString("onsetDateTime");
    r.recordedDate_ = data.getString("recordedDate");
    auto subjJ = j.get("subject", Json.emptyObject);
    r.subject_ = FhirReference(subjJ.getString("reference"), subjJ.getString("display"));
    auto result = usecase.createCondition(r);

    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Condition created successfully", "Created", 201, responseData);
  }

  override protected Json listHandler(HTTPServerRequest req) {
    auto precheck = super.listHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    Condition[] conditions;
    auto patientParam = req.query.get("subject", "");
    if (patientParam.length > 0)
      conditions = usecase.listByPatient(tenantId, patientParam);
    else
      conditions = usecase.listConditions(tenantId);
    auto entries = Json.emptyArray;
    foreach (c; conditions)
      entries ~= c.toJson();
    auto responseData = Json.emptyObject.set("resourceType", "Bundle").set("type", "searchset")
      .set("total", conditions.length).set("entry", entries);

    return successResponse("Conditions retrieved successfully", "Retrieved", 200, responseData);
  }

  override protected Json getHandler(HTTPServerRequest req) {
    auto precheck = super.getHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = ConditionId(precheck.id);
    auto c = usecase.getCondition(tenantId, id);
    if (c.isNull)
      return errorResponse("Condition not found", 404);

    auto responseData = c.toJson();
    return successResponse("Condition retrieved successfully", "Retrieved", 200, responseData);
  }

  override protected Json updateHandler(HTTPServerRequest req) {
    auto precheck = super.updateHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = ConditionId(precheck.id);
    auto data = precheck.data;
    UpdateConditionRequest r;
    r.tenantId = tenantId;
    r.conditionId = id;
    r.note_ = data.getString("note");
    r.onsetDateTime_ = data.getString("onsetDateTime");
    r.recordedDate_ = data.getString("recordedDate");
    auto subjJ = j.get("subject", Json.emptyObject);
    r.subject_ = FhirReference(subjJ.getString("reference"), subjJ.getString("display"));
    auto result = usecase.updateCondition(r);

    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Condition updated successfully", "Updated", 200, responseData);
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
    auto precheck = super.deleteHandler(req);
    if (precheck.hasError)
      return precheck;

    auto tenantId = precheck.tenantId;
    auto id = ConditionId(precheck.id);
    auto result = usecase.deleteCondition(tenantId, id);
    if (result.hasError)
      return errorResponse(result.message, 400);

    auto responseData = Json.emptyObject.set("id", result.id);
    return successResponse("Condition deleted successfully", "Deleted", 200, responseData);
  }
}
