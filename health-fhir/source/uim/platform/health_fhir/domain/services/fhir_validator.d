/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.health_fhir.domain.services.fhir_validator;
import uim.platform.health_fhir;

mixin(ShowModule!());

@safe:

/// FHIR domain validation helpers
struct FhirValidator {
  static string validateResourceId(string id) {
    if (id.length == 0)
      return "Resource ID must not be empty";
    if (id.length > 64)
      return "Resource ID must not exceed 64 characters";
    return "";
  }

  static string validatePatient(string id, string familyName) {
    auto err = validateResourceId(id);
    if (err.length > 0) return err;
    if (familyName.length == 0)
      return "Patient family name is required";
    return "";
  }

  static string validateObservation(string id, string statusStr) {
    auto err = validateResourceId(id);
    if (err.length > 0) return err;
    if (statusStr.length == 0)
      return "Observation status is required";
    return "";
  }

  static string validatePractitioner(string id) {
    return validateResourceId(id);
  }

  static string validateOrganization(string id, string name) {
    auto err = validateResourceId(id);
    if (err.length > 0) return err;
    if (name.length == 0)
      return "Organization name is required";
    return "";
  }

  static string validateEncounter(string id) {
    return validateResourceId(id);
  }

  static string validateCondition(string id) {
    return validateResourceId(id);
  }

  static string validateMedication(string id) {
    return validateResourceId(id);
  }

  static string validateMedicationRequest(string id) {
    return validateResourceId(id);
  }
}
