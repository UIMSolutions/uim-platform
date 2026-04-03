module uim.platform.identity.directory.domain.services.password_validator;

import uim.platform.identity.directory.domain.entities.password_policy;

/// Domain service: validates passwords against policy rules.
struct PasswordValidationResult
{
    bool valid;
    string[] violations;
}

/// Validate a password against a password policy.
PasswordValidationResult validatePassword(string password, PasswordPolicy policy)
{
    string[] violations;

    if (!policy.meetsMinLength(password))
    {
        // import std.conv : to;
        violations ~= "Password must be at least " ~ policy.minLength.to!string ~ " characters";
    }

    if (!policy.meetsMaxLength(password))
    {
        // import std.conv : to;
        violations ~= "Password must not exceed " ~ policy.maxLength.to!string ~ " characters";
    }

    if (policy.requireUppercase && !hasUppercase(password))
        violations ~= "Password must contain at least one uppercase letter";

    if (policy.requireLowercase && !hasLowercase(password))
        violations ~= "Password must contain at least one lowercase letter";

    if (policy.requireDigit && !hasDigit(password))
        violations ~= "Password must contain at least one digit";

    if (policy.requireSpecialChar && !hasSpecialChar(password))
        violations ~= "Password must contain at least one special character";

    if (policy.minUniqueChars > 0 && uniqueCharCount(password) < policy.minUniqueChars)
    {
        // import std.conv : to;
        violations ~= "Password must contain at least " ~ policy.minUniqueChars.to!string ~ " unique characters";
    }

    if (policy.maxRepeatedChars > 0 && hasExcessiveRepeats(password, policy.maxRepeatedChars))
    {
        // import std.conv : to;
        violations ~= "Password must not repeat a character more than " ~ policy.maxRepeatedChars.to!string ~ " times consecutively";
    }

    return PasswordValidationResult(violations.length == 0, violations);
}

private bool hasUppercase(string s)
{
    foreach (c; s)
        if (c >= 'A' && c <= 'Z')
            return true;
    return false;
}

private bool hasLowercase(string s)
{
    foreach (c; s)
        if (c >= 'a' && c <= 'z')
            return true;
    return false;
}

private bool hasDigit(string s)
{
    foreach (c; s)
        if (c >= '0' && c <= '9')
            return true;
    return false;
}

private bool hasSpecialChar(string s)
{
    foreach (c; s)
        if (!((c >= 'A' && c <= 'Z') || (c >= 'a' && c <= 'z') || (c >= '0' && c <= '9')))
            return true;
    return false;
}

private uint uniqueCharCount(string s)
{
    bool[char] seen;
    foreach (c; s)
        seen[c] = true;
    return cast(uint) seen.length;
}

private bool hasExcessiveRepeats(string s, uint maxRepeats)
{
    if (s.length < 2)
        return false;
    uint count = 1;
    foreach (i; 1 .. s.length)
    {
        if (s[i] == s[i - 1])
        {
            count++;
            if (count > maxRepeats)
                return true;
        }
        else
        {
            count = 1;
        }
    }
    return false;
}
