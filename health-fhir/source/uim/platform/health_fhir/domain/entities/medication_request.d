/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.health_fhir.domain.entities.medication_request;
import uim.platform.health_fhir;

mixin(ShowModule!());

@safe:

/// FHIR R4 MedicationRequest resource
struct MedicationRequest {
  mixin TenantEntity!(MedicationRequestId);

  MedicationRequestStatus status_;
  FhirCodeableConcept intent_;
  FhirReference medicationReference_;
  FhirReference subject_;
  FhirReference encounter_;
  string authoredOn_;
  FhirReference requester_;
  FhirReference recorder_;
  FhirCodeableConcept[] reasonCode_;
  FhirReference[] reasonReference_;
  string note_;
  string dosageInstructionText_;

  Json toJson() const {
    auto reasonCodeArr = Json.emptyArray;
    foreach (r; reasonCode_) reasonCodeArr ~= r.toJson();
    auto reasonRefArr = Json.emptyArray;
    foreach (r; reasonReference_) reasonRefArr ~= r.toJson();

    return entityToJson
      .set("resourceType", "MedicationRequest")
      .set("status", status_.to!string)
      .set("intent", intent_.toJson())
      .set("medicationReference", medicationReference_.toJson())
      .set("subject", subject_.toJson())
      .set("encounter", encounter_.toJson())
      .set("authoredOn", authoredOn_)
      .set("requester", requester_.toJson())
      .set("recorder", recorder_.toJson())
      .set("reasonCode", reasonCodeArr)
      .set("reasonReference", reasonRefArr)
      .set("note", note_)
      .set("dosageInstruction", Json.emptyArray ~= Json.emptyObject.set("text", dosageInstructionText_));
  }
}
