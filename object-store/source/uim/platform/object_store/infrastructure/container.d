/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.object_store.infrastructure.container;

import uim.platform.object_store.infrastructure.config;

// Repositories
import uim.platform.object_store.infrastructure.persistence.memory.bucket;
import uim.platform.object_store.infrastructure.persistence.memory.storage_object;
import uim.platform.object_store.infrastructure.persistence.memory.object_version;
import uim.platform.object_store.infrastructure.persistence.memory.access_policy;
import uim.platform.object_store.infrastructure.persistence.memory.lifecycle_rule;
import uim.platform.object_store.infrastructure.persistence.memory.cors_rule;
import uim.platform.object_store.infrastructure.persistence.memory.service_binding;

// Use Cases
import uim.platform.object_store.application.usecases.manage_buckets;
import uim.platform.object_store.application.usecases.manage_objects;
import uim.platform.object_store.application.usecases.manage_access_policies;
import uim.platform.object_store.application.usecases.manage_lifecycle_rules;
import uim.platform.object_store.application.usecases.manage_cors_rules;
import uim.platform.object_store.application.usecases.manage_service_bindings;

// Controllers
import uim.platform.object_store.presentation.http.controllers.bucket;
import uim.platform.object_store.presentation.http.controllers.object;
import uim.platform.object_store.presentation.http.controllers.access_policy;
import uim.platform.object_store.presentation.http.controllers.lifecycle_rule;
import uim.platform.object_store.presentation.http.controllers.cors_rule;
import uim.platform.object_store.presentation.http.controllers.service_binding;
import uim.platform.object_store.presentation.http.controllers.health;

/// Dependency injection container - wires all layers together.
struct Container
{
  // Repositories (driven adapters)
  MemoryBucketRepository bucketRepo;
  MemoryStorageObjectRepository objectRepo;
  MemoryObjectVersionRepository versionRepo;
  MemoryAccessPolicyRepository policyRepo;
  MemoryLifecycleRuleRepository lifecycleRepo;
  MemoryCorsRuleRepository corsRepo;
  MemoryServiceBindingRepository bindingRepo;

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
  c.bucketRepo = new MemoryBucketRepository();
  c.objectRepo = new MemoryStorageObjectRepository();
  c.versionRepo = new MemoryObjectVersionRepository();
  c.policyRepo = new MemoryAccessPolicyRepository();
  c.lifecycleRepo = new MemoryLifecycleRuleRepository();
  c.corsRepo = new MemoryCorsRuleRepository();
  c.bindingRepo = new MemoryServiceBindingRepository();

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
  c.healthController = new HealthController("object-store");

  return c;
}
