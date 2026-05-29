/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.health_fhir.presentation.http.controllers.observation;
import uim.platform.health_fhir;

mixin(ShowModule!());

@safe:

class ObservationController : ManageController {
  private ManageObservationsUseCase usecase;

  this(ManageObservationsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    router.get("/fhir/R4/Observation",     &handleList);
    router.get("/fhir/R4/Observation/*",   &handleGet);
    router.post("/fhir/R4/Observation",    &handleCreate);
    router.put("/fhir/R4/Observation/*",   &handleUpdate);
    router.delete_("/fhir/R4/Observation/*", &handleDelete);
  }

  private static void writeFhirError(scope HTTPServerResponse res, int status, string msg) {
    res.writeJsonBody(
      Json.emptyObject.set("resourceType", "OperationOutcome")
        .set("issue", Json.emptyArray ~= Json.emptyObject
          .set("severity", "error").set("code", "processing").set("diagnostics", msg)),
      status
    );
  }

  override protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto data = precheck.data;
      CreateObservationRequest r;
      r.tenantId        = tenantId;
      r.observationId   = ObservationId(precheck.id);
      r.status_         = parseStatus(data.getString("status"));
      r.effectiveDateTime_ = data.getString("effectiveDateTime");
      r.note_           = data.getString("note");

      auto subjJ = j.get("subject", Json.emptyObject);
      r.subject_ = FhirReference(subjJ.getString("reference"), subjJ.getString("display"));

      auto result = usecase.createObservation(r);
      if (result.success)
        res.writeJsonBody(Json.emptyObject.set("resourceType", "Observation").set("id", result.id), 201);
      else
        writeFhirError(res, 400, result.message);
    } catch (Exception e) {
      writeFhirError(res, 500, "Internal server error");
    }
  }

  override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      Observation[] observations;
      auto patientParam = req.query.get("subject", "");
      if (patientParam.length > 0)
        observations = usecase.listByPatient(tenantId, patientParam);
      else
        observations = usecase.listObservations(tenantId);

      auto entries = Json.emptyArray;
      foreach (o; observations) entries ~= o.toJson();
      res.writeJsonBody(
        Json.emptyObject.set("resourceType", "Bundle").set("type", "searchset")
          .set("total", observations.length).set("entry", entries),
        200
      );
    } catch (Exception e) {
      writeFhirError(res, 500, "Internal server error");
    }
  }

  override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto id = ObservationId(precheck.id);
      auto o = usecase.getObservation(tenantId, id);
      if (o.isNull) { writeFhirError(res, 404, "Observation not found"); return; }
      res.writeJsonBody(o.toJson(), 200);
    } catch (Exception e) {
      writeFhirError(res, 500, "Internal server error");
    }
  }

  override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto id = ObservationId(precheck.id);
      auto data = precheck.data;
      
      UpdateObservationRequest r;
      r.tenantId      = tenantId;
      r.observationId = id;
      r.status_       = data.getString("status");
      r.effectiveDateTime_ = data.getString("effectiveDateTime");
      r.note_         = data.getString("note");
      auto subjJ = j.get("subject", Json.emptyObject);
      r.subject_ = FhirReference(subjJ.getString("reference"), subjJ.getString("display"));
      
      auto result = usecase.updateObservation(r);
      if (result.success)
        res.writeJsonBody(Json.emptyObject.set("resourceType", "Observation").set("id", result.id), 200);
      else
        writeFhirError(res, 400, result.message);
    } catch (Exception e) {
      writeFhirError(res, 500, "Internal server error");
    }
  }

  override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto id = ObservationId(precheck.id);
      auto result = usecase.deleteObservation(tenantId, id);
      if (result.success) res.writeBody("", cast(int) HTTPStatus.noContent, "application/json");
      else writeFhirError(res, 404, result.message);
    } catch (Exception e) {
      writeFhirError(res, 500, "Internal server error");
    }
  }
}
