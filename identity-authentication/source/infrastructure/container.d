module infrastructure.container;

import infrastructure.config;

// Repositories
import infrastructure.persistence.in_memory_user_repo;
import infrastructure.persistence.in_memory_group_repo;
import infrastructure.persistence.in_memory_tenant_repo;
import infrastructure.persistence.in_memory_app_repo;
import infrastructure.persistence.in_memory_session_repo;
import infrastructure.persistence.in_memory_token_repo;
import infrastructure.persistence.in_memory_policy_repo;
import infrastructure.persistence.in_memory_idp_config_repo;
import infrastructure.persistence.in_memory_risk_rule_repo;

// Services
import infrastructure.security.bcrypt_password_service;
import infrastructure.security.jwt_token_service;
import infrastructure.security.totp_mfa_service;

// Use Cases
import application.use_cases.authenticate_user;
import application.use_cases.issue_token;
import application.use_cases.manage_users;
import application.use_cases.manage_groups;
import application.use_cases.manage_applications;
import application.use_cases.manage_tenants;
import application.use_cases.manage_policies;
import application.use_cases.delegated_auth;

// Controllers
import presentation.http.auth_controller;
import presentation.http.user_controller;
import presentation.http.group_controller;
import presentation.http.application_controller;
import presentation.http.tenant_controller;
import presentation.http.policy_controller;

/// Dependency injection container — wires all layers together.
struct Container
{
    // Repositories (driven adapters)
    InMemoryUserRepository userRepo;
    InMemoryGroupRepository groupRepo;
    InMemoryTenantRepository tenantRepo;
    InMemoryApplicationRepository appRepo;
    InMemorySessionRepository sessionRepo;
    InMemoryTokenRepository tokenRepo;
    InMemoryPolicyRepository policyRepo;
    InMemoryIdpConfigRepository idpConfigRepo;
    InMemoryRiskRuleRepository riskRuleRepo;

    // Security services (driven adapters)
    Sha256PasswordService passwordSvc;
    JwtTokenService tokenSvc;
    TotpMfaService mfaSvc;

    // Use cases (application layer)
    AuthenticateUserUseCase authenticateUser;
    IssueTokenUseCase issueToken;
    ManageUsersUseCase manageUsers;
    ManageGroupsUseCase manageGroups;
    ManageApplicationsUseCase manageApplications;
    ManageTenantsUseCase manageTenants;
    ManagePoliciesUseCase managePolicies;
    DelegatedAuthUseCase delegatedAuth;

    // Controllers (driving adapters)
    AuthController authController;
    UserController userController;
    GroupController groupController;
    ApplicationController applicationController;
    TenantController tenantController;
    PolicyController policyController;
}

/// Build the full dependency graph.
Container buildContainer(AppConfig config)
{
    Container c;

    // Infrastructure adapters
    c.userRepo = new InMemoryUserRepository();
    c.groupRepo = new InMemoryGroupRepository();
    c.tenantRepo = new InMemoryTenantRepository();
    c.appRepo = new InMemoryApplicationRepository();
    c.sessionRepo = new InMemorySessionRepository();
    c.tokenRepo = new InMemoryTokenRepository();
    c.policyRepo = new InMemoryPolicyRepository();
    c.idpConfigRepo = new InMemoryIdpConfigRepository();
    c.riskRuleRepo = new InMemoryRiskRuleRepository();

    c.passwordSvc = new Sha256PasswordService();
    c.tokenSvc = new JwtTokenService(config.jwtSecret);
    c.mfaSvc = new TotpMfaService();

    // Application use cases
    c.authenticateUser = new AuthenticateUserUseCase(
        c.userRepo, c.passwordSvc, c.sessionRepo, c.riskRuleRepo, c.mfaSvc
    );
    c.issueToken = new IssueTokenUseCase(
        c.userRepo, c.appRepo, c.tokenRepo, c.sessionRepo, c.tokenSvc
    );
    c.manageUsers = new ManageUsersUseCase(c.userRepo, c.passwordSvc);
    c.manageGroups = new ManageGroupsUseCase(c.groupRepo, c.userRepo);
    c.manageApplications = new ManageApplicationsUseCase(c.appRepo);
    c.manageTenants = new ManageTenantsUseCase(c.tenantRepo);
    c.managePolicies = new ManagePoliciesUseCase(c.policyRepo);
    c.delegatedAuth = new DelegatedAuthUseCase(c.idpConfigRepo, c.userRepo);

    // Presentation controllers
    c.authController = new AuthController(c.authenticateUser, c.issueToken);
    c.userController = new UserController(c.manageUsers);
    c.groupController = new GroupController(c.manageGroups);
    c.applicationController = new ApplicationController(c.manageApplications);
    c.tenantController = new TenantController(c.manageTenants);
    c.policyController = new PolicyController(c.managePolicies);

    return c;
}
