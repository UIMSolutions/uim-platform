/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.health_fhir.domain.enumerations;

import uim.platform.health_fhir;

// mixin(ShowModule!());

@safe:

// --- FHIR domain enums ---
enum Gender : string {
  male_     = "male",
  female_   = "female",
  other_    = "other",
  unknown_  = "unknown"
}
Gender toGender(string s) {
  switch (s) {
    case "male":
      return Gender.male_;
    case "female":
      return Gender.female_;
    case "other":
      return Gender.other_;
    default:
      return Gender.unknown_;
  }
}

enum AdministrativeGender : string {
  male_     = "male",
  female_   = "female",
  other_    = "other",
  unknown_  = "unknown"
}
AdministrativeGender toAdministrativeGender(string s) {
  switch (s) {
    case "male":
      return AdministrativeGender.male_;
    case "female":
      return AdministrativeGender.female_;
    case "other":
      return AdministrativeGender.other_;
    default:
      return AdministrativeGender.unknown_;
  }
}

enum MaritalStatus : string {
  unmarried_ = "unmarried",
  married_   = "married",
  divorced_  = "divorced",
  widowed_   = "widowed",
  unknown_   = "unknown"
}
MaritalStatus toMaritalStatus(string s) {
  switch (s) {
    case "unmarried":
      return MaritalStatus.unmarried_;
    case "married":
      return MaritalStatus.married_;
    case "divorced":
      return MaritalStatus.divorced_;
    case "widowed":
      return MaritalStatus.widowed_;
    default:
      return MaritalStatus.unknown_;
  }
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
ObservationStatus toObservationStatus(string s) {
  switch (s) {
    case "registered":
      return ObservationStatus.registered_;
    case "preliminary":
      return ObservationStatus.preliminary_;
    case "final":
      return ObservationStatus.final_;
    case "amended":
      return ObservationStatus.amended_;
    case "corrected":
      return ObservationStatus.corrected_;
    case "cancelled":
      return ObservationStatus.cancelled_;
    case "entered-in-error":
      return ObservationStatus.enteredInError;
    default:
      return ObservationStatus.unknown_;
  }
}

enum ConditionClinicalStatus : string {
  active_     = "active",
  recurrence_ = "recurrence",
  relapse_    = "relapse",
  inactive_   = "inactive",
  remission_  = "remission",
  resolved_   = "resolved"
}
ConditionClinicalStatus toConditionClinicalStatus(string s) {
  switch (s) {
    case "active":
      return ConditionClinicalStatus.active_;
    case "recurrence":
      return ConditionClinicalStatus.recurrence_;
    case "relapse":
      return ConditionClinicalStatus.relapse_;
    case "inactive":
      return ConditionClinicalStatus.inactive_;
    case "remission":
      return ConditionClinicalStatus.remission_;
    case "resolved":
      return ConditionClinicalStatus.resolved_;
    default:
      return ConditionClinicalStatus.inactive_; // default to inactive if unknown
  }
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
EncounterStatus toEncounterStatus(string s) {
  switch (s) {
    case "planned":
      return EncounterStatus.planned_;
    case "arrived":
      return EncounterStatus.arrived_;
    case "triaged":
      return EncounterStatus.triaged_;
    case "in-progress":
      return EncounterStatus.inProgress_;
    case "onleave":
      return EncounterStatus.onLeave_;
    case "finished":
      return EncounterStatus.finished_;
    case "cancelled":
      return EncounterStatus.cancelled_;
    case "entered-in-error":
      return EncounterStatus.enteredInError;
    default:
      return EncounterStatus.unknown_;
  }
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
MedicationRequestStatus toMedicationRequestStatus(string s) {
  switch (s) {
    case "active":
      return MedicationRequestStatus.active_;
    case "on-hold":
      return MedicationRequestStatus.onHold_;
    case "cancelled":
      return MedicationRequestStatus.cancelled_;
    case "completed":
      return MedicationRequestStatus.completed_;
    case "entered-in-error":
      return MedicationRequestStatus.enteredInError;
    case "stopped":
      return MedicationRequestStatus.stopped_;
    case "draft":
      return MedicationRequestStatus.draft_;
    default:
      return MedicationRequestStatus.unknown_;
  }
}

enum StorageBackend : string {
  memory_  = "memory",
  files_   = "files",
  mongodb_ = "mongodb"
}
StorageBackend toStorageBackend(string s) {
  switch (s) {
    case "memory":
      return StorageBackend.memory_;
    case "files":
      return StorageBackend.files_;
    case "mongodb":
      return StorageBackend.mongodb_;
    default:
      return StorageBackend.memory_; // default to memory if unknown
  }
}