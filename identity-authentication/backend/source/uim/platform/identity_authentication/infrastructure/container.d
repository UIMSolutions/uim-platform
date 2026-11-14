/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_authentication.infrastructure.container;

import uim.platform.identity_authentication;

mixin(ShowModule!());

@safe:

/// Dependency injection container — wires domain, application, persistence
/// and security adapters. Presentation adapters (HTTP, REST, OData, CLI, GUI)
/// are created by the entry points (app.d, cli.d, gui.d) on top of this
/// container and only see the driving ports (IdentityPorts).
class Container {
  IdentityConfig config;

  // ── Driven adapters ───────────────────────────────────────────────────
  ISnapshotStorage storage; // null in "memory" mode
  UserRepository userRepo;
  GroupRepository groupRepo;
  ApplicationRepository applicationRepo;
  PolicyRepository policyRepo;
  RiskRuleRepository riskRuleRepo;
  IdpConfigRepository idpConfigRepo;
  SessionRepository sessionRepo;
  TokenRepository tokenRepo;

  IPasswordService passwords;
  ISecretService secrets;
  ITokenService tokenSigner;
  IMfaService mfa;
  IOtpSender otpSender;
  IIdentityEventPublisher publisher;

  // ── Driving ports ─────────────────────────────────────────────────────
  IAuthenticationUseCase authentication;
  ITokenUseCase tokens;
  IManageSessionsUseCase sessions;
  IManageUsersUseCase users;
  IManageGroupsUseCase groups;
  IManageApplicationsUseCase applications;
  IManagePoliciesUseCase policies;
  IManageRiskRulesUseCase riskRules;
  IManageIdentityProvidersUseCase identityProviders;
  IIdentityStatisticsService statistics;

  this(IdentityConfig config) {
    this.config = config;
    wirePersistence();
    wireSecurity();
    wireApplication();
  }

  /// The driving ports for presentation adapters.
  IdentityPorts ports() {
    IdentityPorts p;
    p.authentication = authentication;
    p.tokens = tokens;
    p.sessions = sessions;
    p.users = users;
    p.groups = groups;
    p.applications = applications;
    p.policies = policies;
    p.riskRules = riskRules;
    p.identityProviders = identityProviders;
    p.statistics = statistics;
    return p;
  }

  protected void wirePersistence() {
    if (!config.usesFileStorage) {
      userRepo = new UserRepository();
      groupRepo = new GroupRepository();
      applicationRepo = new ApplicationRepository();
      policyRepo = new PolicyRepository();
      riskRuleRepo = new RiskRuleRepository();
      idpConfigRepo = new IdpConfigRepository();
      sessionRepo = new SessionRepository();
      tokenRepo = new TokenRepository();
      return;
    }

    storage = new JsonFileSnapshotStorage(config.dataDir);
    auto store(TEntity, TId, TMapper)(IdentityCollections collection) {
      return new SnapshotTenantStore!(TEntity, TId, TMapper)(storage, collection);
    }

    userRepo = new UserRepository(store!(IAUser, UserId, UserMapper)(IdentityCollections.users));
    groupRepo = new GroupRepository(store!(IAGroup, GroupId, GroupMapper)(IdentityCollections.groups));
    applicationRepo = new ApplicationRepository(
      store!(Application, ApplicationId, ApplicationMapper)(IdentityCollections.applications));
    policyRepo = new PolicyRepository(
      store!(AuthorizationPolicy, PolicyId, PolicyMapper)(IdentityCollections.policies));
    riskRuleRepo = new RiskRuleRepository(store!(RiskRule, RiskRuleId, RiskRuleMapper)(IdentityCollections.riskRules));
    idpConfigRepo = new IdpConfigRepository(
      store!(IdpConfig, IdpConfigId, IdpConfigMapper)(IdentityCollections.identityProviders));
    sessionRepo = new SessionRepository(store!(IASession, SessionId, SessionMapper)(IdentityCollections.sessions));
    tokenRepo = new TokenRepository(store!(Token, TokenId, TokenMapper)(IdentityCollections.tokens));
  }

  protected void wireSecurity() {
    if (config.isInsecure)
      logWarn("identity-authentication: the token signing secret is the built-in default — set IAS_JWT_SECRET (≥ 16 characters)");
    passwords = new Pbkdf2PasswordService(cast(uint) max(config.passwordIterations, 1));
    secrets = new Sha256SecretService();
    tokenSigner = new JwtTokenService(config.jwtSecret);
    otpSender = config.otpWebhookUrl.length
      ? cast(IOtpSender) new WebhookOtpSender(config.otpWebhookUrl)
      : cast(IOtpSender) new LogOtpSender();
    mfa = new TotpMfaService(otpSender);
    publisher = new LogEventPublisher();
  }

  protected void wireApplication() {
    auto settings = config.settings;
    authentication = new AuthenticateUserUseCase(userRepo, groupRepo, sessionRepo, tokenRepo, riskRuleRepo,
      passwords, mfa, publisher, settings);
    tokens = new IssueTokenUseCase(userRepo, groupRepo, applicationRepo, tokenRepo, sessionRepo, policyRepo,
      tokenSigner, secrets, publisher, settings);
    sessions = new ManageSessionsUseCase(sessionRepo, tokenRepo, publisher);
    users = new ManageUsersUseCase(userRepo, passwords, mfa, groupRepo, sessionRepo, tokenRepo, publisher, settings);
    groups = new ManageGroupsUseCase(groupRepo, userRepo);
    applications = new ManageApplicationsUseCase(applicationRepo, secrets, policyRepo, publisher);
    policies = new ManagePoliciesUseCase(policyRepo, userRepo, groupRepo);
    riskRules = new ManageRiskRulesUseCase(riskRuleRepo, userRepo, groupRepo);
    identityProviders = new DelegatedAuthUseCase(idpConfigRepo);
    statistics = new IdentityStatisticsService(userRepo, groupRepo, applicationRepo, policyRepo, riskRuleRepo,
      idpConfigRepo, sessionRepo, tokenRepo);
  }
}

/// Build the full dependency graph.
Container buildContainer(IdentityConfig config) {
  return new Container(config);
}

/// Configuration for tests: memory storage, fast hashing.
IdentityConfig testConfig() {
  IdentityConfig cfg;
  cfg.storage = "memory";
  cfg.passwordIterations = 500;
  cfg.jwtSecret = "unit-test-secret-0123456789";
  cfg.maxFailedLogins = 3;
  return cfg;
}

///
unittest {
  mixin(ShowTest!("Container — end-to-end authentication flow"));

  auto c = buildContainer(testConfig());
  assert(c.storage is null);
  auto p = c.ports;
  auto t = TenantId("acme");

  // ── directory setup ────────────────────────────────────────────────
  UserDTO user;
  user.tenantId = t;
  user.email = "jane@acme.test";
  user.firstName = "Jane";
  user.lastName = "Doe";
  user.password = "Secret123";
  auto created = p.users.createUser(user);
  assert(created.isSuccess, created.message);
  auto userId = UserId(created.id);

  GroupDTO admins;
  admins.tenantId = t;
  admins.name = "admins";
  auto groupId = GroupId(p.groups.createGroup(admins).id);
  assert(p.groups.addMember(t, groupId, userId).isSuccess);

  ApplicationDTO app;
  app.tenantId = t;
  app.name = "Portal";
  app.allowedScopes = ["openid", "profile", "admin"];
  auto registered = p.applications.createApplication(app);
  auto clientId = registered.data["clientId"].get!string;
  auto clientSecret = registered.data["clientSecret"].get!string;

  PolicyDTO policy;
  policy.tenantId = t;
  policy.name = "Admins only";
  policy.rules = [PolicyRule("group", "in", "admins")];
  assert(p.policies.createPolicy(policy).isSuccess);

  // ── login ──────────────────────────────────────────────────────────
  AuthRequest login = {tenantId: t, email: "JANE@acme.test", password: "Secret123", ipAddress: "10.0.0.1"};
  auto auth = p.authentication.login(login);
  assert(auth.success, auth.message);
  assert(auth.userId == userId);

  // ── tokens ─────────────────────────────────────────────────────────
  TokenRequest tr = {tenantId: t, sessionId: SessionId(auth.sessionId), clientId: clientId,
    clientSecret: clientSecret, scopes: ["openid", "profile"]};
  auto issued = p.tokens.issueTokens(tr);
  assert(issued.isSuccess, issued.errorDescription);
  assert(issued.idToken.length > 0);

  auto info = p.tokens.introspect(t, issued.accessToken);
  assert(info.active && info.subject == userId.value && info.scopes == ["openid", "profile"]);
  assert(!p.tokens.introspect(TenantId("other"), issued.accessToken).active);
  assert(p.tokens.userInfo(t, issued.accessToken)["groups"][0].get!string == "admins");

  tr.clientSecret = "wrong";
  assert(p.tokens.issueTokens(tr).error == "invalid_client");
  tr.clientSecret = clientSecret;
  tr.scopes = ["payroll"];
  assert(p.tokens.issueTokens(tr).error == "invalid_scope");
  tr.scopes = ["openid"];

  // ── refresh with rotation and reuse detection ─────────────────────
  RefreshRequest rr = {tenantId: t, refreshToken: issued.refreshToken, clientId: clientId, clientSecret: clientSecret};
  auto refreshed = p.tokens.refreshTokens(rr);
  assert(refreshed.isSuccess, refreshed.errorDescription);
  assert(refreshed.accessToken != issued.accessToken);
  assert(p.tokens.refreshTokens(rr).error == "invalid_grant"); // old refresh token reused
  assert(p.sessions.getSession(t, SessionId(auth.sessionId)).revoked); // → session killed
  assert(!p.tokens.introspect(t, refreshed.accessToken).active);

  // ── policy denies non-members ─────────────────────────────────────
  assert(p.groups.removeMember(t, groupId, userId).isSuccess);
  auto second = p.authentication.login(login);
  assert(second.success);
  tr.sessionId = SessionId(second.sessionId);
  assert(p.tokens.issueTokens(tr).error == "access_denied");
  assert(p.groups.addMember(t, groupId, userId).isSuccess);
  auto again = p.tokens.issueTokens(tr);
  assert(again.isSuccess);

  // ── logout revokes the session's tokens ───────────────────────────
  assert(p.authentication.logout(t, SessionId(second.sessionId)).isSuccess);
  assert(!p.tokens.introspect(t, again.accessToken).active);
  assert(p.tokens.issueTokens(tr).error == "invalid_grant");

  // ── MFA ────────────────────────────────────────────────────────────
  auto enrolled = p.users.enrollMfa(t, userId, MfaType.totp, UserId("admin"));
  assert(enrolled.isSuccess);
  auto mfaStep = p.authentication.login(login);
  assert(!mfaStep.success && mfaStep.mfaRequired && mfaStep.mfaType == MfaType.totp);
  login.mfaCode = c.mfa.currentCode(MfaType.totp, enrolled.data["secret"].get!string, Clock.currStdTime());
  assert(p.authentication.login(login).success);
  login.mfaCode = "";
  assert(p.users.disableMfa(t, userId, UserId("admin")).isSuccess);

  // ── risk rule denies ──────────────────────────────────────────────
  RiskRuleDTO block;
  block.tenantId = t;
  block.name = "block guest network";
  block.conditions = [RiskCondition("ip_range", "in", "192.168.66.0/24")];
  block.riskLevel = "critical";
  block.denyAccess = true;
  assert(p.riskRules.createRiskRule(block).isSuccess);
  login.ipAddress = "192.168.66.10";
  assert(p.authentication.login(login).code == 403);
  login.ipAddress = "10.0.0.1";

  // ── lockout after maxFailedLogins (3) ─────────────────────────────
  login.password = "wrong-password";
  assert(p.authentication.login(login).code == 401);
  assert(p.authentication.login(login).code == 401);
  assert(p.authentication.login(login).code == 423);
  login.password = "Secret123";
  assert(p.authentication.login(login).code == 423); // locked even with the right password
  assert(p.users.setUserStatus(t, userId, UserStatus.active, UserId("admin")).isSuccess);
  assert(p.authentication.login(login).success);

  // ── unknown user ──────────────────────────────────────────────────
  login.email = "nobody@acme.test";
  assert(p.authentication.login(login).code == 401);

  auto stats = p.statistics.statistics(t);
  assert(stats.users == 1 && stats.groups == 1 && stats.applications == 1 && stats.riskRules == 1);
  assert(stats.activeSessions >= 1 && stats.tokens > 0);
}
