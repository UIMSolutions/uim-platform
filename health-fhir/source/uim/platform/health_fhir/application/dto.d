/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.health_fhir.application.dto;
import uim.platform.health_fhir;
mixin(ShowModule!());

@safe:

// --- Patient ---
struct CreatePatientRequest {
  TenantId tenantId;
  PatientId patientId;
  FhirHumanName[] name_;
  string birthDate_;
  Gender gender_;
  FhirAddress[] address_;
  bool active_;
  string[] telecom_;
}

struct UpdatePatientRequest {
  TenantId tenantId;
  PatientId patientId;
  FhirHumanName[] name_;
  string birthDate_;
  Gender gender_;
  FhirAddress[] address_;
  bool active_;
  string[] telecom_;
}

// --- Practitioner ---
struct CreatePractitionerRequest {
  TenantId tenantId;
  PractitionerId practitionerId;
  FhirHumanName[] name_;
  Gender gender_;
  string birthDate_;
  FhirAddress[] address_;
  bool active_;
  string[] telecom_;
  FhirCodeableConcept[] qualification_;
}

struct UpdatePractitionerRequest {
  TenantId tenantId;
  PractitionerId practitionerId;
  FhirHumanName[] name_;
  Gender gender_;
  string birthDate_;
  FhirAddress[] address_;
  bool active_;
  string[] telecom_;
  FhirCodeableConcept[] qualification_;
}

// --- Observation ---
struct CreateObservationRequest {
  TenantId tenantId;
  ObservationId observationId;
  ObservationStatus status_;
  FhirCodeableConcept code_;
  FhirReference subject_;
  FhirReference encounter_;
  string effectiveDateTime_;
  FhirQuantity valueQuantity_;
  string valueString_;
  FhirCodeableConcept[] category_;
  FhirReference performer_;
  string note_;
}

struct UpdateObservationRequest {
  TenantId tenantId;
  ObservationId observationId;
  ObservationStatus status_;
  FhirCodeableConcept code_;
  FhirReference subject_;
  FhirReference encounter_;
  string effectiveDateTime_;
  FhirQuantity valueQuantity_;
  string valueString_;
  FhirCodeableConcept[] category_;
  FhirReference performer_;
  string note_;
}

// --- Condition ---
struct CreateConditionRequest {
  TenantId tenantId;
  ConditionId conditionId;
  FhirCodeableConcept clinicalStatus_;
  FhirCodeableConcept verificationStatus_;
  FhirCodeableConcept[] category_;
  FhirCodeableConcept severity_;
  FhirCodeableConcept code_;
  FhirReference subject_;
  FhirReference encounter_;
  string onsetDateTime_;
  string abatementDateTime_;
  string recordedDate_;
  FhirReference recorder_;
  string note_;
}

struct UpdateConditionRequest {
  TenantId tenantId;
  ConditionId conditionId;
  FhirCodeableConcept clinicalStatus_;
  FhirCodeableConcept verificationStatus_;
  FhirCodeableConcept[] category_;
  FhirCodeableConcept severity_;
  FhirCodeableConcept code_;
  FhirReference subject_;
  FhirReference encounter_;
  string onsetDateTime_;
  string abatementDateTime_;
  string recordedDate_;
  FhirReference recorder_;
  string note_;
}

// --- Organization ---
struct CreateOrganizationRequest {
  TenantId tenantId;
  OrganizationId organizationId;
  bool active_;
  FhirCodeableConcept[] type_;
  string name_;
  string[] alias_;
  string[] telecom_;
  FhirAddress[] address_;
  FhirReference partOf_;
}

struct UpdateOrganizationRequest {
  TenantId tenantId;
  OrganizationId organizationId;
  bool active_;
  FhirCodeableConcept[] type_;
  string name_;
  string[] alias_;
  string[] telecom_;
  FhirAddress[] address_;
  FhirReference partOf_;
}

// --- Encounter ---
struct CreateEncounterRequest {
  TenantId tenantId;
  EncounterId encounterId;
  EncounterStatus status_;
  FhirCodeableConcept class_;
  FhirCodeableConcept[] type_;
  FhirReference subject_;
  FhirReference[] participant_;
  string periodStart_;
  string periodEnd_;
  FhirReference[] reasonReference_;
  FhirCodeableConcept[] reasonCode_;
  FhirReference serviceProvider_;
}

struct UpdateEncounterRequest {
  TenantId tenantId;
  EncounterId encounterId;
  EncounterStatus status_;
  FhirCodeableConcept class_;
  FhirCodeableConcept[] type_;
  FhirReference subject_;
  FhirReference[] participant_;
  string periodStart_;
  string periodEnd_;
  FhirReference[] reasonReference_;
  FhirCodeableConcept[] reasonCode_;
  FhirReference serviceProvider_;
}

// --- Medication ---
struct CreateMedicationRequest {
  TenantId tenantId;
  MedicationId medicationId;
  FhirCodeableConcept code_;
  FhirCodeableConcept status_;
  FhirReference manufacturer_;
  FhirCodeableConcept form_;
  FhirQuantity amount_;
  string[] ingredient_;
}

struct UpdateMedicationRequest {
  TenantId tenantId;
  MedicationId medicationId;
  FhirCodeableConcept code_;
  FhirCodeableConcept status_;
  FhirReference manufacturer_;
  FhirCodeableConcept form_;
  FhirQuantity amount_;
  string[] ingredient_;
}

// --- MedicationRequest ---
struct CreateMedicationOrderRequest {
  TenantId tenantId;
  MedicationRequestId medicationRequestId;
  MedicationRequestStatus status_;
  FhirCodeableConcept intent_;
  FhirReference medicationReference_;
  FhirReference subject_;
  FhirReference encounter_;
  string authoredOn_;
  FhirReference requester_;
  FhirReference recorder_;
  FhirCodeableConcept[] reasonCode_;
  FhirReference[] reasonReference_;
  string note_;
  string dosageInstructionText_;
}

struct UpdateMedicationOrderRequest {
  TenantId tenantId;
  MedicationRequestId medicationRequestId;
  MedicationRequestStatus status_;
  FhirCodeableConcept intent_;
  FhirReference medicationReference_;
  FhirReference subject_;
  FhirReference encounter_;
  string authoredOn_;
  FhirReference requester_;
  FhirReference recorder_;
  FhirCodeableConcept[] reasonCode_;
  FhirReference[] reasonReference_;
  string note_;
  string dosageInstructionText_;
}
