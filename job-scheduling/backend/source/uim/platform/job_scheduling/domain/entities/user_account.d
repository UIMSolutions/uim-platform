/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// A user of the built-in login (authMode "jwt"). The id is the user name.
/// Only a salted password hash is stored; repeated failed logins lock the
/// account for a while.
module uim.platform.job_scheduling.domain.entities.user_account;

import uim.platform.job_scheduling;

mixin(ShowModule!());

@safe:

struct UserAccount {
  mixin TenantEntity!UserAccountId;

  string displayName;
  string passwordHash; /// "pbkdf2-sha256$<iterations>$<salt>$<hash>" (never exposed)
  string[] scopes;
  bool locked; /// locked by an administrator
  int failedLogins;
  long lockedUntil; /// temporary lock after too many failed logins (std time)
  long lastLoginAt;

  bool isLockedAt(long now) const {
    return locked || lockedUntil > now;
  }

  bool hasScope(string scope_) const {
    return scopes.canFind(scope_);
  }

  bool isAdmin() const {
    return hasScope(adminScope);
  }

  /// Count a failed login; lock for lockSeconds after maxFailures.
  void recordFailure(long now, int maxFailures, long lockSeconds) {
    failedLogins++;
    if (maxFailures > 0 && failedLogins >= maxFailures) {
      lockedUntil = plusSeconds(now, lockSeconds);
      failedLogins = 0;
    }
  }

  void recordSuccess(long now) {
    failedLogins = 0;
    lockedUntil = 0;
    lastLoginAt = now;
  }

  void validate() const {
    requireId(id.value, "User name");
    requireMaxLength(displayName, 256, "Display name");
    if (passwordHash.length == 0)
      throw JobSchedulingException.invalid("A password is required");
    normalizeScopes(scopes);
  }
}

/// Password policy: at least minLength characters, not only digits.
void requirePasswordStrength(string password, size_t minLength) {
  if (password.walkLength < minLength)
    throw JobSchedulingException.invalid(format("The password must have at least %d characters", minLength));
  if (password.all!(c => c >= '0' && c <= '9'))
    throw JobSchedulingException.invalid("The password must not consist of digits only");
  if (password.length > 1024)
    throw JobSchedulingException.invalid("The password is too long");
}

///
unittest {
  UserAccount u;
  u.id = UserAccountId("ada");
  u.passwordHash = "x";
  u.scopes = ["Read", "Admin"];
  u.validate();
  assert(u.isAdmin && !u.isLockedAt(1));
  foreach (_; 0 .. 3)
    u.recordFailure(100, 3, 60);
  assert(u.isLockedAt(100) && !u.isLockedAt(plusSeconds(100, 61)) && u.failedLogins == 0);
  u.recordSuccess(200);
  assert(!u.isLockedAt(200) && u.lastLoginAt == 200);
  assert(failsWith(JsErrorKind.invalid, () { requirePasswordStrength("short", 8); }));
  assert(failsWith(JsErrorKind.invalid, () { requirePasswordStrength("12345678", 8); }));
  requirePasswordStrength("correct horse", 8);
}
