module uim.platform.identity_authentication.infrastructure.container;

import uim.platform.identity_authentication.infrastructure.config;

// Repositories
import uim.platform.identity_authentication.infrastructure.persistence.in_memory_user;
import uim.platform.identity_authentication.infrastructure.persistence.in_memory_group;
import uim.platform.identity_authentication.infrastructure.persistence.in_memory_tenant;
import uim.platform.identity_authentication.infrastructure.persistence.in_memory_app;
import uim.platform.identity_authentication.infrastructure.persistence.in_memory_session;
import uim.platform.identity_authentication.infrastructure.persistence.in_memory_token;
import uim.platform.identity_authentication.infrastructure.persistence.in_memory_policy;
import uim.platform.identity_authentication.infrastructure.persistence.in_memory_idp_config;
import uim.platform.identity_authentication.infrastructure.persistence.in_memory_risk_rule;

// Services
import uim.platform.identity_authentication.infrastructure.security.bcrypt_password_service;
import uim.platform.identity_authentication.infrastructure.security.jwt_token_service;
import uim.platform.identity_authentication.infrastructure.security.totp_mfa_service;

// Use Cases
import uim.platform.identity_authentication.application.usecases.authenticate_user;
import uim.platform.identity_authentication.application.usecases.issue_token;
import uim.platform.identity_authentication.application.usecases.manage_users;
import uim.platform.identity_authentication.application.usecases.manage_groups;
import uim.platform.identity_authentication.application.usecases.manage_applications;
import uim.platform.identity_authentication.application.usecases.manage_tenants;
import uim.platform.identity_authentication.application.usecases.manage_policies;
import uim.platform.identity_authentication.application.usecases.delegated_auth;

// Controllers
import uim.platform.identity_authentication.presentation.http.controllers.auth;
import uim.platform.identity_authentication.presentation.http.controllers.user;
import uim.platform.identity_authentication.presentation.http.controllers.group;
import uim.platform.identity_authentication.presentation.http.controllers.application;
import uim.platform.identity_authentication.presentation.http.controllers.tenant;
import uim.platform.identity_authentication.presentation.http.controllers.policy;

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
