module infrastructure.container;

import infrastructure.config;

// Repositories
import infrastructure.persistence.in_memory_user_repo;
import infrastructure.persistence.in_memory_group_repo;
import infrastructure.persistence.in_memory_schema_repo;
import infrastructure.persistence.in_memory_password_policy_repo;
import infrastructure.persistence.in_memory_api_client_repo;
import infrastructure.persistence.in_memory_audit_repo;

// Services
import infrastructure.security.sha256_password_service;

// Use Cases
import application.usecases.manage_users;
import application.usecases.manage_groups;
import application.usecases.manage_schemas;
import application.usecases.manage_password_policies;
import application.usecases.manage_api_clients;
import application.usecases.query_audit_log;

// Controllers
import uim.platform.identity_authentication.presentation.http.user;
import uim.platform.identity_authentication.presentation.http.group;
import uim.platform.identity_authentication.presentation.http.schema;
import uim.platform.identity_authentication.presentation.http.password_policy;
import uim.platform.identity_authentication.presentation.http.api_client;
import uim.platform.identity_authentication.presentation.http.audit;
import uim.platform.identity_authentication.presentation.http.health;

/// Dependency injection container — wires all layers together.
struct Container
{
    // Repositories (driven adapters)
    InMemoryUserRepository userRepo;
    InMemoryGroupRepository groupRepo;
    InMemorySchemaRepository schemaRepo;
    InMemoryPasswordPolicyRepository passwordPolicyRepo;
    InMemoryApiClientRepository apiClientRepo;
    InMemoryAuditRepository auditRepo;

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
Container buildContainer(AppConfig config)
{
    Container c;

    // Infrastructure adapters
    c.userRepo = new InMemoryUserRepository();
    c.groupRepo = new InMemoryGroupRepository();
    c.schemaRepo = new InMemorySchemaRepository();
    c.passwordPolicyRepo = new InMemoryPasswordPolicyRepository();
    c.apiClientRepo = new InMemoryApiClientRepository();
    c.auditRepo = new InMemoryAuditRepository();

    c.passwordSvc = new Sha256PasswordService();

    // Application use cases
    c.manageUsers = new ManageUsersUseCase(
        c.userRepo, c.passwordSvc, c.passwordPolicyRepo, c.auditRepo
    );
    c.manageGroups = new ManageGroupsUseCase(
        c.groupRepo, c.userRepo, c.auditRepo
    );
    c.manageSchemas = new ManageSchemasUseCase(
        c.schemaRepo, c.auditRepo
    );
    c.managePasswordPolicies = new ManagePasswordPoliciesUseCase(
        c.passwordPolicyRepo, c.auditRepo
    );
    c.manageApiClients = new ManageApiClientsUseCase(
        c.apiClientRepo, c.auditRepo
    );
    c.queryAuditLog = new QueryAuditLogUseCase(c.auditRepo);

    // Presentation controllers
    c.userController = new UserController(c.manageUsers);
    c.groupController = new GroupController(c.manageGroups);
    c.schemaController = new SchemaController(c.manageSchemas);
    c.passwordPolicyController = new PasswordPolicyController(c.managePasswordPolicies);
    c.apiClientController = new ApiClientController(c.manageApiClients);
    c.auditController = new AuditController(c.queryAuditLog);
    c.healthController = new HealthController();

    return c;
}
