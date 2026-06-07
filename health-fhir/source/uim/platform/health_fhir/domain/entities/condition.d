/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.health_fhir.domain.entities.condition;
import uim.platform.health_fhir;

// mixin(ShowModule!());

@safe:

/// FHIR R4 Condition resource
struct Condition {
  mixin TenantEntity!(ConditionId);

  FhirCodeableConcept clinicalStatus_;
  FhirCodeableConcept verificationStatus_;
  FhirCodeableConcept[] category_;
  FhirCodeableConcept severity_;
  FhirCodeableConcept code_;
  FhirReference subject_;
  FhirReference encounter_;
  string onsetDateTime_;
  string abatementDateTime_;
  string recordedDate_;
  FhirReference recorder_;
  string note_;

  Json toJson() const {
    auto catArr = Json.emptyArray;
    foreach (c; category_) catArr ~= c.toJson();

    return entityToJson
      .set("resourceType", "Condition")
      .set("clinicalStatus", clinicalStatus_.toJson())
      .set("verificationStatus", verificationStatus_.toJson())
      .set("category", catArr)
      .set("severity", severity_.toJson())
      .set("code", code_.toJson())
      .set("subject", subject_.toJson())
      .set("encounter", encounter_.toJson())
      .set("onsetDateTime", onsetDateTime_)
      .set("abatementDateTime", abatementDateTime_)
      .set("recordedDate", recordedDate_)
      .set("recorder", recorder_.toJson())
      .set("note", note_);
  }
}
