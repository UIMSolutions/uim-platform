module uim.platform.xyz.infrastructure.container;

import uim.platform.xyz.infrastructure.config;

// Repositories
import uim.platform.xyz.infrastructure.persistence.memory.validation_rule_repo;
import uim.platform.xyz.infrastructure.persistence.memory.validation_result_repo;
import uim.platform.xyz.infrastructure.persistence.memory.address_repo;
import uim.platform.xyz.infrastructure.persistence.memory.match_group_repo;
import uim.platform.xyz.infrastructure.persistence.memory.data_profile_repo;
import uim.platform.xyz.infrastructure.persistence.memory.cleansing_rule_repo;
import uim.platform.xyz.infrastructure.persistence.memory.cleansing_job_repo;

// Domain services
import domain.services.validation_engine;
import domain.services.address_cleanser;
import domain.services.duplicate_detector;
import domain.services.quality_scorer;

// Use cases
import application.usecases.manage_validation_rules;
import application.usecases.validate_data;
import application.usecases.cleanse_addresses;
import application.usecases.detect_duplicates;
import application.usecases.profile_data;
import application.usecases.manage_cleansing_rules;
import application.usecases.manage_cleansing_jobs;
import application.usecases.compute_dashboard;

// Controllers
import uim.platform.xyz.presentation.http.validation_rule;
import uim.platform.xyz.presentation.http.validate;
import uim.platform.xyz.presentation.http.address;
import uim.platform.xyz.presentation.http.duplicate;
import uim.platform.xyz.presentation.http.profile;
import uim.platform.xyz.presentation.http.cleansing_rule;
import uim.platform.xyz.presentation.http.cleansing_job;
import uim.platform.xyz.presentation.http.dashboard;
import uim.platform.xyz.presentation.http.health;

/// Dependency injection container - wires all layers together.
struct Container {
    // Repositories (driven adapters)
    InMemoryValidationRuleRepository validationRuleRepo;
    InMemoryValidationResultRepository validationResultRepo;
    InMemoryAddressRepository addressRepo;
    InMemoryMatchGroupRepository matchGroupRepo;
    InMemoryDataProfileRepository dataProfileRepo;
    InMemoryCleansingRuleRepository cleansingRuleRepo;
    InMemoryCleansingJobRepository cleansingJobRepo;

    // Domain services
    ValidationEngine validationEngine;
    AddressCleanser addressCleanser;
    DuplicateDetector duplicateDetector;
    QualityScorer qualityScorer;

    // Use cases (application layer)
    ManageValidationRulesUseCase manageValidationRules;
    ValidateDataUseCase validateData;
    CleanseAddressesUseCase cleanseAddresses;
    DetectDuplicatesUseCase detectDuplicates;
    ProfileDataUseCase profileData;
    ManageCleansingRulesUseCase manageCleansingRules;
    ManageCleansingJobsUseCase manageCleansingJobs;
    ComputeDashboardUseCase computeDashboard;

    // Controllers (driving adapters)
    ValidationRuleController validationRuleController;
    ValidateController validateController;
    AddressController addressController;
    DuplicateController duplicateController;
    ProfileController profileController;
    CleansingRuleController cleansingRuleController;
    CleansingJobController cleansingJobController;
    DashboardController dashboardController;
    HealthController healthController;
}

/// Build the full dependency graph.
Container buildContainer(AppConfig config) {
    Container c;

    // Infrastructure adapters
    c.validationRuleRepo = new MemoryValidationRuleRepository();
    c.validationResultRepo = new MemoryValidationResultRepository();
    c.addressRepo = new MemoryAddressRepository();
    c.matchGroupRepo = new MemoryMatchGroupRepository();
    c.dataProfileRepo = new MemoryDataProfileRepository();
    c.cleansingRuleRepo = new MemoryCleansingRuleRepository();
    c.cleansingJobRepo = new MemoryCleansingJobRepository();

    // Domain services
    c.validationEngine = new ValidationEngine();
    c.addressCleanser = new AddressCleanser();
    c.duplicateDetector = new DuplicateDetector();
    c.qualityScorer = new QualityScorer();

    // Application use cases
    c.manageValidationRules = new ManageValidationRulesUseCase(c.validationRuleRepo);
    c.validateData = new ValidateDataUseCase(
        c.validationRuleRepo, c.validationResultRepo, c.validationEngine);
    c.cleanseAddresses = new CleanseAddressesUseCase(c.addressRepo, c.addressCleanser);
    c.detectDuplicates = new DetectDuplicatesUseCase(c.matchGroupRepo, c.duplicateDetector);
    c.profileData = new ProfileDataUseCase(c.dataProfileRepo);
    c.manageCleansingRules = new ManageCleansingRulesUseCase(c.cleansingRuleRepo);
    c.manageCleansingJobs = new ManageCleansingJobsUseCase(c.cleansingJobRepo);
    c.computeDashboard = new ComputeDashboardUseCase(
        c.validationResultRepo, c.dataProfileRepo, c.qualityScorer);

    // Presentation controllers
    c.validationRuleController = new ValidationRuleController(c.manageValidationRules);
    c.validateController = new ValidateController(c.validateData);
    c.addressController = new AddressController(c.cleanseAddresses);
    c.duplicateController = new DuplicateController(c.detectDuplicates);
    c.profileController = new ProfileController(c.profileData);
    c.cleansingRuleController = new CleansingRuleController(c.manageCleansingRules);
    c.cleansingJobController = new CleansingJobController(c.manageCleansingJobs);
    c.dashboardController = new DashboardController(c.computeDashboard);
    c.healthController = new HealthController("data-quality");

    return c;
}
