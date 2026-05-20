/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.health_fhir.domain.entities.practitioner;
import uim.platform.health_fhir;

mixin(ShowModule!());

@safe:

/// FHIR R4 Practitioner resource
struct Practitioner {
  mixin TenantEntity!(PractitionerId);

  FhirHumanName[] name_;
  Gender gender_;
  string birthDate_;
  FhirAddress[] address_;
  bool active_;
  string[] telecom_;
  FhirCodeableConcept[] qualification_;

  Json toJson() const {
    auto nameArr = Json.emptyArray;
    foreach (n; name_) nameArr ~= n.toJson();
    auto addrArr = Json.emptyArray;
    foreach (a; address_) addrArr ~= a.toJson();
    auto qualArr = Json.emptyArray;
    foreach (q; qualification_) qualArr ~= q.toJson();
    auto telecomArr = Json.emptyArray;
    foreach (t; telecom_) telecomArr ~= Json(t);

    return entityToJson
      .set("resourceType", "Practitioner")
      .set("name", nameArr)
      .set("gender", gender_.to!string)
      .set("birthDate", birthDate_)
      .set("address", addrArr)
      .set("active", active_)
      .set("telecom", telecomArr)
      .set("qualification", qualArr);
  }
}
