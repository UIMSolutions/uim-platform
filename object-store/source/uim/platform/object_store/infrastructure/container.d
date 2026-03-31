module uim.platform.object_store.infrastructure.container;

import uim.platform.object_store.infrastructure.config;

// Repositories
import uim.platform.object_store.infrastructure.persistence.in_memory_bucket_repo;
import uim.platform.object_store.infrastructure.persistence.in_memory_storage_object_repo;
import uim.platform.object_store.infrastructure.persistence.in_memory_object_version_repo;
import uim.platform.object_store.infrastructure.persistence.in_memory_access_policy_repo;
import uim.platform.object_store.infrastructure.persistence.in_memory_lifecycle_rule_repo;
import uim.platform.object_store.infrastructure.persistence.in_memory_cors_rule_repo;
import uim.platform.object_store.infrastructure.persistence.in_memory_service_binding_repo;

// Use Cases
import uim.platform.object_store.application.use_cases.manage_buckets;
import uim.platform.object_store.application.use_cases.manage_objects;
import uim.platform.object_store.application.use_cases.manage_access_policies;
import uim.platform.object_store.application.use_cases.manage_lifecycle_rules;
import uim.platform.object_store.application.use_cases.manage_cors_rules;
import uim.platform.object_store.application.use_cases.manage_service_bindings;

// Controllers
import presentation.http.bucket_controller;
import presentation.http.object_controller;
import presentation.http.access_policy_controller;
import presentation.http.lifecycle_rule_controller;
import presentation.http.cors_rule_controller;
import presentation.http.service_binding_controller;
import presentation.http.health_controller;

/// Dependency injection container - wires all layers together.
struct Container
{
    // Repositories (driven adapters)
    InMemoryBucketRepository bucketRepo;
    InMemoryStorageObjectRepository objectRepo;
    InMemoryObjectVersionRepository versionRepo;
    InMemoryAccessPolicyRepository policyRepo;
    InMemoryLifecycleRuleRepository lifecycleRepo;
    InMemoryCorsRuleRepository corsRepo;
    InMemoryServiceBindingRepository bindingRepo;

    // Use cases (application layer)
    ManageBucketsUseCase manageBuckets;
    ManageObjectsUseCase manageObjects;
    ManageAccessPoliciesUseCase manageAccessPolicies;
    ManageLifecycleRulesUseCase manageLifecycleRules;
    ManageCorsRulesUseCase manageCorsRules;
    ManageServiceBindingsUseCase manageServiceBindings;

    // Controllers (driving adapters)
    BucketController bucketController;
    ObjectController objectController;
    AccessPolicyController accessPolicyController;
    LifecycleRuleController lifecycleRuleController;
    CorsRuleController corsRuleController;
    ServiceBindingController serviceBindingController;
    HealthController healthController;
}

/// Build the full dependency graph.
Container buildContainer(AppConfig config)
{
    Container c;

    // Infrastructure adapters
    c.bucketRepo = new InMemoryBucketRepository();
    c.objectRepo = new InMemoryStorageObjectRepository();
    c.versionRepo = new InMemoryObjectVersionRepository();
    c.policyRepo = new InMemoryAccessPolicyRepository();
    c.lifecycleRepo = new InMemoryLifecycleRuleRepository();
    c.corsRepo = new InMemoryCorsRuleRepository();
    c.bindingRepo = new InMemoryServiceBindingRepository();

    // Application use cases
    c.manageBuckets = new ManageBucketsUseCase(c.bucketRepo);
    c.manageObjects = new ManageObjectsUseCase(c.objectRepo, c.bucketRepo, c.versionRepo);
    c.manageAccessPolicies = new ManageAccessPoliciesUseCase(c.policyRepo, c.bucketRepo);
    c.manageLifecycleRules = new ManageLifecycleRulesUseCase(c.lifecycleRepo, c.bucketRepo);
    c.manageCorsRules = new ManageCorsRulesUseCase(c.corsRepo, c.bucketRepo);
    c.manageServiceBindings = new ManageServiceBindingsUseCase(c.bindingRepo, c.bucketRepo);

    // Presentation controllers
    c.bucketController = new BucketController(c.manageBuckets);
    c.objectController = new ObjectController(c.manageObjects);
    c.accessPolicyController = new AccessPolicyController(c.manageAccessPolicies);
    c.lifecycleRuleController = new LifecycleRuleController(c.manageLifecycleRules);
    c.corsRuleController = new CorsRuleController(c.manageCorsRules);
    c.serviceBindingController = new ServiceBindingController(c.manageServiceBindings);
    c.healthController = new HealthController();

    return c;
}
