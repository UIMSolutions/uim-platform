/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.health_fhir.presentation.http.controllers.capability;
import uim.platform.health_fhir;

mixin(ShowModule!());

@safe:

/// Serves FHIR R4 CapabilityStatement at /fhir/R4/metadata
class CapabilityController : HttpController {

  override void registerRoutes(URLRouter router) {
    super.registerRoutes(router);
    router.get("/fhir/R4/metadata", &handleCapabilityStatement);
  }

  protected void handleCapabilityStatement(scope HTTPServerRequest req, scope HTTPServerResponse res) {
    auto resources = Json.emptyArray;
    foreach (rt; ["Patient", "Practitioner", "Observation", "Condition",
                  "Organization", "Encounter", "Medication", "MedicationRequest"]) {
      resources ~= Json.emptyObject
        .set("type", rt)
        .set("interaction", Json.emptyArray
          ~= Json.emptyObject.set("code", "read")
          ~= Json.emptyObject.set("code", "vread")
          ~= Json.emptyObject.set("code", "update")
          ~= Json.emptyObject.set("code", "delete")
          ~= Json.emptyObject.set("code", "create")
          ~= Json.emptyObject.set("code", "search-type")
        )
        .set("versioning", "no-version")
        .set("readHistory", false)
        .set("updateCreate", true);
    }

    auto capability = Json.emptyObject
      .set("resourceType", "CapabilityStatement")
      .set("status", "active")
      .set("date", "2026-01-01")
      .set("kind", "instance")
      .set("fhirVersion", "4.0.1")
      .set("format", Json.emptyArray ~= Json("application/fhir+json"))
      .set("software", Json.emptyObject
        .set("name", "UIM Health FHIR Service")
        .set("version", "1.0.0")
      )
      .set("rest", Json.emptyArray ~= Json.emptyObject
        .set("mode", "server")
        .set("resource", resources)
      );

    res.writeJsonBody(capability, 200);
  }
}
