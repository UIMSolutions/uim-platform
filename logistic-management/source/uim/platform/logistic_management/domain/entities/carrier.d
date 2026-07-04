/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.logistic_management.domain.entities.carrier;
import uim.platform.logistic_management;

mixin(ShowModule!());

@safe:
/// A transportation service provider (carrier) used in freight orders.
struct Carrier {
  mixin TenantEntity!(CarrierId);

  string name;
  string description;
  string contactEmail;
  string contactPhone;
  string addressStreet;
  string addressCity;
  string addressCountry;
  string taxId;
  CarrierStatus status = CarrierStatus.active;
  TransportMode[] supportedModes;
  long createdAt;
  long updatedAt;

  Json toJson() const {
    return entityToJson
        .set("name", name)
        .set("description", description)
        .set("contactEmail", contactEmail)
        .set("contactPhone", contactPhone)
        .set("addressStreet", addressStreet)
        .set("addressCity", addressCity)
        .set("addressCountry", addressCountry)
        .set("taxId", taxId)
        .set("status", status.to!string)
        .set("supportedModes", supportedModes.map!(m => Json(m.to!string)).array.toJson)
        .set("createdAt", Json(createdAt))
        .set("updatedAt", Json(updatedAt));
  }
}
