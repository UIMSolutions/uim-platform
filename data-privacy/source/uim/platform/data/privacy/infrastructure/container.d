/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.infrastructure.container;

import uim.platform.data.privacy.infrastructure.config;

// Repositories
import uim.platform.data.privacy.infrastructure.persistence.memory.data_subject_repo;
import uim.platform.data.privacy.infrastructure.persistence.memory.personal_data_model_repo;
import uim.platform.data.privacy.infrastructure.persistence.memory.deletion_request_repo;
import uim.platform.data.privacy.infrastructure.persistence.memory.blocking_request_repo;
import uim.platform.data.privacy.infrastructure.persistence.memory.legal_ground_repo;
import uim.platform.data.privacy.infrastructure.persistence.memory.retention_rule_repo;
import uim.platform.data.privacy.infrastructure.persistence.memory.consent_record_repo;
import uim.platform.data.privacy.infrastructure.persistence.memory.data_retrieval_repo;

// Use Cases
import uim.platform.data.privacy.application.usecases.manage.data_subjects;
import uim.platform.data.privacy.application.usecases.manage.personal_data_models;
import uim.platform.data.privacy.application.usecases.manage.deletion_requests;
import uim.platform.data.privacy.application.usecases.manage.blocking_requests;
import uim.platform.data.privacy.application.usecases.manage.legal_grounds;
import uim.platform.data.privacy.application.usecases.manage.retention_rules;
import uim.platform.data.privacy.application.usecases.manage.consent_records;
import uim.platform.data.privacy.application.usecases.manage.data_retrievals;

// Controllers
import uim.platform.data.privacy.presentation.http.data_subject;
import uim.platform.data.privacy.presentation.http.personal_data_model;
import uim.platform.data.privacy.presentation.http.deletion;
import uim.platform.data.privacy.presentation.http.blocking;
import uim.platform.data.privacy.presentation.http.legal_ground;
import uim.platform.data.privacy.presentation.http.retention_rule;
import uim.platform.data.privacy.presentation.http.consent;
import uim.platform.data.privacy.presentation.http.data_retrieval;
import uim.platform.data.privacy.presentation.http.health;

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

  // Use cases (application layer)
  ManageDataSubjectsUseCase manageDataSubjects;
  ManagePersonalDataModelsUseCase managePersonalDataModels;
  ManageDeletionRequestsUseCase manageDeletionRequests;
  ManageBlockingRequestsUseCase manageBlockingRequests;
  ManageLegalGroundsUseCase manageLegalGrounds;
  ManageRetentionRulesUseCase manageRetentionRules;
  ManageConsentRecordsUseCase manageConsentRecords;
  ManageDataRetrievalsUseCase manageDataRetrievals;

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

  return c;
}
