/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.customer_identity.domain.entities.site_policy;

import uim.platform.customer_identity;

mixin(ShowModule!());

@safe:

struct SitePolicy {
    mixin TenantEntity!(SitePolicyId);

    string name;
    string description;
    PolicyType policyType;
    int passwordMinLength;
    PasswordComplexity passwordComplexity;
    string passwordRequirements;
    int sessionTimeoutSeconds;
    bool mfaRequired;
    MfaMethod mfaMethod;
    bool captchaEnabled;
    bool socialLoginEnabled;
    bool progressiveProfilingEnabled;
    int maxLoginAttempts;
    int lockoutDurationSeconds;
    bool emailVerificationRequired;
    string version_;

    Json toJson() const {
        return entityToJson
            .set("name", name)
            .set("description", description)
            .set("policyType", policyType.to!string)
            .set("passwordMinLength", passwordMinLength)
            .set("passwordComplexity", passwordComplexity.to!string)
            .set("passwordRequirements", passwordRequirements)
            .set("sessionTimeoutSeconds", sessionTimeoutSeconds)
            .set("mfaRequired", mfaRequired)
            .set("mfaMethod", mfaMethod.to!string)
            .set("captchaEnabled", captchaEnabled)
            .set("socialLoginEnabled", socialLoginEnabled)
            .set("progressiveProfilingEnabled", progressiveProfilingEnabled)
            .set("maxLoginAttempts", maxLoginAttempts)
            .set("lockoutDurationSeconds", lockoutDurationSeconds)
            .set("emailVerificationRequired", emailVerificationRequired)
            .set("version", version_);
    }
}
