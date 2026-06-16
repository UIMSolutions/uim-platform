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
  male_ = "male",
  female_ = "female",
  other_ = "other",
  unknown_ = "unknown"
}

Gender toGender(string s) {
  const map = [
    "male": Gender.male_,
    "female": Gender.female_,
    "other": Gender.other_,
    "unknown": Gender.unknown_
  ];
  return map.get(s.toLower, Gender.unknown_);
}

enum AdministrativeGender : string {
  male_ = "male",
  female_ = "female",
  other_ = "other",
  unknown_ = "unknown"
}

AdministrativeGender toAdministrativeGender(string s) {
  const map = [
    "male": AdministrativeGender.male_,
    "female": AdministrativeGender.female_,
    "other": AdministrativeGender.other_,
    "unknown": AdministrativeGender.unknown_
  ];
  return map.get(s.toLower, AdministrativeGender.unknown_);
}

enum MaritalStatus : string {
  unmarried_ = "unmarried",
  married_ = "married",
  divorced_ = "divorced",
  widowed_ = "widowed",
  unknown_ = "unknown"
}

MaritalStatus toMaritalStatus(string s) {
  const map = [
    "unmarried": MaritalStatus.unmarried_,
    "married": MaritalStatus.married_,
    "divorced": MaritalStatus.divorced_,
    "widowed": MaritalStatus.widowed_,
    "unknown": MaritalStatus.unknown_
  ];
  return map.get(s.toLower, MaritalStatus.unknown_);
}

enum ObservationStatus : string {
  registered_ = "registered",
  preliminary_ = "preliminary",
  final_ = "final",
  amended_ = "amended",
  corrected_ = "corrected",
  cancelled_ = "cancelled",
  enteredInError = "entered-in-error",
  unknown_ = "unknown"
}

ObservationStatus toObservationStatus(string s) {
  const map = [
    "registered": ObservationStatus.registered_,
    "preliminary": ObservationStatus.preliminary_,
    "final": ObservationStatus.final_,
    "amended": ObservationStatus.amended_,
    "corrected": ObservationStatus.corrected_,
    "cancelled": ObservationStatus.cancelled_,
    "entered-in-error": ObservationStatus.enteredInError
  ];
  return map.get(s.toLower, ObservationStatus.unknown_);
}

enum ConditionClinicalStatus : string {
  active_ = "active",
  recurrence_ = "recurrence",
  relapse_ = "relapse",
  inactive_ = "inactive",
  remission_ = "remission",
  resolved_ = "resolved"
}

ConditionClinicalStatus toConditionClinicalStatus(string s) {
  const map = [
    "active": ConditionClinicalStatus.active_,
    "recurrence": ConditionClinicalStatus.recurrence_,
    "relapse": ConditionClinicalStatus.relapse_,
    "inactive": ConditionClinicalStatus.inactive_,
    "remission": ConditionClinicalStatus.remission_,
    "resolved": ConditionClinicalStatus.resolved_
  ];
  return map.get(s.toLower, ConditionClinicalStatus.inactive_);
}

enum EncounterStatus : string {
  planned_ = "planned",
  arrived_ = "arrived",
  triaged_ = "triaged",
  inProgress_ = "in-progress",
  onLeave_ = "onleave",
  finished_ = "finished",
  cancelled_ = "cancelled",
  enteredInError = "entered-in-error",
  unknown_ = "unknown"
}

EncounterStatus toEncounterStatus(string s) {
  const map = [
    "planned": EncounterStatus.planned_,
    "arrived": EncounterStatus.arrived_,
    "triaged": EncounterStatus.triaged_,
    "in-progress": EncounterStatus.inProgress_,
    "onleave": EncounterStatus.onLeave_,
    "finished": EncounterStatus.finished_,
    "cancelled": EncounterStatus.cancelled_,
    "entered-in-error": EncounterStatus.enteredInError
  ];
  return map.get(s.toLower, EncounterStatus.unknown_);
}

enum MedicationRequestStatus : string {
  active_ = "active",
  onHold_ = "on-hold",
  cancelled_ = "cancelled",
  completed_ = "completed",
  enteredInError = "entered-in-error",
  stopped_ = "stopped",
  draft_ = "draft",
  unknown_ = "unknown"
}

MedicationRequestStatus toMedicationRequestStatus(string s) {
  const map = [
    "active": MedicationRequestStatus.active_,
    "on-hold": MedicationRequestStatus.onHold_,
    "cancelled": MedicationRequestStatus.cancelled_,
    "completed": MedicationRequestStatus.completed_,
    "entered-in-error": MedicationRequestStatus.enteredInError,
    "stopped": MedicationRequestStatus.stopped_,
    "draft": MedicationRequestStatus.draft_
  ];
  return map.get(s.toLower, MedicationRequestStatus.unknown_);
}

enum StorageBackend : string {
  memory_ = "memory",
  files_ = "files",
  mongodb_ = "mongodb"
}

StorageBackend toStorageBackend(string s) {
  const map = [
    "memory": StorageBackend.memory_,
    "files": StorageBackend.files_,
    "mongodb": StorageBackend.mongodb_
  ];
  return map.get(s.toLower, StorageBackend.memory_);
}
