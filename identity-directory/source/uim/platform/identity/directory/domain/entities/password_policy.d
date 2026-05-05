/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.directory.domain.entities.password_policy;

// import uim.platform.identity.directory.domain.types;
import uim.platform.identity.directory;

mixin(ShowModule!());

@safe:
/// Password policy configuration per tenant.
struct PasswordPolicy {
  mixin TenantEntity!PasswordPolicyId;

  string name;
  string description;
  PasswordStrength strength = PasswordStrength.standard;
  size_t minLength = 8;
  size_t maxLength = 128;
  bool requireUppercase = true;
  bool requireLowercase = true;
  bool requireDigit = true;
  bool requireSpecialChar = false;
  size_t minUniqueChars = 3;
  size_t maxRepeatedChars = 3;
  size_t passwordHistoryCount = 5; // how many old passwords to remember
  size_t maxFailedAttempts = 5;
  size_t lockoutDurationMinutes = 30;
  size_t expiryDays = 90; // 0 = no expiry
  size_t warningDaysBeforeExpiry = 14;
  bool active = true;

  /// Check if password meets minimum length.
  bool meetsMinLength(string password) const {
    return password.length >= minLength;
  }

  /// Check if password meets maximum length.
  bool meetsMaxLength(string password) const {
    return password.length <= maxLength;
  }

  Json toJson() const {
    return entityToJson
      .set("name", name)
      .set("description", description)
      .set("strength", strength.to!string())
      .set("minLength", minLength)
      .set("maxLength", maxLength)
      .set("requireUppercase", requireUppercase)
      .set("requireLowercase", requireLowercase)
      .set("requireDigit", requireDigit)
      .set("requireSpecialChar", requireSpecialChar)
      .set("minUniqueChars", minUniqueChars)
      .set("maxRepeatedChars", maxRepeatedChars)
      .set("passwordHistoryCount", passwordHistoryCount)
      .set("maxFailedAttempts", maxFailedAttempts)
      .set("lockoutDurationMinutes", lockoutDurationMinutes)
      .set("expiryDays", expiryDays)
      .set("warningDaysBeforeExpiry", warningDaysBeforeExpiry)
      .set("active", active);
  }
}
