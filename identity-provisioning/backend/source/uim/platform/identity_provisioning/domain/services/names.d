/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Naming rules and derived display names.
module uim.platform.identity_provisioning.domain.services.names;

import uim.platform.identity_provisioning;

mixin(ShowModule!());

@safe:

/// A display name (system, transformation, job): 1–120 characters, no surrounding blanks.
void validateDisplayName(string kind, string name) {
  validate(name.strip.length > 0, kind ~ " name is required");
  validate(name.length <= 120, kind ~ " name must not exceed 120 characters");
  validate(name == name.strip, kind ~ " name must not start or end with blanks");
}

/// "HR → IAS (delta)".
string jobName(string sourceName, string targetName, JobType type) {
  return sourceName ~ " → " ~ targetName ~ " (" ~ enumText(type) ~ ")";
}

/// "create user ada.lovelace".
string logName(OperationType operation, EntityType type, string entityName) {
  return enumText(operation) ~ " " ~ enumText(type) ~ " " ~ entityName;
}

///
unittest {
  validateDisplayName("System", "HR");
  bool failed;
  try validateDisplayName("System", " HR");
  catch (ProvisioningValidationException) failed = true;
  assert(failed);
  assert(jobName("HR", "IAS", JobType.delta) == "HR → IAS (delta)");
  assert(logName(OperationType.delete_, EntityType.group, "Finance") == "delete group Finance");
}
