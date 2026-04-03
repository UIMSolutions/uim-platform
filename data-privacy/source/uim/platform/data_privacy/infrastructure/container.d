module uim.platform.xyz.infrastructure.container;

import uim.platform.xyz.infrastructure.config;

// Repositories
import uim.platform.xyz.infrastructure.persistence.memory.data_subject_repo;
import uim.platform.xyz.infrastructure.persistence.memory.personal_data_model_repo;
import uim.platform.xyz.infrastructure.persistence.memory.deletion_request_repo;
import uim.platform.xyz.infrastructure.persistence.memory.blocking_request_repo;
import uim.platform.xyz.infrastructure.persistence.memory.legal_ground_repo;
import uim.platform.xyz.infrastructure.persistence.memory.retention_rule_repo;
import uim.platform.xyz.infrastructure.persistence.memory.consent_record_repo;
import uim.platform.xyz.infrastructure.persistence.memory.data_retrieval_repo;

// Use Cases
import application.usecases.manage_data_subjects;
import application.usecases.manage_personal_data_models;
import application.usecases.manage_deletion_requests;
import application.usecases.manage_blocking_requests;
import application.usecases.manage_legal_grounds;
import application.usecases.manage_retention_rules;
import application.usecases.manage_consent_records;
import application.usecases.manage_data_retrievals;

// Controllers
import uim.platform.xyz.presentation.http.data_subject;
import uim.platform.xyz.presentation.http.personal_data_model;
import uim.platform.xyz.presentation.http.deletion;
import uim.platform.xyz.presentation.http.blocking;
import uim.platform.xyz.presentation.http.legal_ground;
import uim.platform.xyz.presentation.http.retention_rule;
import uim.platform.xyz.presentation.http.consent;
import uim.platform.xyz.presentation.http.data_retrieval;
import uim.platform.xyz.presentation.http.health;

/// Dependency injection container — wires all layers together.
struct Container
{
    // Repositories (driven adapters)
    InMemoryDataSubjectRepository dataSubjectRepo;
    InMemoryPersonalDataModelRepository personalDataModelRepo;
    InMemoryDeletionRequestRepository deletionRequestRepo;
    InMemoryBlockingRequestRepository blockingRequestRepo;
    InMemoryLegalGroundRepository legalGroundRepo;
    InMemoryRetentionRuleRepository retentionRuleRepo;
    InMemoryConsentRecordRepository consentRecordRepo;
    InMemoryDataRetrievalRequestRepository dataRetrievalRepo;

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
Container buildContainer(AppConfig config)
{
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
    c.manageDeletionRequests = new ManageDeletionRequestsUseCase(c.deletionRequestRepo, c.dataSubjectRepo);
    c.manageBlockingRequests = new ManageBlockingRequestsUseCase(c.blockingRequestRepo, c.dataSubjectRepo);
    c.manageLegalGrounds = new ManageLegalGroundsUseCase(c.legalGroundRepo);
    c.manageRetentionRules = new ManageRetentionRulesUseCase(c.retentionRuleRepo);
    c.manageConsentRecords = new ManageConsentRecordsUseCase(c.consentRecordRepo, c.dataSubjectRepo);
    c.manageDataRetrievals = new ManageDataRetrievalsUseCase(c.dataRetrievalRepo, c.dataSubjectRepo, c.personalDataModelRepo);

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
