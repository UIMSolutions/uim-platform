/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.health_fhir.domain.entities.patient;
import uim.platform.health_fhir;

// mixin(ShowModule!());

@safe:

/// FHIR R4 Patient resource
struct Patient {
  mixin TenantEntity!(PatientId);

  // FHIR R4 standard fields
  FhirHumanName[] name_;
  string birthDate_;
  Gender gender_;
  FhirAddress[] address_;
  bool active_;
  string[] telecom_;

  Json toJson() const {
    auto nameArr = Json.emptyArray;
    foreach (n; name_) nameArr ~= n.toJson();
    auto addrArr = Json.emptyArray;
    foreach (a; address_) addrArr ~= a.toJson();
    auto telecomArr = Json.emptyArray;
    foreach (t; telecom_) telecomArr ~= Json(t);

    return entityToJson
      .set("resourceType", "Patient")
      .set("name", nameArr)
      .set("birthDate", birthDate_)
      .set("gender", gender_.to!string)
      .set("address", addrArr)
      .set("active", active_)
      .set("telecom", telecomArr);
  }
}
