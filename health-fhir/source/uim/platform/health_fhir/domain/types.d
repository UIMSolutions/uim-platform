/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.health_fhir.domain.types;
import uim.platform.health_fhir;

mixin(ShowModule!());

@safe:

// --- FHIR Resource ID types ---
struct PatientId {
  string value;
  this(string value) { this.value = value; }
  mixin DomainId;
}

struct PractitionerId {
  string value;
  this(string value) { this.value = value; }
  mixin DomainId;
}

struct ObservationId {
  string value;
  this(string value) { this.value = value; }
  mixin DomainId;
}

struct ConditionId {
  string value;
  this(string value) { this.value = value; }
  mixin DomainId;
}

struct OrganizationId {
  string value;
  this(string value) { this.value = value; }
  mixin DomainId;
}

struct EncounterId {
  string value;
  this(string value) { this.value = value; }
  mixin DomainId;
}

struct MedicationId {
  string value;
  this(string value) { this.value = value; }
  mixin DomainId;
}

struct MedicationRequestId {
  string value;
  this(string value) { this.value = value; }
  mixin DomainId;
}

// --- FHIR domain enums ---
enum Gender : string {
  male_     = "male",
  female_   = "female",
  other_    = "other",
  unknown_  = "unknown"
}

enum ObservationStatus : string {
  registered_    = "registered",
  preliminary_   = "preliminary",
  final_         = "final",
  amended_       = "amended",
  corrected_     = "corrected",
  cancelled_     = "cancelled",
  enteredInError = "entered-in-error",
  unknown_       = "unknown"
}

enum ConditionClinicalStatus : string {
  active_     = "active",
  recurrence_ = "recurrence",
  relapse_    = "relapse",
  inactive_   = "inactive",
  remission_  = "remission",
  resolved_   = "resolved"
}

enum EncounterStatus : string {
  planned_      = "planned",
  arrived_      = "arrived",
  triaged_      = "triaged",
  inProgress_   = "in-progress",
  onLeave_      = "onleave",
  finished_     = "finished",
  cancelled_    = "cancelled",
  enteredInError = "entered-in-error",
  unknown_      = "unknown"
}

enum MedicationRequestStatus : string {
  active_        = "active",
  onHold_        = "on-hold",
  cancelled_     = "cancelled",
  completed_     = "completed",
  enteredInError = "entered-in-error",
  stopped_       = "stopped",
  draft_         = "draft",
  unknown_       = "unknown"
}

enum StorageBackend : string {
  memory_  = "memory",
  files_   = "files",
  mongodb_ = "mongodb"
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
