/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.health_fhir.presentation.http.controllers.encounter;
import uim.platform.health_fhir;

mixin(ShowModule!());

@safe:

class EncounterController : ManageController {
  private ManageEncountersUseCase usecase;

  this(ManageEncountersUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    router.get("/fhir/R4/Encounter",     &handleList);
    router.get("/fhir/R4/Encounter/*",   &handleGet);
    router.post("/fhir/R4/Encounter",    &handleCreate);
    router.put("/fhir/R4/Encounter/*",   &handleUpdate);
    router.delete_("/fhir/R4/Encounter/*", &handleDelete);
  }

  private static void writeFhirError(scope HTTPServerResponse res, int status, string msg) {
    res.writeJsonBody(
      Json.emptyObject.set("resourceType", "OperationOutcome")
        .set("issue", Json.emptyArray ~= Json.emptyObject
          .set("severity", "error").set("code", "processing").set("diagnostics", msg)),
      status
    );
  }

  private static EncounterStatus parseStatus(string s) {
    switch (s) {
      case "planned":        return EncounterStatus.planned_;
      case "arrived":        return EncounterStatus.arrived_;
      case "triaged":        return EncounterStatus.triaged_;
      case "in-progress":    return EncounterStatus.inProgress_;
      case "onleave":        return EncounterStatus.onLeave_;
      case "finished":       return EncounterStatus.finished_;
      case "cancelled":      return EncounterStatus.cancelled_;
      case "entered-in-error": return EncounterStatus.enteredInError;
      default:               return EncounterStatus.unknown_;
    }
  }

  override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
        ScanJobDTO dto;
        dto.tenantId = tenantId;
      CreateEncounterRequest r;
      r.tenantId    = tenantId;
      r.encounterId = EncounterId(precheck.id);
      r.status_     = parseStatus(data.getString("status"));
      auto subjJ = j.get("subject", Json.emptyObject);
      r.subject_ = FhirReference(subjJ.getString("reference"), subjJ.getString("display"));
      auto periodJ = j.get("period", Json.emptyObject);
      r.periodStart_ = periodJ.getString("start");
      r.periodEnd_   = periodJ.getString("end");
      auto result = usecase.createEncounter(r);
      if (result.success)
        res.writeJsonBody(Json.emptyObject.set("resourceType", "Encounter").set("id", result.id), 201);
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
      Encounter[] encounters;
      auto patientParam = req.query.get("subject", "");
      if (patientParam.length > 0)
        encounters = usecase.listByPatient(tenantId, patientParam);
      else
        encounters = usecase.listEncounters(tenantId);
      auto entries = Json.emptyArray;
      foreach (e; encounters) entries ~= e.toJson();
      res.writeJsonBody(
        Json.emptyObject.set("resourceType", "Bundle").set("type", "searchset")
          .set("total", encounters.length).set("entry", entries),
        200
      );
    } catch (Exception e) {
      writeFhirError(res, 500, "Internal server error");
    }
  }

  override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto id = EncounterId(precheck.id);
      auto enc = usecase.getEncounter(tenantId, id);
      if (enc.isNull) { writeFhirError(res, 404, "Encounter not found"); return; }
      res.writeJsonBody(enc.toJson(), 200);
    } catch (Exception e) {
      writeFhirError(res, 500, "Internal server error");
    }
  }

  override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto id = EncounterId(precheck.id);
      auto data = precheck.data;
      UpdateEncounterRequest r;
      r.tenantId    = tenantId;
      r.encounterId = id;
      r.status_     = parseStatus(data.getString("status"));
      auto subjJ = j.get("subject", Json.emptyObject);
      r.subject_ = FhirReference(subjJ.getString("reference"), subjJ.getString("display"));
      auto periodJ = j.get("period", Json.emptyObject);
      r.periodStart_ = periodJ.getString("start");
      r.periodEnd_   = periodJ.getString("end");
      auto result = usecase.updateEncounter(r);
      if (result.success)
        res.writeJsonBody(Json.emptyObject.set("resourceType", "Encounter").set("id", result.id), 200);
      else
        writeFhirError(res, 400, result.message);
    } catch (Exception e) {
      writeFhirError(res, 500, "Internal server error");
    }
  }

  override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto id = EncounterId(precheck.id);
      auto result = usecase.deleteEncounter(tenantId, id);
      if (result.success) res.writeBody("", cast(int) HTTPStatus.noContent, "application/json");
      else writeFhirError(res, 404, result.message);
    } catch (Exception e) {
      writeFhirError(res, 500, "Internal server error");
    }
  }
}
