/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.customer_identity.domain.enumerations;

import uim.platform.customer_identity;

// mixin(ShowModule!());

@safe:

enum CustomerStatus {
    pending,
    active,
    locked,
    disabled,
    deleted
}

enum CustomerGender {
    unspecified,
    male,
    female,
    other
}

enum LoginProvider {
    site,
    google,
    facebook,
    apple,
    twitter,
    linkedin,
    saml,
    oidc
}

enum SessionStatus {
    active,
    expired,
    revoked
}

enum SocialIdentityStatus {
    linked,
    unlinked,
    error
}

enum ConsentType {
    marketing,
    analytics,
    functional,
    necessary,
    thirdParty,
    dataProcessing,
    newsletter
}

enum LegalBasis {
    consent,
    contract,
    legalObligation,
    vitalInterests,
    publicTask,
    legitimateInterests
}

enum AuditAction {
    register,
    login,
    logout,
    passwordChange,
    passwordReset,
    profileUpdate,
    consentGranted,
    consentRevoked,
    accountLocked,
    accountDeleted,
    socialLink,
    socialUnlink,
    sessionRevoked,
    policyUpdated,
    adminAction
}

enum ResourceType {
    customer,
    session,
    socialIdentity,
    consentRecord,
    identityProvider,
    screenSet,
    sitePolicy
}

enum IdentityProviderType {
    saml,
    oidc,
    oauth2,
    ldap
}

enum IdentityProviderStatus {
    active,
    inactive,
    testing
}

enum ScreenSetFlowType {
    registrationLogin,
    profileUpdate,
    forgotPassword,
    reAuthentication,
    linkAccount,
    liteRegistration
}

enum ScreenSetStatus {
    draft,
    active,
    archived
}

enum PolicyType {
    password,
    session,
    registration,
    login,
    mfa,
    consent
}

enum MfaMethod {
    none,
    email,
    sms,
    totp,
    push
}

enum PasswordComplexity {
    low,
    medium,
    high,
    custom
}
