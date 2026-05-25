/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.health_fhir.presentation.http.controllers.condition;
import uim.platform.health_fhir;

mixin(ShowModule!());

@safe:

class ConditionController : ManageController {
  private ManageConditionsUseCase usecase;

  this(ManageConditionsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    router.get("/fhir/R4/Condition",     &handleList);
    router.get("/fhir/R4/Condition/*",   &handleGet);
    router.post("/fhir/R4/Condition",    &handleCreate);
    router.put("/fhir/R4/Condition/*",   &handleUpdate);
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

  protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto j = req.json;
      CreateConditionRequest r;
      r.tenantId     = tenantId;
      r.conditionId  = ConditionId(j.getString("id"));
      r.note_        = j.getString("note");
      r.onsetDateTime_   = j.getString("onsetDateTime");
      r.recordedDate_    = j.getString("recordedDate");
      auto subjJ = j.get("subject", Json.emptyObject);
      r.subject_ = FhirReference(subjJ.getString("reference"), subjJ.getString("display"));
      auto result = usecase.createCondition(r);
      if (result.success)
        res.writeJsonBody(Json.emptyObject.set("resourceType", "Condition").set("id", result.id), 201);
      else
        writeFhirError(res, 400, result.message);
    } catch (Exception e) {
      writeFhirError(res, 500, "Internal server error");
    }
  }

  protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      Condition[] conditions;
      auto patientParam = req.query.get("subject", "");
      if (patientParam.length > 0)
        conditions = usecase.listByPatient(tenantId, patientParam);
      else
        conditions = usecase.listConditions(tenantId);
      auto entries = Json.emptyArray;
      foreach (c; conditions) entries ~= c.toJson();
      res.writeJsonBody(
        Json.emptyObject.set("resourceType", "Bundle").set("type", "searchset")
          .set("total", conditions.length).set("entry", entries),
        200
      );
    } catch (Exception e) {
      writeFhirError(res, 500, "Internal server error");
    }
  }

  override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = ConditionId(extractIdFromPath(req.requestURI.to!string));
      auto c = usecase.getCondition(tenantId, id);
      if (c.isNull) { writeFhirError(res, 404, "Condition not found"); return; }
      res.writeJsonBody(c.toJson(), 200);
    } catch (Exception e) {
      writeFhirError(res, 500, "Internal server error");
    }
  }

  override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = ConditionId(extractIdFromPath(req.requestURI.to!string));
      auto j = req.json;
      UpdateConditionRequest r;
      r.tenantId    = tenantId;
      r.conditionId = id;
      r.note_       = j.getString("note");
      r.onsetDateTime_ = j.getString("onsetDateTime");
      r.recordedDate_  = j.getString("recordedDate");
      auto subjJ = j.get("subject", Json.emptyObject);
      r.subject_ = FhirReference(subjJ.getString("reference"), subjJ.getString("display"));
      auto result = usecase.updateCondition(r);
      if (result.success)
        res.writeJsonBody(Json.emptyObject.set("resourceType", "Condition").set("id", result.id), 200);
      else
        writeFhirError(res, 400, result.message);
    } catch (Exception e) {
      writeFhirError(res, 500, "Internal server error");
    }
  }

  override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = ConditionId(extractIdFromPath(req.requestURI.to!string));
      auto result = usecase.deleteCondition(tenantId, id);
      if (result.success) res.writeBody("", cast(int) HTTPStatus.noContent, "application/json");
      else writeFhirError(res, 404, result.message);
    } catch (Exception e) {
      writeFhirError(res, 500, "Internal server error");
    }
  }
}
