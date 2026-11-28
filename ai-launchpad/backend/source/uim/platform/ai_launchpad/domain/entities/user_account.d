/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// A user of the built-in login (authMode "jwt"). The id is the user name.
/// Only a salted password hash is stored; the scopes come from the assigned
/// roles. Repeated failed logins lock the account for a while.
module uim.platform.ai_launchpad.domain.entities.user_account;

import uim.platform.ai_launchpad;

mixin(ShowModule!());

@safe:

struct UserAccount {
  mixin TenantEntity!UserAccountId;

  string displayName;
  string email;
  string passwordHash; /// "pbkdf2-sha256$<iterations>$<salt>$<hash>" (never exposed)
  string[] roles; /// role ids
  bool locked; /// locked by an administrator
  int failedLogins;
  long lockedUntil; /// temporary lock after too many failed logins (std time)
  long lastLoginAt;

  bool isLockedAt(long now) const {
    return locked || lockedUntil > now;
  }

  bool hasRole(string role) const {
    return roles.canFind(role);
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
    requireEmail(email);
    if (passwordHash.length == 0)
      throw AilpException.invalid("A password is required");
    if (roles.length == 0)
      throw AilpException.invalid("A user needs at least one role");
    foreach (r; roles)
      requireId(r, "Role");
  }
}

/// Password policy: at least minLength characters, not only digits.
void requirePasswordStrength(string password, size_t minLength) {
  if (password.walkLength < minLength)
    throw AilpException.invalid(format("The password must have at least %d characters", minLength));
  if (password.all!(c => c >= '0' && c <= '9'))
    throw AilpException.invalid("The password must not consist of digits only");
  if (password.length > 1024)
    throw AilpException.invalid("The password is too long");
}

/// "" or a plausible e-mail address (one @, a dot in the domain, no spaces).
void requireEmail(string email) {
  auto e = email.strip;
  if (e.length == 0)
    return;
  auto at = e.indexOf('@');
  if (at <= 0 || at != e.lastIndexOf('@') || !e[at + 1 .. $].canFind('.') || e.canFind(' ') || e[$ - 1] == '.'
    || e.length > 254)
    throw AilpException.invalid("E-mail '" ~ email ~ "' is not valid");
}

///
unittest {
  UserAccount u;
  u.id = UserAccountId("ada");
  u.passwordHash = "x";
  assert(failsWith(AilpErrorKind.invalid, () { u.validate(); }), "role required");
  u.roles = ["Administrator"];
  u.email = "ada@example.com";
  u.validate();
  assert(u.hasRole("Administrator") && !u.isLockedAt(1));
  foreach (_; 0 .. 3)
    u.recordFailure(100, 3, 60);
  assert(u.isLockedAt(100) && !u.isLockedAt(plusSeconds(100, 61)) && u.failedLogins == 0);
  u.recordSuccess(200);
  assert(!u.isLockedAt(200) && u.lastLoginAt == 200);
  assert(failsWith(AilpErrorKind.invalid, () { requirePasswordStrength("short", 8); }));
  assert(failsWith(AilpErrorKind.invalid, () { requirePasswordStrength("12345678", 8); }));
  assert(failsWith(AilpErrorKind.invalid, () { requireEmail("ada@example"); }));
  requirePasswordStrength("correct horse", 8);
}
