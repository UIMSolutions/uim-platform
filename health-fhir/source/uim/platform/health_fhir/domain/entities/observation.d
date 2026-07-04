/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.health_fhir.domain.entities.observation;
import uim.platform.health_fhir;

mixin(ShowModule!());

@safe:

/// FHIR R4 Observation resource
struct Observation {
  mixin TenantEntity!(ObservationId);

  ObservationStatus status_;
  FhirCodeableConcept code_;
  FhirReference subject_;
  FhirReference encounter_;
  string effectiveDateTime_;
  FhirQuantity valueQuantity_;
  string valueString_;
  FhirCodeableConcept[] category_;
  FhirReference performer_;
  string note_;

  Json toJson() const {
    auto catArr = Json.emptyArray;
    foreach (c; category_) catArr ~= c.toJson();

    return entityToJson
      .set("resourceType", "Observation")
      .set("status", status_.to!string)
      .set("code", code_.toJson())
      .set("subject", subject_.toJson())
      .set("encounter", encounter_.toJson())
      .set("effectiveDateTime", effectiveDateTime_)
      .set("valueQuantity", valueQuantity_.toJson())
      .set("valueString", valueString_)
      .set("category", catArr)
      .set("performer", performer_.toJson())
      .set("note", note_);
  }
}
