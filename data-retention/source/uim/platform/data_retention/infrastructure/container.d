module uim.platform.data_retention.infrastructure.container;

import uim.platform.data_retention;

mixin(ShowModule!());

@safe:

struct Container {
    // Repositories (driven adapters)
    MemoryBusinessPurposeRepository businessPurposeRepo;
    MemoryLegalGroundRepository legalGroundRepo;
    MemoryRetentionRuleRepository retentionRuleRepo;
    MemoryResidenceRuleRepository residenceRuleRepo;
    MemoryDataSubjectRepository dataSubjectRepo;
    MemoryDeletionRequestRepository deletionRequestRepo;
    MemoryArchivingJobRepository archivingJobRepo;
    MemoryApplicationGroupRepository applicationGroupRepo;
    MemoryLegalEntityRepository legalEntityRepo;
    MemoryDataSubjectRoleRepository dataSubjectRoleRepo;

    // Use cases (application layer)
    ManageBusinessPurposesUseCase manageBusinessPurposes;
    ManageLegalGroundsUseCase manageLegalGrounds;
    ManageRetentionRulesUseCase manageRetentionRules;
    ManageResidenceRulesUseCase manageResidenceRules;
    ManageDataSubjectsUseCase manageDataSubjects;
    ManageDeletionRequestsUseCase manageDeletionRequests;
    ManageArchivingJobsUseCase manageArchivingJobs;
    ManageApplicationGroupsUseCase manageApplicationGroups;
    ManageLegalEntitiesUseCase manageLegalEntities;
    ManageDataSubjectRolesUseCase manageDataSubjectRoles;

    // Controllers (driving adapters)
    BusinessPurposeController businessPurposeController;
    LegalGroundController legalGroundController;
    RetentionRuleController retentionRuleController;
    ResidenceRuleController residenceRuleController;
    DataSubjectController dataSubjectController;
    DeletionRequestController deletionRequestController;
    ArchivingJobController archivingJobController;
    ApplicationGroupController applicationGroupController;
    LegalEntityController legalEntityController;
    DataSubjectRoleController dataSubjectRoleController;
    HealthController healthController;
}

Container buildContainer(AppConfig config) {
    Container c;

    // Infrastructure adapters
    c.businessPurposeRepo = new MemoryBusinessPurposeRepository();
    c.legalGroundRepo = new MemoryLegalGroundRepository();
    c.retentionRuleRepo = new MemoryRetentionRuleRepository();
    c.residenceRuleRepo = new MemoryResidenceRuleRepository();
    c.dataSubjectRepo = new MemoryDataSubjectRepository();
    c.deletionRequestRepo = new MemoryDeletionRequestRepository();
    c.archivingJobRepo = new MemoryArchivingJobRepository();
    c.applicationGroupRepo = new MemoryApplicationGroupRepository();
    c.legalEntityRepo = new MemoryLegalEntityRepository();
    c.dataSubjectRoleRepo = new MemoryDataSubjectRoleRepository();

    // Application use cases
    c.manageBusinessPurposes = new ManageBusinessPurposesUseCase(c.businessPurposeRepo);
    c.manageLegalGrounds = new ManageLegalGroundsUseCase(c.legalGroundRepo);
    c.manageRetentionRules = new ManageRetentionRulesUseCase(c.retentionRuleRepo);
    c.manageResidenceRules = new ManageResidenceRulesUseCase(c.residenceRuleRepo);
    c.manageDataSubjects = new ManageDataSubjectsUseCase(c.dataSubjectRepo);
    c.manageDeletionRequests = new ManageDeletionRequestsUseCase(c.deletionRequestRepo);
    c.manageArchivingJobs = new ManageArchivingJobsUseCase(c.archivingJobRepo);
    c.manageApplicationGroups = new ManageApplicationGroupsUseCase(c.applicationGroupRepo);
    c.manageLegalEntities = new ManageLegalEntitiesUseCase(c.legalEntityRepo);
    c.manageDataSubjectRoles = new ManageDataSubjectRolesUseCase(c.dataSubjectRoleRepo);

    // Presentation controllers
    c.businessPurposeController = new BusinessPurposeController(c.manageBusinessPurposes);
    c.legalGroundController = new LegalGroundController(c.manageLegalGrounds);
    c.retentionRuleController = new RetentionRuleController(c.manageRetentionRules);
    c.residenceRuleController = new ResidenceRuleController(c.manageResidenceRules);
    c.dataSubjectController = new DataSubjectController(c.manageDataSubjects);
    c.deletionRequestController = new DeletionRequestController(c.manageDeletionRequests);
    c.archivingJobController = new ArchivingJobController(c.manageArchivingJobs);
    c.applicationGroupController = new ApplicationGroupController(c.manageApplicationGroups);
    c.legalEntityController = new LegalEntityController(c.manageLegalEntities);
    c.dataSubjectRoleController = new DataSubjectRoleController(c.manageDataSubjectRoles);
    c.healthController = new HealthController("data-retention");

    return c;
}
