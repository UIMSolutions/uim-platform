/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.infrastructure.container;

// import uim.platform.data.privacy.infrastructure.config;

// // Repositories
// import uim.platform.data.privacy.infrastructure.persistence.memory.data_subject;
// import uim.platform.data.privacy.infrastructure.persistence.memory.personal_data_model;
// import uim.platform.data.privacy.infrastructure.persistence.memory.deletion_request;
// import uim.platform.data.privacy.infrastructure.persistence.memory.blocking_request;
// import uim.platform.data.privacy.infrastructure.persistence.memory.legal_ground;
// import uim.platform.data.privacy.infrastructure.persistence.memory.retention_rule;
// import uim.platform.data.privacy.infrastructure.persistence.memory.consent_record;
// import uim.platform.data.privacy.infrastructure.persistence.memory.data_retrieval;
// import uim.platform.data.privacy.infrastructure.persistence.memory.data_controller;
// import uim.platform.data.privacy.infrastructure.persistence.memory.data_controller_group;
// import uim.platform.data.privacy.infrastructure.persistence.memory.business_context;
// import uim.platform.data.privacy.infrastructure.persistence.memory.business_process;
// import uim.platform.data.privacy.infrastructure.persistence.memory.business_subprocess;
// import uim.platform.data.privacy.infrastructure.persistence.memory.correction_request;
// import uim.platform.data.privacy.infrastructure.persistence.memory.archive_request;
// import uim.platform.data.privacy.infrastructure.persistence.memory.destruction_request;
// import uim.platform.data.privacy.infrastructure.persistence.memory.purpose_record;
// import uim.platform.data.privacy.infrastructure.persistence.memory.consent_purpose;
// import uim.platform.data.privacy.infrastructure.persistence.memory.rule_set;
// import uim.platform.data.privacy.infrastructure.persistence.memory.information_report;
// import uim.platform.data.privacy.infrastructure.persistence.memory.anonymization_config;

// // Use Cases
// import uim.platform.data.privacy.application.usecases.manage.data_subjects;
// import uim.platform.data.privacy.application.usecases.manage.personal_data_models;
// import uim.platform.data.privacy.application.usecases.manage.deletion_requests;
// import uim.platform.data.privacy.application.usecases.manage.blocking_requests;
// import uim.platform.data.privacy.application.usecases.manage.legal_grounds;
// import uim.platform.data.privacy.application.usecases.manage.retention_rules;
// import uim.platform.data.privacy.application.usecases.manage.consent_records;
// import uim.platform.data.privacy.application.usecases.manage.data_retrievals;
// import uim.platform.data.privacy.application.usecases.manage.data_controllers;
// import uim.platform.data.privacy.application.usecases.manage.data_controller_groups;
// import uim.platform.data.privacy.application.usecases.manage.business_contexts;
// import uim.platform.data.privacy.application.usecases.manage.business_processes;
// import uim.platform.data.privacy.application.usecases.manage.business_subprocesses;
// import uim.platform.data.privacy.application.usecases.manage.correction_requests;
// import uim.platform.data.privacy.application.usecases.manage.archive_requests;
// import uim.platform.data.privacy.application.usecases.manage.destruction_requests;
// import uim.platform.data.privacy.application.usecases.manage.purpose_records;
// import uim.platform.data.privacy.application.usecases.manage.consent_purposes;
// import uim.platform.data.privacy.application.usecases.manage.rule_sets;
// import uim.platform.data.privacy.application.usecases.manage.information_reports;
// import uim.platform.data.privacy.application.usecases.manage.anonymization_configs;

// // Controllers
// import uim.platform.data.privacy.presentation.http.data_subject;
// import uim.platform.data.privacy.presentation.http.personal_data_model;
// import uim.platform.data.privacy.presentation.http.deletion;
// import uim.platform.data.privacy.presentation.http.blocking;
// import uim.platform.data.privacy.presentation.http.legal_ground;
// import uim.platform.data.privacy.presentation.http.retention_rule;
// import uim.platform.data.privacy.presentation.http.consent;
// import uim.platform.data.privacy.presentation.http.data_retrieval;
// import uim.platform.data.privacy.presentation.http.health;
// import uim.platform.data.privacy.presentation.http.data_controller;
// import uim.platform.data.privacy.presentation.http.data_controller_group;
// import uim.platform.data.privacy.presentation.http.business_context;
// import uim.platform.data.privacy.presentation.http.business_process;
// import uim.platform.data.privacy.presentation.http.business_subprocess;
// import uim.platform.data.privacy.presentation.http.correction_request;
// import uim.platform.data.privacy.presentation.http.archive_request;
// import uim.platform.data.privacy.presentation.http.destruction_request;
// import uim.platform.data.privacy.presentation.http.purpose_record;
// import uim.platform.data.privacy.presentation.http.consent_purpose;
// import uim.platform.data.privacy.presentation.http.rule_set;
// import uim.platform.data.privacy.presentation.http.information_report;
// import uim.platform.data.privacy.presentation.http.anonymization_config;
import uim.platform.data.privacy;

mixin(ShowModule!());

@safe:
/// Dependency injection container — wires all layers together.
struct Container {
  // Repositories (driven adapters)
  MemoryDataSubjectRepository dataSubjectRepo;
  MemoryPersonalDataModelRepository personalDataModelRepo;
  MemoryDeletionRequestRepository deletionRequestRepo;
  MemoryBlockingRequestRepository blockingRequestRepo;
  MemoryLegalGroundRepository legalGroundRepo;
  MemoryRetentionRuleRepository retentionRuleRepo;
  MemoryConsentRecordRepository consentRecordRepo;
  MemoryDataRetrievalRequestRepository dataRetrievalRepo;
  MemoryDataControllerRepository dataControllerRepo;
  MemoryDataControllerGroupRepository dataControllerGroupRepo;
  MemoryBusinessContextRepository businessContextRepo;
  MemoryBusinessProcessRepository businessProcessRepo;
  MemoryBusinessSubprocessRepository businessSubprocessRepo;
  MemoryCorrectionRequestRepository correctionRequestRepo;
  MemoryArchiveRequestRepository archiveRequestRepo;
  MemoryDestructionRequestRepository destructionRequestRepo;
  MemoryPurposeRecordRepository purposeRecordRepo;
  MemoryConsentPurposeRepository consentPurposeRepo;
  MemoryRuleSetRepository ruleSetRepo;
  MemoryInformationReportRepository informationReportRepo;
  MemoryAnonymizationConfigRepository anonymizationConfigRepo;

  // Use cases (application layer)
  ManageDataSubjectsUseCase manageDataSubjects;
  ManagePersonalDataModelsUseCase managePersonalDataModels;
  ManageDeletionRequestsUseCase manageDeletionRequests;
  ManageBlockingRequestsUseCase manageBlockingRequests;
  ManageLegalGroundsUseCase manageLegalGrounds;
  ManageRetentionRulesUseCase manageRetentionRules;
  ManageConsentRecordsUseCase manageConsentRecords;
  ManageDataRetrievalsUseCase manageDataRetrievals;
  ManageDataControllersUseCase manageDataControllers;
  ManageDataControllerGroupsUseCase manageDataControllerGroups;
  ManageBusinessContextsUseCase manageBusinessContexts;
  ManageBusinessProcessesUseCase manageBusinessProcesses;
  ManageBusinessSubprocessesUseCase manageBusinessSubprocesses;
  ManageCorrectionRequestsUseCase manageCorrectionRequests;
  ManageArchiveRequestsUseCase manageArchiveRequests;
  ManageDestructionRequestsUseCase manageDestructionRequests;
  ManagePurposeRecordsUseCase managePurposeRecords;
  ManageConsentPurposesUseCase manageConsentPurposes;
  ManageRuleSetsUseCase manageRuleSets;
  ManageInformationReportsUseCase manageInformationReports;
  ManageAnonymizationConfigsUseCase manageAnonymizationConfigs;

  // Controllers (driving adapters)
  DataSubjectController dataSubjectController;
  PersonalDataModelController personalDataModelController;
  DeletionController deletionController;
  BlockingController blockingController;
  LegalGroundController legalGroundController;
  RetentionRuleController retentionRuleController;
  ConsentController consentController;
  DataRetrievalController dataRetrievalController;
  HealthController healthController;
  DataControllerController dataControllerController;
  DataControllerGroupController dataControllerGroupController;
  BusinessContextController businessContextController;
  BusinessProcessController businessProcessController;
  BusinessSubprocessController businessSubprocessController;
  CorrectionRequestController correctionRequestController;
  ArchiveRequestController archiveRequestController;
  DestructionRequestController destructionRequestController;
  PurposeRecordController purposeRecordController;
  ConsentPurposeController consentPurposeController;
  RuleSetController ruleSetController;
  InformationReportController informationReportController;
  AnonymizationConfigController anonymizationConfigController;
}

/// Build the full dependency graph.
Container buildContainer(AppConfig config) {
  Container c;

  // Infrastructure adapters
  c.dataSubjectRepo = new MemoryDataSubjectRepository();
  c.personalDataModelRepo = new MemoryPersonalDataModelRepository();
  c.deletionRequestRepo = new MemoryDeletionRequestRepository();
  c.blockingRequestRepo = new MemoryBlockingRequestRepository();
  c.legalGroundRepo = new MemoryLegalGroundRepository();
  c.retentionRuleRepo = new MemoryRetentionRuleRepository();
  c.consentRecordRepo = new MemoryConsentRecordRepository();
  c.dataRetrievalRepo = new MemoryDataRetrievalRequestRepository();
  c.dataControllerRepo = new MemoryDataControllerRepository();
  c.dataControllerGroupRepo = new MemoryDataControllerGroupRepository();
  c.businessContextRepo = new MemoryBusinessContextRepository();
  c.businessProcessRepo = new MemoryBusinessProcessRepository();
  c.businessSubprocessRepo = new MemoryBusinessSubprocessRepository();
  c.correctionRequestRepo = new MemoryCorrectionRequestRepository();
  c.archiveRequestRepo = new MemoryArchiveRequestRepository();
  c.destructionRequestRepo = new MemoryDestructionRequestRepository();
  c.purposeRecordRepo = new MemoryPurposeRecordRepository();
  c.consentPurposeRepo = new MemoryConsentPurposeRepository();
  c.ruleSetRepo = new MemoryRuleSetRepository();
  c.informationReportRepo = new MemoryInformationReportRepository();
  c.anonymizationConfigRepo = new MemoryAnonymizationConfigRepository();

  // Application use cases
  c.manageDataSubjects = new ManageDataSubjectsUseCase(c.dataSubjectRepo);
  c.managePersonalDataModels = new ManagePersonalDataModelsUseCase(c.personalDataModelRepo);
  c.manageDeletionRequests = new ManageDeletionRequestsUseCase(c.deletionRequestRepo,
      c.dataSubjectRepo);
  c.manageBlockingRequests = new ManageBlockingRequestsUseCase(c.blockingRequestRepo,
      c.dataSubjectRepo);
  c.manageLegalGrounds = new ManageLegalGroundsUseCase(c.legalGroundRepo);
  c.manageRetentionRules = new ManageRetentionRulesUseCase(c.retentionRuleRepo);
  c.manageConsentRecords = new ManageConsentRecordsUseCase(c.consentRecordRepo, c.dataSubjectRepo);
  c.manageDataRetrievals = new ManageDataRetrievalsUseCase(c.dataRetrievalRepo,
      c.dataSubjectRepo, c.personalDataModelRepo);
  c.manageDataControllers = new ManageDataControllersUseCase(c.dataControllerRepo);
  c.manageDataControllerGroups = new ManageDataControllerGroupsUseCase(c.dataControllerGroupRepo);
  c.manageBusinessContexts = new ManageBusinessContextsUseCase(c.businessContextRepo);
  c.manageBusinessProcesses = new ManageBusinessProcessesUseCase(c.businessProcessRepo);
  c.manageBusinessSubprocesses = new ManageBusinessSubprocessesUseCase(c.businessSubprocessRepo);
  c.manageCorrectionRequests = new ManageCorrectionRequestsUseCase(c.correctionRequestRepo,
      c.dataSubjectRepo);
  c.manageArchiveRequests = new ManageArchiveRequestsUseCase(c.archiveRequestRepo,
      c.dataSubjectRepo);
  c.manageDestructionRequests = new ManageDestructionRequestsUseCase(c.destructionRequestRepo,
      c.dataSubjectRepo);
  c.managePurposeRecords = new ManagePurposeRecordsUseCase(c.purposeRecordRepo);
  c.manageConsentPurposes = new ManageConsentPurposesUseCase(c.consentPurposeRepo);
  c.manageRuleSets = new ManageRuleSetsUseCase(c.ruleSetRepo);
  c.manageInformationReports = new ManageInformationReportsUseCase(c.informationReportRepo,
      c.dataSubjectRepo);
  c.manageAnonymizationConfigs = new ManageAnonymizationConfigsUseCase(c.anonymizationConfigRepo);

  // Presentation controllers
  c.dataSubjectController = new DataSubjectController(c.manageDataSubjects);
  c.personalDataModelController = new PersonalDataModelController(c.managePersonalDataModels);
  c.deletionController = new DeletionController(c.manageDeletionRequests);
  c.blockingController = new BlockingController(c.manageBlockingRequests);
  c.legalGroundController = new LegalGroundController(c.manageLegalGrounds);
  c.retentionRuleController = new RetentionRuleController(c.manageRetentionRules);
  c.consentController = new ConsentController(c.manageConsentRecords);
  c.dataRetrievalController = new DataRetrievalController(c.manageDataRetrievals);
  c.healthController = new HealthController("data-privacy");
  c.dataControllerController = new DataControllerController(c.manageDataControllers);
  c.dataControllerGroupController = new DataControllerGroupController(c.manageDataControllerGroups);
  c.businessContextController = new BusinessContextController(c.manageBusinessContexts);
  c.businessProcessController = new BusinessProcessController(c.manageBusinessProcesses);
  c.businessSubprocessController = new BusinessSubprocessController(c.manageBusinessSubprocesses);
  c.correctionRequestController = new CorrectionRequestController(c.manageCorrectionRequests);
  c.archiveRequestController = new ArchiveRequestController(c.manageArchiveRequests);
  c.destructionRequestController = new DestructionRequestController(c.manageDestructionRequests);
  c.purposeRecordController = new PurposeRecordController(c.managePurposeRecords);
  c.consentPurposeController = new ConsentPurposeController(c.manageConsentPurposes);
  c.ruleSetController = new RuleSetController(c.manageRuleSets);
  c.informationReportController = new InformationReportController(c.manageInformationReports);
  c.anonymizationConfigController = new AnonymizationConfigController(c.manageAnonymizationConfigs);

  return c;
}
