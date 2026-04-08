/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.directory.infrastructure.container;

import uim.platform.identity.directory.infrastructure.config;

// Repositories
import uim.platform.identity.directory.infrastructure.persistence.memory.user;
import uim.platform.identity.directory.infrastructure.persistence.memory.group;
import uim.platform.identity.directory.infrastructure.persistence.memory.schema;
import uim.platform.identity.directory.infrastructure.persistence.memory.password_policy;
import uim.platform.identity.directory.infrastructure.persistence.memory.api_client;
import uim.platform.identity.directory.infrastructure.persistence.memory.audit;

// Services
import uim.platform.identity.directory.infrastructure.security.sha256_password_service;

// Use Cases
import uim.platform.identity.directory.application.usecases.manage.users;
import uim.platform.identity.directory.application.usecases.manage.groups;
import uim.platform.identity.directory.application.usecases.manage.schemas;
import uim.platform.identity.directory.application.usecases.manage.password_policies;
import uim.platform.identity.directory.application.usecases.manage.api_clients;
import uim.platform.identity.directory.application.usecases.query_audit_log;

// Controllers
import uim.platform.identity_authentication.presentation.http.user;
import uim.platform.identity_authentication.presentation.http.group;
import uim.platform.identity_authentication.presentation.http.schema;
import uim.platform.identity_authentication.presentation.http.password_policy;
import uim.platform.identity_authentication.presentation.http.api_client;
import uim.platform.identity_authentication.presentation.http.audit;
import uim.platform.identity_authentication.presentation.http.health;

/// Dependency injection container — wires all layers together.
struct Container {
  // Repositories (driven adapters)
  MemoryUserRepository userRepo;
  MemoryGroupRepository groupRepo;
  MemorySchemaRepository schemaRepo;
  MemoryPasswordPolicyRepository passwordPolicyRepo;
  MemoryApiClientRepository apiClientRepo;
  MemoryAuditRepository auditRepo;

  // Security services (driven adapters)
  Sha256PasswordService passwordSvc;

  // Use cases (application layer)
  ManageUsersUseCase manageUsers;
  ManageGroupsUseCase manageGroups;
  ManageSchemasUseCase manageSchemas;
  ManagePasswordPoliciesUseCase managePasswordPolicies;
  ManageApiClientsUseCase manageApiClients;
  QueryAuditLogUseCase queryAuditLog;

  // Controllers (driving adapters)
  UserController userController;
  GroupController groupController;
  SchemaController schemaController;
  PasswordPolicyController passwordPolicyController;
  ApiClientController apiClientController;
  AuditController auditController;
  HealthController healthController;
}

/// Build the full dependency graph.
Container buildContainer(AppConfig config) {
  Container c;

  // Infrastructure adapters
  c.userRepo = new MemoryUserRepository();
  c.groupRepo = new MemoryGroupRepository();
  c.schemaRepo = new MemorySchemaRepository();
  c.passwordPolicyRepo = new MemoryPasswordPolicyRepository();
  c.apiClientRepo = new MemoryApiClientRepository();
  c.auditRepo = new MemoryAuditRepository();

  c.passwordSvc = new Sha256PasswordService();

  // Application use cases
  c.manageUsers = new ManageUsersUseCase(c.userRepo, c.passwordSvc,
      c.passwordPolicyRepo, c.auditRepo);
  c.manageGroups = new ManageGroupsUseCase(c.groupRepo, c.userRepo, c.auditRepo);
  c.manageSchemas = new ManageSchemasUseCase(c.schemaRepo, c.auditRepo);
  c.managePasswordPolicies = new ManagePasswordPoliciesUseCase(c.passwordPolicyRepo, c.auditRepo);
  c.manageApiClients = new ManageApiClientsUseCase(c.apiClientRepo, c.auditRepo);
  c.queryAuditLog = new QueryAuditLogUseCase(c.auditRepo);

  // Presentation controllers
  c.userController = new UserController(c.manageUsers);
  c.groupController = new GroupController(c.manageGroups);
  c.schemaController = new SchemaController(c.manageSchemas);
  c.passwordPolicyController = new PasswordPolicyController(c.managePasswordPolicies);
  c.apiClientController = new ApiClientController(c.manageApiClients);
  c.auditController = new AuditController(c.queryAuditLog);
  c.healthController = new HealthController("identity-directory");

  return c;
}
