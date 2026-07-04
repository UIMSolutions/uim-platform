/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.customer_identity.domain.enumerations;

import uim.platform.customer_identity;

mixin(ShowModule!());

@safe:

enum CustomerStatus {
    pending,
    active,
    locked,
    disabled,
    deleted
}
CustomerStatus toCustomerStatus (string value) {
    mixin(EnumSwitch!("CustomerStatus", "pending"));
}
CustomerStatus[] toCustomerStatusArray (string[] values) {
    return values.map!(toCustomerStatus).array;
}
string toString (CustomerStatus status) {
    mixin(EnumToString!("CustomerStatus"));
}
string[] toString(CustomerStatus[] statuses) {
    return statuses.map!(toString).array;
}
///
unittest {
    mixin(ShowTest!("CustomerStatus"));

    assert(toCustomerStatus("pending") == CustomerStatus.pending);
    assert(toCustomerStatus("active") == CustomerStatus.active);
    assert(toCustomerStatus("locked") == CustomerStatus.locked);
    assert(toCustomerStatus("disabled") == CustomerStatus.disabled);
    assert(toCustomerStatus("deleted") == CustomerStatus.deleted);

    assert(toCustomerStatus("") == CustomerStatus.pending);
    assert(toCustomerStatus("unknown") == CustomerStatus.pending);

    assert(toCustomerStatusArray(["pending", "locked"]) == [CustomerStatus.pending, CustomerStatus.locked]);

    assert(toString(CustomerStatus.pending) == "pending");
    assert(toString(CustomerStatus.active) == "active");
    assert(toString(CustomerStatus.locked) == "locked");
    assert(toString(CustomerStatus.disabled) == "disabled");
    assert(toString(CustomerStatus.deleted) == "deleted");

    assert(toString([CustomerStatus.pending, CustomerStatus.locked]) == ["pending", "locked"]);
}

enum CustomerGender {
    unspecified,
    male,
    female,
    other
}
CustomerGender toCustomerGender (string value) {
    mixin(EnumSwitch!("CustomerGender", "unspecified"));
}
CustomerGender[] toCustomerGender (string[] values) {
    return values.map!(toCustomerGender).array;
}
string toString (CustomerGender gender ) {
    return gender.to!string();
}
string[] toString(CustomerGender[] genders) {
    return genders.map!(toString).array;
}
/// 
unittest {
    mixin(ShowTest!("CustomerGender"));

    assert(toCustomerGender("unspecified") == CustomerGender.unspecified);
    assert(toCustomerGender("male") == CustomerGender.male);
    assert(toCustomerGender("female") == CustomerGender.female);
    assert(toCustomerGender("other") == CustomerGender.other);  

    assert(toCustomerGender("") == CustomerGender.unspecified);
    assert(toCustomerGender("unknown") == CustomerGender.unspecified);

    assert(toCustomerGender(["unspecified", "female"]) == [CustomerGender.unspecified, CustomerGender.female]);

    assert(toString(CustomerGender.unspecified) == "unspecified");
    assert(toString(CustomerGender.male) == "male");
    assert(toString(CustomerGender.female) == "female");
    assert(toString(CustomerGender.other) == "other");  

    assert(toString([CustomerGender.unspecified, CustomerGender.female]) == ["unspecified", "female"]);
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
LoginProvider toLoginProvider (string value) {
    mixin(EnumSwitch!("LoginProvider", "site"));
}
LoginProvider[] toLoginProvider (string[] values) {
    return values.map!(toLoginProvider).array;
}
string toString (LoginProvider provider) {
    return provider.to!string();
}
string[] toString(LoginProvider[] providers) {
    return providers.map!(toString).array;
}
/// 
unittest {
    mixin(ShowTest!("LoginProvider"));

    assert(toLoginProvider("site") == LoginProvider.site);
    assert(toLoginProvider("google") == LoginProvider.google);
    assert(toLoginProvider("facebook") == LoginProvider.facebook);
    assert(toLoginProvider("apple") == LoginProvider.apple);
    assert(toLoginProvider("twitter") == LoginProvider.twitter);
    assert(toLoginProvider("linkedin") == LoginProvider.linkedin);
    assert(toLoginProvider("saml") == LoginProvider.saml);
    assert(toLoginProvider("oidc") == LoginProvider.oidc);

    assert(toLoginProvider("") == LoginProvider.site);
    assert(toLoginProvider("unknown") == LoginProvider.site);

    assert(toLoginProvider(["site", "google"]) == [LoginProvider.site, LoginProvider.google]);

    assert(toString(LoginProvider.site) == "site");
    assert(toString(LoginProvider.google) == "google");
    assert(toString(LoginProvider.facebook) == "facebook");
    assert(toString(LoginProvider.apple) == "apple");
    assert(toString(LoginProvider.twitter) == "twitter");
    assert(toString(LoginProvider.linkedin) == "linkedin");
    assert(toString(LoginProvider.saml) == "saml");
    assert(toString(LoginProvider.oidc) == "oidc");

    assert(toString([LoginProvider.site, LoginProvider.google]) == ["site", "google"]);
}

enum SessionStatus {
    active,
    expired,
    revoked
}
SessionStatus toSessionStatus(string value) {
    mixin(EnumSwitch!("SessionStatus", "active"));
}
SessionStatus[] toSessionStatus(string[] values) {
    return values.map!(toSessionStatus).array;
}
string toString(SessionStatus status) {
    return status.to!string();
}
string[] toString(SessionStatus[] statuses) {
    return statuses.map!(toString).array;
}
///
unittest {
    mixin(ShowTest!("SessionStatus"));

    assert(toSessionStatus("active") == SessionStatus.active);
    assert(toSessionStatus("expired") == SessionStatus.expired);
    assert(toSessionStatus("revoked") == SessionStatus.revoked);

    assert(toSessionStatus("") == SessionStatus.active);
    assert(toSessionStatus("unknown") == SessionStatus.active);

    assert(toSessionStatus(["active", "revoked"]) == [SessionStatus.active, SessionStatus.revoked]);

    assert(toString(SessionStatus.active) == "active");
    assert(toString(SessionStatus.expired) == "expired");
    assert(toString(SessionStatus.revoked) == "revoked");

    assert(toString([SessionStatus.active, SessionStatus.revoked]) == ["active", "revoked"]);
}

enum SocialIdentityStatus {
    linked,
    unlinked,
    error
}
SocialIdentityStatus toSocialIdentityStatus(string value) {
    mixin(EnumSwitch!("SocialIdentityStatus", "linked"));
}
SocialIdentityStatus[] toSocialIdentityStatus(string[] values) {
    return values.map!(toSocialIdentityStatus).array;
}
string toString(SocialIdentityStatus status) {
    return status.to!string();
}
string[] toString(SocialIdentityStatus[] statuses) {
    return statuses.map!(toString).array;
}
///
unittest {
    mixin(ShowTest!("SocialIdentityStatus"));

    assert(toSocialIdentityStatus("linked") == SocialIdentityStatus.linked);
    assert(toSocialIdentityStatus("unlinked") == SocialIdentityStatus.unlinked);
    assert(toSocialIdentityStatus("error") == SocialIdentityStatus.error);

    assert(toSocialIdentityStatus("") == SocialIdentityStatus.linked);
    assert(toSocialIdentityStatus("unknown") == SocialIdentityStatus.linked);

    assert(toSocialIdentityStatus(["linked", "error"]) == [SocialIdentityStatus.linked, SocialIdentityStatus.error]);

    assert(toString(SocialIdentityStatus.linked) == "linked");
    assert(toString(SocialIdentityStatus.unlinked) == "unlinked");
    assert(toString(SocialIdentityStatus.error) == "error");

    assert(toString([SocialIdentityStatus.linked, SocialIdentityStatus.error]) == ["linked", "error"]);
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
ConsentType toConsentType(string value) {
    mixin(EnumSwitch!("ConsentType", "marketing"));
}
ConsentType[] toConsentType(string[] values) {
    return values.map!(toConsentType).array;
}
string toString(ConsentType type) {
    return type.to!string();
}
string[] toString(ConsentType[] types) {
    return types.map!(toString).array;
}
///
unittest {
    mixin(ShowTest!("ConsentType"));

    assert(toConsentType("marketing") == ConsentType.marketing);
    assert(toConsentType("analytics") == ConsentType.analytics);
    assert(toConsentType("functional") == ConsentType.functional);
    assert(toConsentType("necessary") == ConsentType.necessary);
    assert(toConsentType("thirdParty") == ConsentType.thirdParty);
    assert(toConsentType("dataProcessing") == ConsentType.dataProcessing);
    assert(toConsentType("newsletter") == ConsentType.newsletter);

    assert(toConsentType("") == ConsentType.marketing);
    assert(toConsentType("unknown") == ConsentType.marketing);

    assert(toConsentType(["marketing", "functional"]) == [ConsentType.marketing, ConsentType.functional]);

    assert(toString(ConsentType.marketing) == "marketing");
    assert(toString(ConsentType.analytics) == "analytics");
    assert(toString(ConsentType.functional) == "functional");
    assert(toString(ConsentType.necessary) == "necessary");
    assert(toString(ConsentType.thirdParty) == "thirdParty");
    assert(toString(ConsentType.dataProcessing) == "dataProcessing");
    assert(toString(ConsentType.newsletter) == "newsletter");

    assert(toString([ConsentType.marketing, ConsentType.functional]) == ["marketing", "functional"]);
}

enum LegalBasis {
    consent,
    contract,
    legalObligation,
    vitalInterests,
    publicTask,
    legitimateInterests
}
LegalBasis toLegalBasis(string value) {
    mixin(EnumSwitch!("LegalBasis", "consent"));
}
LegalBasis[] toLegalBasis(string[] values) {
    return values.map!(toLegalBasis).array;
}
string toString(LegalBasis basis) { 
    return basis.to!string();
}
string[] toString(LegalBasis[] bases) {
    return bases.map!(toString).array;
}
///
unittest {
    mixin(ShowTest!("LegalBasis"));

    assert(toLegalBasis("consent") == LegalBasis.consent);
    assert(toLegalBasis("contract") == LegalBasis.contract);
    assert(toLegalBasis("legalObligation") == LegalBasis.legalObligation);  
    assert(toLegalBasis("vitalInterests") == LegalBasis.vitalInterests);
    assert(toLegalBasis("publicTask") == LegalBasis.publicTask);
    assert(toLegalBasis("legitimateInterests") == LegalBasis.legitimateInterests);

    assert(toLegalBasis("") == LegalBasis.consent);
    assert(toLegalBasis("unknown") == LegalBasis.consent);

    assert(toLegalBasis(["consent", "contract"]) == [LegalBasis.consent, LegalBasis.contract]);

    assert(toString(LegalBasis.consent) == "consent");
    assert(toString(LegalBasis.contract) == "contract");
    assert(toString(LegalBasis.legalObligation) == "legalObligation");
    assert(toString(LegalBasis.vitalInterests) == "vitalInterests");
    assert(toString(LegalBasis.publicTask) == "publicTask");
    assert(toString(LegalBasis.legitimateInterests) == "legitimateInterests");

    assert(toString([LegalBasis.consent, LegalBasis.contract]) == ["consent", "contract"]);
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
AuditAction toAuditAction(string value) {
    mixin(EnumSwitch!("AuditAction", "register"));
}
AuditAction[] toAuditAction(string[] values) {
    return values.map!(toAuditAction).array;
}
string toString(AuditAction action) {
    return action.to!string();
}
string[] toString(AuditAction[] actions) {
    return actions.map!(toString).array;
}
///
unittest {
    mixin(ShowTest!("AuditAction"));

    assert("register".toAuditAction == AuditAction.register);
    assert("login".toAuditAction == AuditAction.login);
    assert("logout".toAuditAction == AuditAction.logout);
    assert("passwordChange".toAuditAction == AuditAction.passwordChange);
    assert("passwordReset".toAuditAction == AuditAction.passwordReset);
    assert("profileUpdate".toAuditAction == AuditAction.profileUpdate);
    assert("consentGranted".toAuditAction == AuditAction.consentGranted);
    assert("consentRevoked".toAuditAction == AuditAction.consentRevoked);
    assert("accountLocked".toAuditAction == AuditAction.accountLocked);
    assert("accountDeleted".toAuditAction == AuditAction.accountDeleted);
    assert("socialLink".toAuditAction == AuditAction.socialLink);
    assert("socialUnlink".toAuditAction == AuditAction.socialUnlink);
    assert("sessionRevoked".toAuditAction == AuditAction.sessionRevoked);
    assert("policyUpdated".toAuditAction == AuditAction.policyUpdated);
    assert("adminAction".toAuditAction == AuditAction.adminAction);    

    assert("".toAuditAction == AuditAction.register);
    assert("unknown".toAuditAction == AuditAction.register);

    assert(["register", "login"].toAuditAction == [AuditAction.register, AuditAction.login]);

    assert(AuditAction.register.toString == "register");
    assert(AuditAction.login.toString == "login");
    assert(AuditAction.logout.toString == "logout");   
    assert(AuditAction.passwordChange.toString == "passwordChange");
    assert(AuditAction.passwordReset.toString == "passwordReset");
    assert(AuditAction.profileUpdate.toString == "profileUpdate");
    assert(AuditAction.consentGranted.toString == "consentGranted");
    assert(AuditAction.consentRevoked.toString == "consentRevoked");
    assert(AuditAction.accountLocked.toString == "accountLocked");
    assert(AuditAction.accountDeleted.toString == "accountDeleted");
    assert(AuditAction.socialLink.toString == "socialLink");
    assert(AuditAction.socialUnlink.toString == "socialUnlink");
    assert(AuditAction.sessionRevoked.toString == "sessionRevoked");
    assert(AuditAction.policyUpdated.toString == "policyUpdated");
    assert(AuditAction.adminAction.toString == "adminAction");

    assert([AuditAction.register, AuditAction.login].toString == ["register", "login"]);
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
ResourceType toResourceType(string value) {
    mixin(EnumSwitch!("ResourceType", "customer"));
}
ResourceType[] toResourceType(string[] values) {
    return values.map!(toResourceType).array;
}
string toString(ResourceType type) {
    return type.to!string();
}
string[] toString(ResourceType[] types) {
    return types.map!(toString).array;
}
///
unittest {
    mixin(ShowTest!("ResourceType"));   

    assert(toResourceType("customer") == ResourceType.customer);
    assert(toResourceType("session") == ResourceType.session);
    assert(toResourceType("socialIdentity") == ResourceType.socialIdentity);
    assert(toResourceType("consentRecord") == ResourceType.consentRecord);
    assert(toResourceType("identityProvider") == ResourceType.identityProvider);
    assert(toResourceType("screenSet") == ResourceType.screenSet);
    assert(toResourceType("sitePolicy") == ResourceType.sitePolicy);

    assert(toResourceType("") == ResourceType.customer);
    assert(toResourceType("unknown") == ResourceType.customer);

    assert(toResourceType(["customer", "session"]) == [ResourceType.customer, ResourceType.session]);

    assert(toString(ResourceType.customer) == "customer");
    assert(toString(ResourceType.session) == "session");
    assert(toString(ResourceType.socialIdentity) == "socialIdentity");
    assert(toString(ResourceType.consentRecord) == "consentRecord");
    assert(toString(ResourceType.identityProvider) == "identityProvider");
    assert(toString(ResourceType.screenSet) == "screenSet");
    assert(toString(ResourceType.sitePolicy) == "sitePolicy");

    assert(toString([ResourceType.customer, ResourceType.session]) == ["customer", "session"]);
}

enum IdentityProviderType {
    saml,
    oidc,
    oauth2,
    ldap
}
IdentityProviderType toIdentityProviderType(string value) {
    mixin(EnumSwitch!("IdentityProviderType", "saml"));
}
IdentityProviderType[] toIdentityProviderType(string[] values) {
    return values.map!(toIdentityProviderType).array;
}
string toString(IdentityProviderType type) {
    return type.to!string();
}
string[] toString(IdentityProviderType[] types) {
    return types.map!(toString).array;
}
///
unittest {
    mixin(ShowTest!("IdentityProviderType"));   

    assert(toIdentityProviderType("saml") == IdentityProviderType.saml);
    assert(toIdentityProviderType("oidc") == IdentityProviderType.oidc);
    assert(toIdentityProviderType("oauth2") == IdentityProviderType.oauth2);
    assert(toIdentityProviderType("ldap") == IdentityProviderType.ldap);

    assert(toIdentityProviderType("") == IdentityProviderType.saml);
    assert(toIdentityProviderType("unknown") == IdentityProviderType.saml);

    assert(toIdentityProviderType(["saml", "oidc"]) == [IdentityProviderType.saml, IdentityProviderType.oidc]);

    assert(toString(IdentityProviderType.saml) == "saml");
    assert(toString(IdentityProviderType.oidc) == "oidc");
    assert(toString(IdentityProviderType.oauth2) == "oauth2");
    assert(toString(IdentityProviderType.ldap) == "ldap");

    assert(toString([IdentityProviderType.saml, IdentityProviderType.oidc]) == ["saml", "oidc"]);
}

enum IdentityProviderStatus {
    active,
    inactive,
    testing
}
IdentityProviderStatus toIdentityProviderStatus(string value) {
    mixin(EnumSwitch!("IdentityProviderStatus", "active"));
}
IdentityProviderStatus[] toIdentityProviderStatus(string[] values) {
    return values.map!(toIdentityProviderStatus).array;
}
string toString(IdentityProviderStatus status) {
    return status.to!string();
}
string[] toString(IdentityProviderStatus[] statuses) {
    return statuses.map!(toString).array;
}
///
unittest {
    mixin(ShowTest!("IdentityProviderStatus"));

    assert(toIdentityProviderStatus("active") == IdentityProviderStatus.active);
    assert(toIdentityProviderStatus("inactive") == IdentityProviderStatus.inactive);
    assert(toIdentityProviderStatus("testing") == IdentityProviderStatus.testing);

    assert(toIdentityProviderStatus("") == IdentityProviderStatus.active);
    assert(toIdentityProviderStatus("unknown") == IdentityProviderStatus.active);

    assert(toIdentityProviderStatus(["active", "testing"]) == [IdentityProviderStatus.active, IdentityProviderStatus.testing]);

    assert(toString(IdentityProviderStatus.active) == "active");
    assert(toString(IdentityProviderStatus.inactive) == "inactive");
    assert(toString(IdentityProviderStatus.testing) == "testing");

    assert(toString([IdentityProviderStatus.active, IdentityProviderStatus.testing]) == ["active", "testing"]);
}

enum ScreenSetFlowType {
    registrationLogin,
    profileUpdate,
    forgotPassword,
    reAuthentication,
    linkAccount,
    liteRegistration
}
ScreenSetFlowType toScreenSetFlowType(string value) {
    mixin(EnumSwitch!("ScreenSetFlowType", "registrationLogin"));
}
ScreenSetFlowType[] toScreenSetFlowType(string[] values) {
    return values.map!(toScreenSetFlowType).array;
}
string toString(ScreenSetFlowType type) {
    return type.to!string();
}
string[] toString(ScreenSetFlowType[] types) {  
    return types.map!(toString).array;
}   
///
unittest {
    mixin(ShowTest!("ScreenSetFlowType"));

    assert(toScreenSetFlowType("registrationLogin") == ScreenSetFlowType.registrationLogin);
    assert(toScreenSetFlowType("profileUpdate") == ScreenSetFlowType.profileUpdate);
    assert(toScreenSetFlowType("forgotPassword") == ScreenSetFlowType.forgotPassword);
    assert(toScreenSetFlowType("reAuthentication") == ScreenSetFlowType.reAuthentication);
    assert(toScreenSetFlowType("linkAccount") == ScreenSetFlowType.linkAccount);
    assert(toScreenSetFlowType("liteRegistration") == ScreenSetFlowType.liteRegistration);

    assert(toScreenSetFlowType("") == ScreenSetFlowType.registrationLogin);
    assert(toScreenSetFlowType("unknown") == ScreenSetFlowType.registrationLogin);

    assert(toScreenSetFlowType(["registrationLogin", "forgotPassword"]) == [ScreenSetFlowType.registrationLogin, ScreenSetFlowType.forgotPassword]);    

    assert(toString(ScreenSetFlowType.registrationLogin) == "registrationLogin");
    assert(toString(ScreenSetFlowType.profileUpdate) == "profileUpdate");
    assert(toString(ScreenSetFlowType.forgotPassword) == "forgotPassword");
    assert(toString(ScreenSetFlowType.reAuthentication) == "reAuthentication");
    assert(toString(ScreenSetFlowType.linkAccount) == "linkAccount");
    assert(toString(ScreenSetFlowType.liteRegistration) == "liteRegistration");

    assert(toString([ScreenSetFlowType.registrationLogin, ScreenSetFlowType.forgotPassword]) == ["registrationLogin", "forgotPassword"]);
}

enum ScreenSetStatus {
    draft,
    active,
    archived
}
ScreenSetStatus toScreenSetStatus(string value) {
    mixin(EnumSwitch!("ScreenSetStatus", "draft"));
}
ScreenSetStatus[] toScreenSetStatus(string[] values) {
    return values.map!(toScreenSetStatus).array;
}
string toString(ScreenSetStatus status) {
    return status.to!string();
}
string[] toString(ScreenSetStatus[] statuses) {
    return statuses.map!(toString).array;
}
///
unittest {
    mixin(ShowTest!("ScreenSetStatus"));

    assert(toScreenSetStatus("draft") == ScreenSetStatus.draft);
    assert(toScreenSetStatus("active") == ScreenSetStatus.active);
    assert(toScreenSetStatus("archived") == ScreenSetStatus.archived);

    assert(toScreenSetStatus("") == ScreenSetStatus.draft);
    assert(toScreenSetStatus("unknown") == ScreenSetStatus.draft);

    assert(toScreenSetStatus(["draft", "archived"]) == [ScreenSetStatus.draft, ScreenSetStatus.archived]);

    assert(toString(ScreenSetStatus.draft) == "draft");
    assert(toString(ScreenSetStatus.active) == "active");
    assert(toString(ScreenSetStatus.archived) == "archived");

    assert(toString([ScreenSetStatus.draft, ScreenSetStatus.archived]) == ["draft", "archived"]);
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
