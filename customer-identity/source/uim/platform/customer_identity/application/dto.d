/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.customer_identity.application.dto;

import uim.platform.customer_identity;

// mixin(ShowModule!());

@safe:

struct CustomerDTO {
    CustomerId customerId;
    TenantId tenantId;
    string email;
    string phone;
    string firstName;
    string lastName;
    string password;
    string status;
    string loginProvider;
    string locale;
    string country;
    string birthDate;
    string gender;
    string profileData;
    string progressiveData;
    UserId createdBy;
    UserId updatedBy;
}

struct CustomerSessionDTO {
    CustomerSessionId sessionId;
    TenantId tenantId;
    CustomerId customerId;
    string token;
    string deviceInfo;
    string ipAddress;
    string userAgent;
    long expiresAt;
    UserId createdBy;
}

struct SocialIdentityDTO {
    SocialIdentityId identityId;
    TenantId tenantId;
    CustomerId customerId;
    string provider;
    string providerUserId;
    string providerEmail;
    string displayName;
    string accessToken;
    string refreshToken;
    long tokenExpiresAt;
    string profileData;
    UserId createdBy;
    UserId updatedBy;
}

struct ConsentRecordDTO {
    ConsentRecordId recordId;
    TenantId tenantId;
    CustomerId customerId;
    string consentType;
    string purpose;
    string legalBasis;
    bool granted;
    string ipAddress;
    string userAgent;
    string version_;
    string locale;
    UserId createdBy;
}

struct AuditLogDTO {
    AuditLogId auditLogId;
    TenantId tenantId;
    string actorId;
    string action;
    string resourceType;
    string resourceId;
    string ipAddress;
    string userAgent;
    string details;
    bool success;
    UserId createdBy;
}

struct IdentityProviderDTO {
    IdentityProviderId providerId;
    TenantId tenantId;
    string name;
    string description;
    string providerType;
    string clientId;
    string clientSecret;
    string issuerUrl;
    string metadataUrl;
    string redirectUri;
    string attributeMapping;
    string scopes;
    string status;
    UserId createdBy;
    UserId updatedBy;
}

struct ScreenSetDTO {
    ScreenSetId screenSetId;
    TenantId tenantId;
    string name;
    string description;
    string flowType;
    string htmlContent;
    string cssContent;
    string jsContent;
    string locale;
    string version_;
    string status;
    UserId createdBy;
    UserId updatedBy;
}

struct SitePolicyDTO {
    SitePolicyId policyId;
    TenantId tenantId;
    string name;
    string description;
    string policyType;
    int passwordMinLength;
    string passwordComplexity;
    string passwordRequirements;
    int sessionTimeoutSeconds;
    bool mfaRequired;
    string mfaMethod;
    bool captchaEnabled;
    bool socialLoginEnabled;
    bool progressiveProfilingEnabled;
    int maxLoginAttempts;
    int lockoutDurationSeconds;
    bool emailVerificationRequired;
    string version_;
    UserId createdBy;
    UserId updatedBy;
}
