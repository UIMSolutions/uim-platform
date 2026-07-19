/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.health_fhir.domain.entities.encounter;
import uim.platform.health_fhir;
mixin(ShowModule!());

@safe:

/// FHIR R4 Encounter resource
struct Encounter {
  mixin TenantEntity!(EncounterId);

  EncounterStatus status_;
  FhirCodeableConcept class_;
  FhirCodeableConcept[] type_;
  FhirReference subject_;
  FhirReference[] participant_;
  string periodStart_;
  string periodEnd_;
  FhirReference[] reasonReference_;
  FhirCodeableConcept[] reasonCode_;
  FhirReference serviceProvider_;

  Json toJson() const {
    auto typeArr = Json.emptyArray;
    foreach (t; type_) typeArr ~= t.toJson();
    auto participantArr = Json.emptyArray;
    foreach (p; participant_) participantArr ~= p.toJson();
    auto reasonRefArr = Json.emptyArray;
    foreach (r; reasonReference_) reasonRefArr ~= r.toJson();
    auto reasonCodeArr = Json.emptyArray;
    foreach (r; reasonCode_) reasonCodeArr ~= r.toJson();

    return entityToJson
      .set("resourceType", "Encounter")
      .set("status", status_.to!string)
      .set("class", class_.toJson())
      .set("type", typeArr)
      .set("subject", subject_.toJson())
      .set("participant", participantArr)
      .set("period", Json.emptyObject.set("start", periodStart_).set("end", periodEnd_))
      .set("reasonReference", reasonRefArr)
      .set("reasonCode", reasonCodeArr)
      .set("serviceProvider", serviceProvider_.toJson());
  }
}
