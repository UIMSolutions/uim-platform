/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.health_fhir.domain.types;

import uim.platform.health_fhir;

// mixin(ShowModule!());

@safe:

// --- FHIR Resource ID types ---
struct PatientId {
  string value;
  this(string value) { this.value = value; }
  mixin IdTemplate;
}

struct PractitionerId {
  string value;
  this(string value) { this.value = value; }
  mixin IdTemplate;
}

struct ObservationId {
  string value;
  this(string value) { this.value = value; }
  mixin IdTemplate;
}

struct ConditionId {
  string value;
  this(string value) { this.value = value; }
  mixin IdTemplate;
}

struct OrganizationId {
  string value;
  this(string value) { this.value = value; }
  mixin IdTemplate;
}

struct EncounterId {
  string value;
  this(string value) { this.value = value; }
  mixin IdTemplate;
}

struct MedicationId {
  string value;
  this(string value) { this.value = value; }
  mixin IdTemplate;
}

struct MedicationRequestId {
  string value;
  this(string value) { this.value = value; }
  mixin IdTemplate;
}


// --- FHIR Coding helper struct ---
struct FhirCoding {
  string system_;
  string code_;
  string display_;

  Json toJson() const @safe {
    return Json.emptyObject
      .set("system", system_)
      .set("code", code_)
      .set("display", display_);
  }
}

struct FhirCodeableConcept {
  FhirCoding[] coding_;
  string text_;

  Json toJson() const @safe {
    auto arr = Json.emptyArray;
    foreach (c; coding_) arr ~= c.toJson();
    return Json.emptyObject
      .set("coding", arr)
      .set("text", text_);
  }
}

struct FhirHumanName {
  string use_;
  string family_;
  string[] given_;

  Json toJson() const @safe {
    auto givenArr = Json.emptyArray;
    foreach (g; given_) givenArr ~= Json(g);
    return Json.emptyObject
      .set("use", use_)
      .set("family", family_)
      .set("given", givenArr);
  }
}

struct FhirAddress {
  string use_;
  string type_;
  string[] line_;
  string city_;
  string state_;
  string postalCode_;
  string country_;

  Json toJson() const @safe {
    auto lineArr = Json.emptyArray;
    foreach (l; line_) lineArr ~= Json(l);
    return Json.emptyObject
      .set("use", use_)
      .set("type", type_)
      .set("line", lineArr)
      .set("city", city_)
      .set("state", state_)
      .set("postalCode", postalCode_)
      .set("country", country_);
  }
}

struct FhirReference {
  string reference_;
  string display_;

  Json toJson() const @safe {
    return Json.emptyObject
      .set("reference", reference_)
      .set("display", display_);
  }
}

struct FhirQuantity {
  double value_;
  string unit_;
  string system_;
  string code_;

  Json toJson() const @safe {
    return Json.emptyObject
      .set("value", value_)
      .set("unit", unit_)
      .set("system", system_)
      .set("code", code_);
  }
}
