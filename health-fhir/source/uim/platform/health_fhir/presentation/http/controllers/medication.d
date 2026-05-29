/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.health_fhir.presentation.http.controllers.medication;
import uim.platform.health_fhir;

mixin(ShowModule!());

@safe:

class MedicationController : ManageController {
  private ManageMedicationsUseCase usecase;

  this(ManageMedicationsUseCase usecase) {
    this.usecase = usecase;
  }

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    router.get("/fhir/R4/Medication",     &handleList);
    router.get("/fhir/R4/Medication/*",   &handleGet);
    router.post("/fhir/R4/Medication",    &handleCreate);
    router.put("/fhir/R4/Medication/*",   &handleUpdate);
    router.delete_("/fhir/R4/Medication/*", &handleDelete);
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
      CreateMedicationRequest r;
      r.tenantId    = tenantId;
      r.medicationId = MedicationId(precheck.id);
      auto result = usecase.createMedication(r);
      if (result.success)
        res.writeJsonBody(Json.emptyObject.set("resourceType", "Medication").set("id", result.id), 201);
      else
        writeFhirError(res, 400, result.message);
    } catch (Exception e) {
      writeFhirError(res, 500, "Internal server error");
    }
  }

  override protected void handleList(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto meds = usecase.listMedications(tenantId);
      auto entries = Json.emptyArray;
      foreach (m; meds) entries ~= m.toJson();
      res.writeJsonBody(
        Json.emptyObject.set("resourceType", "Bundle").set("type", "searchset")
          .set("total", meds.length).set("entry", entries),
        200
      );
    } catch (Exception e) {
      writeFhirError(res, 500, "Internal server error");
    }
  }

  override protected void handleGet(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto id = MedicationId(precheck.id);
      auto m = usecase.getMedication(tenantId, id);
      if (m.isNull) { writeFhirError(res, 404, "Medication not found"); return; }
      res.writeJsonBody(m.toJson(), 200);
    } catch (Exception e) {
      writeFhirError(res, 500, "Internal server error");
    }
  }

  override protected void handleUpdate(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto id = MedicationId(precheck.id);
      auto data = precheck.data;
      UpdateMedicationRequest r;
      r.tenantId     = tenantId;
      r.medicationId = id;
      auto result = usecase.updateMedication(r);
      if (result.success)
        res.writeJsonBody(Json.emptyObject.set("resourceType", "Medication").set("id", result.id), 200);
      else
        writeFhirError(res, 400, result.message);
    } catch (Exception e) {
      writeFhirError(res, 500, "Internal server error");
    }
  }

  override protected void handleDelete(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    try {
      auto tenantId = precheck.tenantId;
      auto id = MedicationId(precheck.id);
      auto result = usecase.deleteMedication(tenantId, id);
      if (result.success) res.writeBody("", cast(int) HTTPStatus.noContent, "application/json");
      else writeFhirError(res, 404, result.message);
    } catch (Exception e) {
      writeFhirError(res, 500, "Internal server error");
    }
  }
}
