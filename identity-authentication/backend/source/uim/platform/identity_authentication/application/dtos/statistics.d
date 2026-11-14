/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_authentication.application.dtos.statistics;

import uim.platform.identity_authentication;

mixin(ShowModule!());

@safe:

/// Aggregated figures of one tenant (OData singleton "Statistics", CLI
/// "stats", GUI overview, Fiori KPI header).
struct IdentityStatistics {
  TenantId tenantId;

  size_t users;
  size_t activeUsers;
  size_t lockedUsers;
  size_t inactiveUsers;
  size_t pendingUsers;
  size_t mfaUsers;
  size_t usersWithFailedLogins;
  size_t groups;
  size_t applications;
  size_t activeApplications;
  size_t policies;
  size_t riskRules;
  size_t identityProviders;
  size_t sessions;
  size_t activeSessions;
  size_t tokens;
  size_t activeTokens;
  long lastLoginAt;

  /// Percentage of users with a second factor (0–100).
  int mfaCoverage() const {
    return users == 0 ? 0 : cast(int)(mfaUsers * 100 / users);
  }

  Json toJson() const {
    return Json.emptyObject
      .set("tenantId", tenantId.value)
      .set("users", users)
      .set("activeUsers", activeUsers)
      .set("lockedUsers", lockedUsers)
      .set("inactiveUsers", inactiveUsers)
      .set("pendingUsers", pendingUsers)
      .set("mfaUsers", mfaUsers)
      .set("mfaCoverage", mfaCoverage)
      .set("usersWithFailedLogins", usersWithFailedLogins)
      .set("groups", groups)
      .set("applications", applications)
      .set("activeApplications", activeApplications)
      .set("policies", policies)
      .set("riskRules", riskRules)
      .set("identityProviders", identityProviders)
      .set("sessions", sessions)
      .set("activeSessions", activeSessions)
      .set("tokens", tokens)
      .set("activeTokens", activeTokens)
      .set("lastLoginAt", lastLoginAt);
  }
}
