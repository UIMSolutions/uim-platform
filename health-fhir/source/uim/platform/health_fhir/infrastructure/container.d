/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.health_fhir.infrastructure.container;
import uim.platform.health_fhir;

// mixin(ShowModule!());

@safe:

struct Container {
  // --- Repositories (driven adapters) ---
  PatientRepository patientRepo;
  PractitionerRepository practitionerRepo;
  ObservationRepository observationRepo;
  ConditionRepository conditionRepo;
  OrganizationRepository organizationRepo;
  EncounterRepository encounterRepo;
  MedicationRepository medicationRepo;
  MedicationRequestRepository medicationRequestRepo;

  // --- Use cases (application layer) ---
  ManagePatientsUseCase managePatients;
  ManagePractitionersUseCase managePractitioners;
  ManageObservationsUseCase manageObservations;
  ManageConditionsUseCase manageConditions;
  ManageOrganizationsUseCase manageOrganizations;
  ManageEncountersUseCase manageEncounters;
  ManageMedicationsUseCase manageMedications;
  ManageMedicationRequestsUseCase manageMedicationRequests;

  // --- Controllers (driving adapters) ---
  PatientController patientController;
  PractitionerController practitionerController;
  ObservationController observationController;
  ConditionController conditionController;
  OrganizationController organizationController;
  EncounterController encounterController;
  MedicationController medicationController;
  MedicationRequestController medicationRequestController;
  CapabilityController capabilityController;
  HealthController healthController;
}

Container buildContainer(SrvConfig config) {
  Container c;

  // --- Infrastructure adapters (storage selection) ---
  final switch (config.storage) {
    case StorageBackend.files_:
      c.patientRepo            = new FilePatientRepository(config.dataPath);
      c.practitionerRepo       = new MemoryPractitionerRepository();
      c.observationRepo        = new MemoryObservationRepository();
      c.conditionRepo          = new MemoryConditionRepository();
      c.organizationRepo       = new MemoryOrganizationRepository();
      c.encounterRepo          = new MemoryEncounterRepository();
      c.medicationRepo         = new MemoryMedicationRepository();
      c.medicationRequestRepo  = new MemoryMedicationRequestRepository();
      break;

    case StorageBackend.mongodb_:
      c.patientRepo            = new MongoPatientRepository(config.mongoUri);
      c.practitionerRepo       = new MemoryPractitionerRepository();
      c.observationRepo        = new MemoryObservationRepository();
      c.conditionRepo          = new MemoryConditionRepository();
      c.organizationRepo       = new MemoryOrganizationRepository();
      c.encounterRepo          = new MemoryEncounterRepository();
      c.medicationRepo         = new MemoryMedicationRepository();
      c.medicationRequestRepo  = new MemoryMedicationRequestRepository();
      break;

    case StorageBackend.memory_:
      c.patientRepo            = new MemoryPatientRepository();
      c.practitionerRepo       = new MemoryPractitionerRepository();
      c.observationRepo        = new MemoryObservationRepository();
      c.conditionRepo          = new MemoryConditionRepository();
      c.organizationRepo       = new MemoryOrganizationRepository();
      c.encounterRepo          = new MemoryEncounterRepository();
      c.medicationRepo         = new MemoryMedicationRepository();
      c.medicationRequestRepo  = new MemoryMedicationRequestRepository();
      break;
  }

  // --- Application use cases ---
  c.managePatients           = new ManagePatientsUseCase(c.patientRepo);
  c.managePractitioners      = new ManagePractitionersUseCase(c.practitionerRepo);
  c.manageObservations       = new ManageObservationsUseCase(c.observationRepo);
  c.manageConditions         = new ManageConditionsUseCase(c.conditionRepo);
  c.manageOrganizations      = new ManageOrganizationsUseCase(c.organizationRepo);
  c.manageEncounters         = new ManageEncountersUseCase(c.encounterRepo);
  c.manageMedications        = new ManageMedicationsUseCase(c.medicationRepo);
  c.manageMedicationRequests = new ManageMedicationRequestsUseCase(c.medicationRequestRepo);

  // --- Presentation controllers ---
  c.patientController           = new PatientController(c.managePatients);
  c.practitionerController      = new PractitionerController(c.managePractitioners);
  c.observationController       = new ObservationController(c.manageObservations);
  c.conditionController         = new ConditionController(c.manageConditions);
  c.organizationController      = new OrganizationController(c.manageOrganizations);
  c.encounterController         = new EncounterController(c.manageEncounters);
  c.medicationController        = new MedicationController(c.manageMedications);
  c.medicationRequestController = new MedicationRequestController(c.manageMedicationRequests);
  c.capabilityController        = new CapabilityController();
  c.healthController            = new HealthController();

  return c;
}
