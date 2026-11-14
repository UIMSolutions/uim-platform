/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_authentication.application.services.statistics;

import uim.platform.identity_authentication;

mixin(ShowModule!());

@safe:

/// Application service computing the tenant figures from all repositories
/// (one pass per collection).
class IdentityStatisticsService : IIdentityStatisticsService {
  protected IUserRepository users;
  protected IGroupRepository groups;
  protected IApplicationRepository applications;
  protected IPolicyRepository policies;
  protected IRiskRuleRepository riskRules;
  protected IIdpConfigRepository idps;
  protected ISessionRepository sessions;
  protected ITokenRepository tokens;

  this(IUserRepository users, IGroupRepository groups, IApplicationRepository applications,
      IPolicyRepository policies, IRiskRuleRepository riskRules, IIdpConfigRepository idps,
      ISessionRepository sessions, ITokenRepository tokens) {
    this.users = users;
    this.groups = groups;
    this.applications = applications;
    this.policies = policies;
    this.riskRules = riskRules;
    this.idps = idps;
    this.sessions = sessions;
    this.tokens = tokens;
  }

  IdentityStatistics statistics(TenantId tenantId) {
    IdentityStatistics s;
    s.tenantId = tenantId;
    auto now = nowStdTime();

    foreach (u; users.findByTenant(tenantId)) {
      s.users++;
      final switch (u.status) {
      case UserStatus.active:
        s.activeUsers++;
        break;
      case UserStatus.locked:
        s.lockedUsers++;
        break;
      case UserStatus.inactive:
        s.inactiveUsers++;
        break;
      case UserStatus.pendingVerification:
        s.pendingUsers++;
        break;
      }
      if (u.hasMfa)
        s.mfaUsers++;
      if (u.failedLoginAttempts > 0)
        s.usersWithFailedLogins++;
      s.lastLoginAt = max(s.lastLoginAt, u.lastLoginAt);
    }
    s.groups = groups.countByTenant(tenantId);
    foreach (a; applications.findByTenant(tenantId)) {
      s.applications++;
      if (a.active)
        s.activeApplications++;
    }
    s.policies = policies.countByTenant(tenantId);
    s.riskRules = riskRules.countByTenant(tenantId);
    s.identityProviders = idps.countByTenant(tenantId);
    foreach (x; sessions.findByTenant(tenantId)) {
      s.sessions++;
      if (x.isActive(now))
        s.activeSessions++;
    }
    foreach (t; tokens.findByTenant(tenantId)) {
      s.tokens++;
      if (t.isActive(now))
        s.activeTokens++;
    }
    return s;
  }
}

///
unittest {
  mixin(ShowTest!("IdentityStatisticsService"));

  auto t = TenantId("t1");
  auto users = new UserRepository();
  auto a = IAUser(t);
  a.mfaType = MfaType.totp;
  a.mfaSecret = "X";
  a.lastLoginAt = 42;
  users.save(a);
  auto b = IAUser(t);
  b.status = UserStatus.locked;
  b.failedLoginAttempts = 5;
  users.save(b);

  auto svc = new IdentityStatisticsService(users, new GroupRepository(), new ApplicationRepository(),
    new PolicyRepository(), new RiskRuleRepository(), new IdpConfigRepository(), new SessionRepository(),
    new TokenRepository());
  auto s = svc.statistics(t);
  assert(s.users == 2 && s.activeUsers == 1 && s.lockedUsers == 1);
  assert(s.mfaUsers == 1 && s.mfaCoverage == 50 && s.usersWithFailedLogins == 1);
  assert(s.lastLoginAt == 42);
}
