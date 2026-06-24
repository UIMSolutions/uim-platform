/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.health_fhir.presentation.http.controllers.medication;
import uim.platform.health_fhir;

// mixin(ShowModule!());

@safe:

class MedicationController : ManageHttpController {
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

  override protected Json createHandler(HTTPServerRequest req) {
        auto precheck = super.createHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;

        auto data = precheck.data;
              CreateMedicationRequest r;
      r.tenantId    = tenantId;
      r.medicationId = MedicationId(precheck.id);
      auto result = usecase.createMedication(r);
      if (result.hasError)
        return errorResponse(result.message, 400);

      return successResponse("Medication created successfully", 201, Json.emptyObject.set("resourceType", "Medication").set("id", result.id));  

      // res.writeJsonBody(Json.emptyObject.set("resourceType", "Medication").set("id", result.id), 201);
      // writeFhirError(res, 500, "Internal server error");
  }

  override protected Json listHandler(HTTPServerRequest req) {
        auto precheck = super.listHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      auto meds = usecase.listMedications(tenantId);
      auto entries = meds.map!(m => m.toJson()).array;

      auto responseData = Json.emptyObject.set("resourceType", "Bundle").set("type", "searchset")
        .set("total", meds.length).set("entry", entries);
      return successResponse("Medications retrieved successfully", 200, responseData);
        // Json.emptyObject.set("resourceType", "Bundle").set("type", "searchset")
        //   .set("total", meds.length).set("entry", entries),
        // 200
      
    // writeFhirError(res, 500, "Internal server error");
    
  }

  override protected Json getHandler(HTTPServerRequest req) {
        auto precheck = super.getHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      auto id = MedicationId(precheck.id);
      auto m = usecase.getMedication(tenantId, id);
      if (m.isNull) { writeFhirError(res, 404, "Medication not found"); return; }
      res.writeJsonBody(m.toJson(), 200);
    } catch (Exception e) {
    // writeFhirError(res, 500, "Internal server error");
    }
  }

  override protected Json updateHandler(HTTPServerRequest req) {
        auto precheck = super.updateHandler(req);
        if (precheck.hasError)
            return precheck;

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
    // writeFhirError(res, 500, "Internal server error");
    }
  }

  override protected Json deleteHandler(HTTPServerRequest req) {
        auto precheck = super.deleteHandler(req);
        if (precheck.hasError)
            return precheck;

        auto tenantId = precheck.tenantId;
      auto id = MedicationId(precheck.id);
      auto result = usecase.deleteMedication(tenantId, id);
      if (result.success) res.writeBody("", cast(int) HTTPStatus.noContent, "application/json");
      else writeFhirError(res, 404, result.message);
    } catch (Exception e) {
    // writeFhirError(res, 500, "Internal server error");
    }
  }
}
