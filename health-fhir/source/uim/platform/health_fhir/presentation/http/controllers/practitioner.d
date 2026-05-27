/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.health_fhir.presentation.http.controllers.practitioner;
import uim.platform.health_fhir;

mixin(ShowModule!());

@safe:

class PractitionerController : ManageController {
  private ManagePractitionersUseCase usecase;

  this(ManagePractitionersUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    router.get("/fhir/R4/Practitioner",     &handleList);
    router.get("/fhir/R4/Practitioner/*",   &handleGet);
    router.post("/fhir/R4/Practitioner",    &handleCreate);
    router.put("/fhir/R4/Practitioner/*",   &handleUpdate);
    router.delete_("/fhir/R4/Practitioner/*", &handleDelete);
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
      auto j = req.json;
      CreatePractitionerRequest r;
      r.tenantId        = tenantId;
      r.practitionerId  = PractitionerId(precheck.id);
      r.birthDate_      = j.getString("birthDate");
      r.active_         = j.get("active", Json(true)).get!bool;

      auto result = usecase.createPractitioner(r);
      if (result.success)
        res.writeJsonBody(Json.emptyObject.set("resourceType", "Practitioner").set("id", result.id), 201);
      else
        writeFhirError(res, 400, result.message);
    } catch (Exception e) {
      writeFhirError(res, 500, "Internal server error");
    }
  }

  override protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto practitioners = usecase.listPractitioners(tenantId);
      auto entries = Json.emptyArray;
      foreach (p; practitioners) entries ~= p.toJson();
      res.writeJsonBody(
        Json.emptyObject.set("resourceType", "Bundle").set("type", "searchset")
          .set("total", practitioners.length).set("entry", entries),
        200
      );
    } catch (Exception e) {
      writeFhirError(res, 500, "Internal server error");
    }
  }

  override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto id = Practitionerprecheck.id);
      auto p = usecase.getPractitioner(tenantId, id);
      if (p.isNull) { writeFhirError(res, 404, "Practitioner not found"); return; }
      res.writeJsonBody(p.toJson(), 200);
    } catch (Exception e) {
      writeFhirError(res, 500, "Internal server error");
    }
  }

  override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto id = Practitionerprecheck.id);
      auto j = req.json;
      UpdatePractitionerRequest r;
      r.tenantId = tenantId;
      r.practitionerId = id;
      r.birthDate_ = j.getString("birthDate");
      r.active_    = j.get("active", Json(true)).get!bool;
      auto result = usecase.updatePractitioner(r);
      if (result.success)
        res.writeJsonBody(Json.emptyObject.set("resourceType", "Practitioner").set("id", result.id), 200);
      else
        writeFhirError(res, 400, result.message);
    } catch (Exception e) {
      writeFhirError(res, 500, "Internal server error");
    }
  }

  override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto id = Practitionerprecheck.id);
      auto result = usecase.deletePractitioner(tenantId, id);
      if (result.success) res.writeBody("", cast(int) HTTPStatus.noContent, "application/json");
      else writeFhirError(res, 404, result.message);
    } catch (Exception e) {
      writeFhirError(res, 500, "Internal server error");
    }
  }
}
