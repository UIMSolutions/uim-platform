/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_authentication.infrastructure.container;

// import uim.platform.identity_authentication.infrastructure.config;
// 
// // Repositories
// import uim.platform.identity_authentication.infrastructure.persistence.memory.user;
// import uim.platform.identity_authentication.infrastructure.persistence.memory.group;
// import uim.platform.identity_authentication.infrastructure.persistence.memory.tenant;
// import uim.platform.identity_authentication.infrastructure.persistence.memory.app;
// import uim.platform.identity_authentication.infrastructure.persistence.memory.session;
// import uim.platform.identity_authentication.infrastructure.persistence.memory.token;
// import uim.platform.identity_authentication.infrastructure.persistence.memory.policy;
// import uim.platform.identity_authentication.infrastructure.persistence.memory.idp_config;
// import uim.platform.identity_authentication.infrastructure.persistence.memory.risk_rule;
// 
// // Services
// import uim.platform.identity_authentication.infrastructure.security.bcrypt_password_service;
// import uim.platform.identity_authentication.infrastructure.security.jwt_token_service;
// import uim.platform.identity_authentication.infrastructure.security.totp_mfa_service;
// 
// // Use Cases
// import uim.platform.identity_authentication.application.usecases.authenticate_user;
// import uim.platform.identity_authentication.application.usecases.issue_token;
// import uim.platform.identity_authentication.application.usecases.manage.users;
// import uim.platform.identity_authentication.application.usecases.manage.groups;
// import uim.platform.identity_authentication.application.usecases.manage.applications;
// import uim.platform.identity_authentication.application.usecases.manage.tenants;
// import uim.platform.identity_authentication.application.usecases.manage.policies;
// import uim.platform.identity_authentication.application.usecases.delegated_auth;
// 
// // Controllers
// import uim.platform.identity_authentication.presentation.http.controllers.auth;
// import uim.platform.identity_authentication.presentation.http.controllers.user;
// import uim.platform.identity_authentication.presentation.http.controllers.group;
// import uim.platform.identity_authentication.presentation.http.controllers.application;
// import uim.platform.identity_authentication.presentation.http.controllers.tenant;
// import uim.platform.identity_authentication.presentation.http.controllers.policy;

import uim.platform.identity_authentication;

mixin(ShowModule!());
@safe:

/// Dependency injection container — wires all layers together.
struct Container
{
  // Repositories (driven adapters)
  MemoryUserRepository userRepo;
  MemoryGroupRepository groupRepo;
  MemoryTenantRepository tenantRepo;
  MemoryApplicationRepository appRepo;
  MemorySessionRepository sessionRepo;
  MemoryTokenRepository tokenRepo;
  MemoryPolicyRepository policyRepo;
  MemoryIdpConfigRepository idpConfigRepo;
  MemoryRiskRuleRepository riskRuleRepo;

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
  c.userRepo = new MemoryUserRepository();
  c.groupRepo = new MemoryGroupRepository();
  c.tenantRepo = new MemoryTenantRepository();
  c.appRepo = new MemoryApplicationRepository();
  c.sessionRepo = new MemorySessionRepository();
  c.tokenRepo = new MemoryTokenRepository();
  c.policyRepo = new MemoryPolicyRepository();
  c.idpConfigRepo = new MemoryIdpConfigRepository();
  c.riskRuleRepo = new MemoryRiskRuleRepository();

  c.passwordSvc = new Sha256PasswordService();
  c.tokenSvc = new JwtTokenService(config.jwtSecret);
  c.mfaSvc = new TotpMfaService();

  // Application use cases
  c.authenticateUser = new AuthenticateUserUseCase(c.userRepo, c.passwordSvc,
      c.sessionRepo, c.riskRuleRepo, c.mfaSvc);
  c.issueToken = new IssueTokenUseCase(c.userRepo, c.appRepo, c.tokenRepo,
      c.sessionRepo, c.tokenSvc);
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
