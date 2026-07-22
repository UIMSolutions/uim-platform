/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.health_fhir.domain.enumerations;

import uim.platform.health_fhir;

mixin(ShowModule!());

@safe:

// --- FHIR domain enums ---
enum Gender : string {
  male_ = "male",
  female_ = "female",
  other_ = "other",
  unknown_ = "unknown"
}

Gender toGender(string value) {
  switch (value.toLower) {
  case "male":
    return Gender.male_;
  case "female":
    return Gender.female_;
  case "other":
    return Gender.other_;
  case "unknown":
    return Gender.unknown_;
  default:
    return Gender.unknown_;
  }
}

Gender[] toGenders(string[] values)
  => values.map!toGender;

string toString(Gender value)
  => cast(string)value;

string[] toStrings(Gender[] values)
  => values.map!toString.array;

///
unittest {
  mixin(ShowTest!("Gender"));

  assert("male".toGender == Gender.male_);
  assert("female".toGender == Gender.female_);
  assert("other".toGender == Gender.other_);
  assert("unknown".toGender == Gender.unknown_);

  assert("".toGender == Gender.unknown_);
  assert("something".toGender == Gender.unknown_);

  assert(Gender.male_.toString == "male");
  assert(Gender.female_.toString == "female");
  assert(Gender.other_.toString == "other");
  assert(Gender.unknown_.toString == "unknown");

  assert(["male", "female"].toGenders == [
      Gender.male_, Gender.female_
    ]);

  assert([Gender.male_, Gender.female_].toStrings == ["male", "female"]);
}

enum AdministrativeGender : string {
  male_ = "male",
  female_ = "female",
  other_ = "other",
  unknown_ = "unknown"
}

AdministrativeGender toAdministrativeGender(string value) {
  switch (value.toLower) {
  case "male":
    return AdministrativeGender.male_;
  case "female":
    return AdministrativeGender.female_;
  case "other":
    return AdministrativeGender.other_;
  case "unknown":
    return AdministrativeGender.unknown_;
  default:
    return AdministrativeGender.unknown_;
  }
}

AdministrativeGender[] toAdministrativeGenders(string[] values)
  => values.map!toAdministrativeGender;

string toString(AdministrativeGender value)
  => cast(string)value;

string[] toStrings(AdministrativeGender[] values)
  => values.map!toString.array;

///
unittest {
  mixin(ShowTest!("AdministrativeGender"));

  assert("male".toAdministrativeGender == AdministrativeGender.male_);
  assert("female".toAdministrativeGender == AdministrativeGender.female_);
  assert("other".toAdministrativeGender == AdministrativeGender.other_);
  assert("unknown".toAdministrativeGender == AdministrativeGender.unknown_);

  assert("".toAdministrativeGender == AdministrativeGender.unknown_);
  assert("something".toAdministrativeGender == AdministrativeGender.unknown_);

  assert(AdministrativeGender.male_.toString == "male");
  assert(AdministrativeGender.female_.toString == "female");
  assert(AdministrativeGender.other_.toString == "other");
  assert(AdministrativeGender.unknown_.toString == "unknown");

  assert(["male", "female"].toAdministrativeGenders == [
      AdministrativeGender.male_, AdministrativeGender.female_
    ]);

  assert([AdministrativeGender.male_, AdministrativeGender.female_].toStrings == [
      "male", "female"
    ]);
}

enum MaritalStatus : string {
  unmarried_ = "unmarried",
  married_ = "married",
  divorced_ = "divorced",
  widowed_ = "widowed",
  unknown_ = "unknown"
}

MaritalStatus toMaritalStatus(string value) {
  switch (value.toLower) {
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

MaritalStatus[] toMaritalStatuses(string[] values)
  => values.map!toMaritalStatus;

string toString(MaritalStatus value)
  => cast(string)value;

string[] toStrings(MaritalStatus[] values)
  => values.map!toString.array;

///
unittest {
  mixin(ShowTest!("MaritalStatus"));

  assert("unmarried".toMaritalStatus == MaritalStatus.unmarried_);
  assert("married".toMaritalStatus == MaritalStatus.married_);
  assert("divorced".toMaritalStatus == MaritalStatus.divorced_);
  assert("widowed".toMaritalStatus == MaritalStatus.widowed_);

  assert("".toMaritalStatus == MaritalStatus.unknown_);
  assert("something".toMaritalStatus == MaritalStatus.unknown_);

  assert(MaritalStatus.unmarried_.toString == "unmarried");
  assert(MaritalStatus.married_.toString == "married");
  assert(MaritalStatus.divorced_.toString == "divorced");
  assert(MaritalStatus.widowed_.toString == "widowed");

  assert(["unmarried", "married"].toMaritalStatuses == [
      MaritalStatus.unmarried_, MaritalStatus.married_
    ]);

  assert([MaritalStatus.unmarried_, MaritalStatus.married_].toStrings == [
      "unmarried", "married"
    ]);
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

ObservationStatus toObservationStatus(string value) {
  switch (value.toLower) {
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

ObservationStatus[] toObservationStatuses(string[] values)
  => values.map!toObservationStatus;

string toString(ObservationStatus value)
  => cast(string)value;

string[] toStrings(ObservationStatus[] values)
  => values.map!toString.array;

/// 
unittest {
  mixin(ShowTest!("ObservationStatus"));

  assert("registered".toObservationStatus == ObservationStatus.registered_);
  assert("preliminary".toObservationStatus == ObservationStatus.preliminary_);
  assert("final".toObservationStatus == ObservationStatus.final_);
  assert("amended".toObservationStatus == ObservationStatus.amended_);
  assert("corrected".toObservationStatus == ObservationStatus.corrected_);
  assert("cancelled".toObservationStatus == ObservationStatus.cancelled_);
  assert("entered-in-error".toObservationStatus == ObservationStatus.enteredInError);

  assert("".toObservationStatus == ObservationStatus.unknown_);
  assert("something".toObservationStatus == ObservationStatus.unknown_);

  assert(ObservationStatus.registered_.toString == "registered");
  assert(ObservationStatus.preliminary_.toString == "preliminary");
  assert(ObservationStatus.final_.toString == "final");
  assert(ObservationStatus.amended_.toString == "amended");
  assert(ObservationStatus.corrected_.toString == "corrected");
  assert(ObservationStatus.cancelled_.toString == "cancelled");
  assert(ObservationStatus.enteredInError.toString == "entered-in-error");

  assert(["registered", "preliminary"].toObservationStatuses == [
      ObservationStatus.registered_, ObservationStatus.preliminary_
    ]);

  assert([ObservationStatus.registered_, ObservationStatus.preliminary_].toStrings == [
      "registered", "preliminary"
    ]);
}

enum ConditionClinicalStatus : string {
  active_ = "active",
  recurrence_ = "recurrence",
  relapse_ = "relapse",
  inactive_ = "inactive",
  remission_ = "remission",
  resolved_ = "resolved"
}

ConditionClinicalStatus toConditionClinicalStatus(string value) {
  switch (value.toLower) {
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
    return ConditionClinicalStatus.active_; // Default to active if unknown
  }
}

ConditionClinicalStatus[] toConditionClinicalStatuses(string[] values)
  => values.map!toConditionClinicalStatus;

string toString(ConditionClinicalStatus value)
  => cast(string)value;

string[] toStrings(ConditionClinicalStatus[] values)
  => values.map!toString.array;

/// 
unittest {
  mixin(ShowTest!("ConditionClinicalStatus"));

  assert("active".toConditionClinicalStatus == ConditionClinicalStatus.active_);
  assert("recurrence".toConditionClinicalStatus == ConditionClinicalStatus.recurrence_);
  assert("relapse".toConditionClinicalStatus == ConditionClinicalStatus.relapse_);
  assert("inactive".toConditionClinicalStatus == ConditionClinicalStatus.inactive_);
  assert("remission".toConditionClinicalStatus == ConditionClinicalStatus.remission_);
  assert("resolved".toConditionClinicalStatus == ConditionClinicalStatus.resolved_);

  assert("".toConditionClinicalStatus == ConditionClinicalStatus.active_);
  assert("something".toConditionClinicalStatus == ConditionClinicalStatus.active_);

  assert(ConditionClinicalStatus.active_.toString == "active");
  assert(ConditionClinicalStatus.recurrence_.toString == "recurrence");
  assert(ConditionClinicalStatus.relapse_.toString == "relapse");
  assert(ConditionClinicalStatus.inactive_.toString == "inactive");
  assert(ConditionClinicalStatus.remission_.toString == "remission");
  assert(ConditionClinicalStatus.resolved_.toString == "resolved");

  assert(["active", "recurrence"].toConditionClinicalStatuses == [
      ConditionClinicalStatus.active_, ConditionClinicalStatus.recurrence_
    ]);
  assert([ConditionClinicalStatus.active_, ConditionClinicalStatus.recurrence_].toStrings == [
      "active", "recurrence"
    ]);
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

EncounterStatus toEncounterStatus(string value) {
  switch (value.toLower) {
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

EncounterStatus[] toEncounterStatuses(string[] values)
  => values.map!toEncounterStatus;

string toString(EncounterStatus value)
  => cast(string)value;

string[] toStrings(EncounterStatus[] values)
  => values.map!toString.array;

/// 
unittest {
  mixin(ShowTest!("EncounterStatus"));

  assert("planned".toEncounterStatus == EncounterStatus.planned_);
  assert("arrived".toEncounterStatus == EncounterStatus.arrived_);
  assert("triaged".toEncounterStatus == EncounterStatus.triaged_);
  assert("in-progress".toEncounterStatus == EncounterStatus.inProgress_);
  assert("onleave".toEncounterStatus == EncounterStatus.onLeave_);
  assert("finished".toEncounterStatus == EncounterStatus.finished_);
  assert("cancelled".toEncounterStatus == EncounterStatus.cancelled_);
  assert("entered-in-error".toEncounterStatus == EncounterStatus.enteredInError);

  assert("".toEncounterStatus == EncounterStatus.unknown_);
  assert("something".toEncounterStatus == EncounterStatus.unknown_);

  assert(EncounterStatus.planned_.toString == "planned");
  assert(EncounterStatus.arrived_.toString == "arrived");
  assert(EncounterStatus.triaged_.toString == "triaged");
  assert(EncounterStatus.inProgress_.toString == "in-progress");
  assert(EncounterStatus.onLeave_.toString == "onleave");
  assert(EncounterStatus.finished_.toString == "finished");
  assert(EncounterStatus.cancelled_.toString == "cancelled");
  assert(EncounterStatus.enteredInError.toString == "entered-in-error");

  assert(["planned", "arrived"].toEncounterStatuses == [
      EncounterStatus.planned_, EncounterStatus.arrived_
    ]);
  assert([EncounterStatus.planned_, EncounterStatus.arrived_].toStrings == [
      "planned", "arrived"
    ]);
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

MedicationRequestStatus toMedicationRequestStatus(string value) {
  switch (value.toLower()) {
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

MedicationRequestStatus[] toMedicationRequestStatuses(string[] values)
  => values.map!toMedicationRequestStatus;

string toString(MedicationRequestStatus value)
  => cast(string)value;

string[] toStrings(MedicationRequestStatus[] values)
  => values.map!toString.array;

/// 
unittest {
  mixin(ShowTest!("MedicationRequestStatus"));

  assert("active".toMedicationRequestStatus == MedicationRequestStatus.active_);
  assert("on-hold".toMedicationRequestStatus == MedicationRequestStatus.onHold_);
  assert("cancelled".toMedicationRequestStatus == MedicationRequestStatus.cancelled_);
  assert("completed".toMedicationRequestStatus == MedicationRequestStatus.completed_);
  assert("entered-in-error".toMedicationRequestStatus == MedicationRequestStatus.enteredInError);
  assert("stopped".toMedicationRequestStatus == MedicationRequestStatus.stopped_);
  assert("draft".toMedicationRequestStatus == MedicationRequestStatus.draft_);

  assert("".toMedicationRequestStatus == MedicationRequestStatus.unknown_);
  assert("something".toMedicationRequestStatus == MedicationRequestStatus.unknown_);

  assert(MedicationRequestStatus.active_.toString == "active");
  assert(MedicationRequestStatus.onHold_.toString == "on-hold");
  assert(MedicationRequestStatus.cancelled_.toString == "cancelled");
  assert(MedicationRequestStatus.completed_.toString == "completed");
  assert(MedicationRequestStatus.enteredInError.toString == "entered-in-error");
  assert(MedicationRequestStatus.stopped_.toString == "stopped");
  assert(MedicationRequestStatus.draft_.toString == "draft");

  assert(["active", "on-hold"].toMedicationRequestStatuses == [
      MedicationRequestStatus.active_, MedicationRequestStatus.onHold_
    ]);
  assert([MedicationRequestStatus.active_, MedicationRequestStatus.onHold_].toStrings == [
      "active", "on-hold"
    ]);
}

enum StorageBackend : string {
  memory_ = "memory",
  files_ = "files",
  mongodb_ = "mongodb"
}

StorageBackend toStorageBackend(string value) {
  mixin(EnumSwitch("StorageBackend", "memory"));
}

StorageBackend[] toStorageBackends(string[] values)
  => values.map!toStorageBackend.array;

string toString(StorageBackend value)
  => cast(string)value;

string[] toStrings(StorageBackend[] values)
  => values.map!toString.array;

///
unittest {
  mixin(ShowTest!("StorageBackend"));

  assert("memory".toStorageBackend == StorageBackend.memory_);
  assert("files".toStorageBackend == StorageBackend.files_);
  assert("mongodb".toStorageBackend == StorageBackend.mongodb_);

  assert("".toStorageBackend == StorageBackend.memory_);
  assert("unknown".toStorageBackend == StorageBackend.memory_);

  assert(StorageBackend.memory_.toString == "memory");
  assert(StorageBackend.files_.toString == "files");
  assert(StorageBackend.mongodb_.toString == "mongodb");

  assert(["memory", "files"].toStorageBackends == [
      StorageBackend.memory_, StorageBackend.files_
    ]);
  assert([StorageBackend.memory_, StorageBackend.files_].toStrings == [
      "memory", "files"
    ]);
}
