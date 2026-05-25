/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.health_fhir.presentation.http.controllers.patient;
import uim.platform.health_fhir;

mixin(ShowModule!());

@safe:

class PatientController : ManageController {
  private ManagePatientsUseCase usecase;

  this(ManagePatientsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    router.get("/fhir/R4/Patient",    &handleList);
    router.get("/fhir/R4/Patient/*",  &handleGet);
    router.post("/fhir/R4/Patient",   &handleCreate);
    router.put("/fhir/R4/Patient/*",  &handleUpdate);
    router.delete_("/fhir/R4/Patient/*", &handleDelete);
  }

  protected void handleCreate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto j = req.json;

      CreatePatientRequest r;
      r.tenantId  = tenantId;
      r.patientId = PatientId(j.getString("id"));
      r.birthDate_ = j.getString("birthDate");
      r.active_   = j.get("active", Json(true)).get!bool;

      auto genderStr = j.getString("gender");
      switch (genderStr) {
        case "male":    r.gender_ = Gender.male_;    break;
        case "female":  r.gender_ = Gender.female_;  break;
        case "other":   r.gender_ = Gender.other_;   break;
        default:        r.gender_ = Gender.unknown_;  break;
      }

      auto nameArr = j.get("name", Json.emptyArray);
      foreach (n; nameArr) {
        FhirHumanName hn;
        hn.use_    = n.getString("use");
        hn.family_ = n.getString("family");
        auto givenArr = n.get("given", Json.emptyArray);
        foreach (g; givenArr) hn.given_ ~= g.get!string;
        r.name_ ~= hn;
      }

      auto result = usecase.createPatient(r);
      if (result.success) {
        res.writeJsonBody(
          Json.emptyObject
            .set("resourceType", "Patient")
            .set("id", result.id)
            .set("message", "Patient created"),
          201
        );
      } else {
        writeFhirError(res, 400, result.message);
      }
    } catch (Exception e) {
      writeFhirError(res, 500, "Internal server error");
    }
  }

  protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      Patient[] patients;

      // Support ?name= search parameter
      auto nameParam = req.query.get("name", "");
      if (nameParam.length > 0) {
        patients = usecase.searchByName(tenantId, nameParam);
      } else {
        patients = usecase.listPatients(tenantId);
      }

      auto entries = Json.emptyArray;
      foreach (p; patients) entries ~= p.toJson();

      res.writeJsonBody(
        Json.emptyObject
          .set("resourceType", "Bundle")
          .set("type", "searchset")
          .set("total", patients.length)
          .set("entry", entries),
        200
      );
    } catch (Exception e) {
      writeFhirError(res, 500, "Internal server error");
    }
  }

  protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = PatientId(extractIdFromPath(req.requestURI.to!string));
      auto p = usecase.getPatient(tenantId, id);
      if (p.isNull) { writeFhirError(res, 404, "Patient not found"); return; }
      res.writeJsonBody(p.toJson(), 200);
    } catch (Exception e) {
      writeFhirError(res, 500, "Internal server error");
    }
  }

  override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = PatientId(extractIdFromPath(req.requestURI.to!string));
      auto j = req.json;

      UpdatePatientRequest r;
      r.tenantId   = tenantId;
      r.patientId  = id;
      r.birthDate_ = j.getString("birthDate");
      r.active_    = j.get("active", Json(true)).get!bool;

      auto genderStr = j.getString("gender");
      switch (genderStr) {
        case "male":    r.gender_ = Gender.male_;    break;
        case "female":  r.gender_ = Gender.female_;  break;
        case "other":   r.gender_ = Gender.other_;   break;
        default:        r.gender_ = Gender.unknown_;  break;
      }

      auto nameArr = j.get("name", Json.emptyArray);
      foreach (n; nameArr) {
        FhirHumanName hn;
        hn.use_    = n.getString("use");
        hn.family_ = n.getString("family");
        auto givenArr = n.get("given", Json.emptyArray);
        foreach (g; givenArr) hn.given_ ~= g.get!string;
        r.name_ ~= hn;
      }

      auto result = usecase.updatePatient(r);
      if (result.success)
        res.writeJsonBody(Json.emptyObject.set("resourceType", "Patient").set("id", result.id), 200);
      else
        writeFhirError(res, 400, result.message);
    } catch (Exception e) {
      writeFhirError(res, 500, "Internal server error");
    }
  }

  override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = req.getTenantId;
      auto id = PatientId(extractIdFromPath(req.requestURI.to!string));
      auto result = usecase.deletePatient(tenantId, id);
      if (result.success) res.writeBody("", cast(int) HTTPStatus.noContent, "application/json");
      else writeFhirError(res, 404, result.message);
    } catch (Exception e) {
      writeFhirError(res, 500, "Internal server error");
    }
  }

  private static void writeFhirError(scope HTTPServerResponse res, int status, string msg) {
    auto oo = Json.emptyObject
      .set("resourceType", "OperationOutcome")
      .set("issue", Json.emptyArray ~= Json.emptyObject
        .set("severity", "error")
        .set("code", "processing")
        .set("diagnostics", msg));
    res.writeJsonBody(oo, status);
  }
}
