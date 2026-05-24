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