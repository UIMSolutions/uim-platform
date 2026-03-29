module domain.entities.password_policy;

import domain.types;

/// Password policy configuration per tenant.
struct PasswordPolicy
{
    string id;
    TenantId tenantId;
    string name;
    string description;
    PasswordStrength strength = PasswordStrength.standard;
    uint minLength = 8;
    uint maxLength = 128;
    bool requireUppercase = true;
    bool requireLowercase = true;
    bool requireDigit = true;
    bool requireSpecialChar = false;
    uint minUniqueChars = 3;
    uint maxRepeatedChars = 3;
    uint passwordHistoryCount = 5;   // how many old passwords to remember
    uint maxFailedAttempts = 5;
    uint lockoutDurationMinutes = 30;
    uint expiryDays = 90;            // 0 = no expiry
    uint warningDaysBeforeExpiry = 14;
    bool active = true;
    long createdAt;
    long updatedAt;

    /// Check if password meets minimum length.
    bool meetsMinLength(string password) const
    {
        return password.length >= minLength;
    }

    /// Check if password meets maximum length.
    bool meetsMaxLength(string password) const
    {
        return password.length <= maxLength;
    }
}
