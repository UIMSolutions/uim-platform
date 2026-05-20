/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.health_fhir.domain.entities.medication;
import uim.platform.health_fhir;

mixin(ShowModule!());

@safe:

/// FHIR R4 Medication resource
struct Medication {
  mixin TenantEntity!(MedicationId);

  FhirCodeableConcept code_;
  FhirCodeableConcept status_;
  FhirReference manufacturer_;
  FhirCodeableConcept form_;
  FhirQuantity amount_;
  string[] ingredient_;

  Json toJson() const {
    auto ingredientArr = Json.emptyArray;
    foreach (i; ingredient_) ingredientArr ~= Json(i);

    return entityToJson
      .set("resourceType", "Medication")
      .set("code", code_.toJson())
      .set("status", status_.toJson())
      .set("manufacturer", manufacturer_.toJson())
      .set("form", form_.toJson())
      .set("amount", amount_.toJson())
      .set("ingredient", ingredientArr);
  }
}
