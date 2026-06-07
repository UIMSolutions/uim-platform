/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.health_fhir.domain.entities.organization;
import uim.platform.health_fhir;

// mixin(ShowModule!());

@safe:

/// FHIR R4 Organization resource
struct Organization {
  mixin TenantEntity!(OrganizationId);

  bool active_;
  FhirCodeableConcept[] type_;
  string name_;
  string[] alias_;
  string[] telecom_;
  FhirAddress[] address_;
  FhirReference partOf_;

  Json toJson() const {
    auto typeArr = Json.emptyArray;
    foreach (t; type_) typeArr ~= t.toJson();
    auto aliasArr = Json.emptyArray;
    foreach (a; alias_) aliasArr ~= Json(a);
    auto telecomArr = Json.emptyArray;
    foreach (t; telecom_) telecomArr ~= Json(t);
    auto addrArr = Json.emptyArray;
    foreach (a; address_) addrArr ~= a.toJson();

    return entityToJson
      .set("resourceType", "Organization")
      .set("active", active_)
      .set("type", typeArr)
      .set("name", name_)
      .set("alias", aliasArr)
      .set("telecom", telecomArr)
      .set("address", addrArr)
      .set("partOf", partOf_.toJson());
  }
}
