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
string[] toStrings(CustomerStatus[] statuses) {
    return statuses.map!toString.array;
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

    assert(toStrings([CustomerStatus.pending, CustomerStatus.locked]) == ["pending", "locked"]);
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
CustomerGender[] toCustomerGenders (string[] values) {
    return values.map!(toCustomerGender).array;
}
string toString (CustomerGender gender ) {
    return gender.to!string;
}
string[] toStrings(CustomerGender[] genders) {
    return genders.map!toString.array;
}
/// 
unittest {
    mixin(ShowTest!("CustomerGender"));

    assert("unspecified".toCustomerGender == CustomerGender.unspecified);
    assert("male".toCustomerGender == CustomerGender.male);
    assert("female".toCustomerGender == CustomerGender.female);
    assert("other".toCustomerGender == CustomerGender.other);  

    assert("".toCustomerGender == CustomerGender.unspecified);
    assert("unknown".toCustomerGender == CustomerGender.unspecified);

    assert(["unspecified", "female"].toCustomerGenders == [CustomerGender.unspecified, CustomerGender.female]);

    assert(CustomerGender.unspecified.toString == "unspecified");
    assert(CustomerGender.male.toString == "male");
    assert(CustomerGender.female.toString == "female");
    assert(CustomerGender.other.toString == "other");  

    assert([CustomerGender.unspecified, CustomerGender.female].toStrings == ["unspecified", "female"]);
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
LoginProvider[] toLoginProviders (string[] values) {
    return values.map!(toLoginProvider).array;
}
string toString (LoginProvider provider) {
    return provider.to!string;
}
string[] toStrings(LoginProvider[] providers) {
    return providers.map!toString.array;
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

    assert(["site", "google"].toLoginProviders == [LoginProvider.site, LoginProvider.google]);

    assert(toString(LoginProvider.site) == "site");
    assert(toString(LoginProvider.google) == "google");
    assert(toString(LoginProvider.facebook) == "facebook");
    assert(toString(LoginProvider.apple) == "apple");
    assert(toString(LoginProvider.twitter) == "twitter");
    assert(toString(LoginProvider.linkedin) == "linkedin");
    assert(toString(LoginProvider.saml) == "saml");
    assert(toString(LoginProvider.oidc) == "oidc");

    assert(toStrings([LoginProvider.site, LoginProvider.google]) == ["site", "google"]);
}

enum SessionStatus {
    active,
    expired,
    revoked
}
SessionStatus toSessionStatus(string value) {
    mixin(EnumSwitch!("SessionStatus", "active"));
}
SessionStatus[] toSessionStatuses(string[] values) {
    return values.map!(toSessionStatus).array;
}
string toString(SessionStatus status) {
    return status.to!string;
}
string[] toStrings(SessionStatus[] statuses) {
    return statuses.map!toString.array;
}
///
unittest {
    mixin(ShowTest!("SessionStatus"));

    assert(toSessionStatus("active") == SessionStatus.active);
    assert(toSessionStatus("expired") == SessionStatus.expired);
    assert(toSessionStatus("revoked") == SessionStatus.revoked);

    assert(toSessionStatus("") == SessionStatus.active);
    assert(toSessionStatus("unknown") == SessionStatus.active);

    assert(["active", "revoked"].toSessionStatuses == [SessionStatus.active, SessionStatus.revoked]);

    assert(toString(SessionStatus.active) == "active");
    assert(toString(SessionStatus.expired) == "expired");
    assert(toString(SessionStatus.revoked) == "revoked");

    assert(toStrings([SessionStatus.active, SessionStatus.revoked]) == ["active", "revoked"]);
}

enum SocialIdentityStatus {
    linked,
    unlinked,
    error
}
SocialIdentityStatus toSocialIdentityStatus(string value) {
    mixin(EnumSwitch!("SocialIdentityStatus", "linked"));
}
SocialIdentityStatus[] toSocialIdentityStatuses(string[] values) {
    return values.map!(toSocialIdentityStatus).array;
}
string toString(SocialIdentityStatus status) {
    return status.to!string;
}
string[] toStrings(SocialIdentityStatus[] statuses) {
    return statuses.map!toString.array;
}
///
unittest {
    mixin(ShowTest!("SocialIdentityStatus"));

    assert(toSocialIdentityStatus("linked") == SocialIdentityStatus.linked);
    assert(toSocialIdentityStatus("unlinked") == SocialIdentityStatus.unlinked);
    assert(toSocialIdentityStatus("error") == SocialIdentityStatus.error);

    assert(toSocialIdentityStatus("") == SocialIdentityStatus.linked);
    assert(toSocialIdentityStatus("unknown") == SocialIdentityStatus.linked);

    assert(["linked", "error"].toSocialIdentityStatuses == [SocialIdentityStatus.linked, SocialIdentityStatus.error]);

    assert(toString(SocialIdentityStatus.linked) == "linked");
    assert(toString(SocialIdentityStatus.unlinked) == "unlinked");
    assert(toString(SocialIdentityStatus.error) == "error");

    assert(toStrings([SocialIdentityStatus.linked, SocialIdentityStatus.error]) == ["linked", "error"]);
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
ConsentType[] toConsentTypes(string[] values) {
    return values.map!(toConsentType).array;
}
string toString(ConsentType type) {
    return type.to!string;
}
string[] toStrings(ConsentType[] types) {
    return types.map!toString.array;
}
///
unittest {
    mixin(ShowTest!("ConsentType"));

    assert("marketing".toConsentType == ConsentType.marketing);
    assert("analytics".toConsentType == ConsentType.analytics);
    assert("functional".toConsentType == ConsentType.functional);
    assert("necessary".toConsentType == ConsentType.necessary);
    assert("thirdParty".toConsentType == ConsentType.thirdParty);
    assert("dataProcessing".toConsentType == ConsentType.dataProcessing);
    assert("newsletter".toConsentType == ConsentType.newsletter);

    assert(toConsentType("") == ConsentType.marketing);
    assert(toConsentType("unknown") == ConsentType.marketing);

    assert(["marketing", "functional"].toConsentTypes == [ConsentType.marketing, ConsentType.functional]);

    assert(toString(ConsentType.marketing) == "marketing");
    assert(toString(ConsentType.analytics) == "analytics");
    assert(toString(ConsentType.functional) == "functional");
    assert(toString(ConsentType.necessary) == "necessary");
    assert(toString(ConsentType.thirdParty) == "thirdParty");
    assert(toString(ConsentType.dataProcessing) == "dataProcessing");
    assert(toString(ConsentType.newsletter) == "newsletter");

    assert(toStrings([ConsentType.marketing, ConsentType.functional]) == ["marketing", "functional"]);
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
LegalBasis[] toLegalBases(string[] values) {
    return values.map!(toLegalBasis).array;
}
string toString(LegalBasis basis) { 
    return basis.to!string;
}
string[] toStrings(LegalBasis[] bases) {
    return bases.map!toString.array;
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

    assert(["consent", "contract"].toLegalBases == [LegalBasis.consent, LegalBasis.contract]);

    assert(toString(LegalBasis.consent) == "consent");
    assert(toString(LegalBasis.contract) == "contract");
    assert(toString(LegalBasis.legalObligation) == "legalObligation");
    assert(toString(LegalBasis.vitalInterests) == "vitalInterests");
    assert(toString(LegalBasis.publicTask) == "publicTask");
    assert(toString(LegalBasis.legitimateInterests) == "legitimateInterests");

    assert(toStrings([LegalBasis.consent, LegalBasis.contract]) == ["consent", "contract"]);
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
AuditAction[] toAuditActions(string[] values) {
    return values.map!(toAuditAction).array;
}
string toString(AuditAction action) {
    return action.to!string;
}
string[] toStrings(AuditAction[] actions) {
    return actions.map!toString.array;
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

    assert(["register", "login"].toAuditActions == [AuditAction.register, AuditAction.login]);

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

    assert([AuditAction.register, AuditAction.login].toStrings == ["register", "login"]);
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
ResourceType[] toResourceTypes(string[] values) {
    return values.map!(toResourceType).array;
}
string toString(ResourceType type) {
    return type.to!string;
}
string[] toStrings(ResourceType[] types) {
    return types.map!toString.array;
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

    assert(["customer", "session"].toResourceTypes == [ResourceType.customer, ResourceType.session]);

    assert(ResourceType.customer.toString == "customer");
    assert(ResourceType.session.toString == "session");
    assert(ResourceType.socialIdentity.toString == "socialIdentity");
    assert(ResourceType.consentRecord.toString == "consentRecord");
    assert(ResourceType.identityProvider.toString == "identityProvider");
    assert(ResourceType.screenSet.toString == "screenSet");
    assert(ResourceType.sitePolicy.toString == "sitePolicy");

    assert([ResourceType.customer, ResourceType.session].toStrings == ["customer", "session"]);
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
IdentityProviderType[] toIdentityProviderTypes(string[] values) {
    return values.map!(toIdentityProviderType).array;
}
string toString(IdentityProviderType type) {
    return type.to!string;
}
string[] toStrings(IdentityProviderType[] types) {
    return types.map!toString.array;
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

    assert(["saml", "oidc"].toIdentityProviderTypes == [IdentityProviderType.saml, IdentityProviderType.oidc]);

    assert(IdentityProviderType.saml.toString == "saml");
    assert(IdentityProviderType.oidc.toString == "oidc");
    assert(IdentityProviderType.oauth2.toString == "oauth2");
    assert(IdentityProviderType.ldap.toString == "ldap");

    assert(toStrings([IdentityProviderType.saml, IdentityProviderType.oidc]) == ["saml", "oidc"]);
}

enum IdentityProviderStatus {
    active,
    inactive,
    testing
}
IdentityProviderStatus toIdentityProviderStatus(string value) {
    mixin(EnumSwitch!("IdentityProviderStatus", "active"));
}
IdentityProviderStatus[] toIdentityProviderStatuses(string[] values) {
    return values.map!(toIdentityProviderStatus).array;
}
string toString(IdentityProviderStatus status) {
    return status.to!string;
}
string[] toStrings(IdentityProviderStatus[] statuses) {
    return statuses.map!toString.array;
}
///
unittest {
    mixin(ShowTest!("IdentityProviderStatus"));

    assert("active".toIdentityProviderStatus == IdentityProviderStatus.active);
    assert("inactive".toIdentityProviderStatus == IdentityProviderStatus.inactive);
    assert("testing".toIdentityProviderStatus == IdentityProviderStatus.testing);

    assert("".toIdentityProviderStatus == IdentityProviderStatus.active);
    assert("unknown".toIdentityProviderStatus == IdentityProviderStatus.active);

    assert(["active", "testing"].toIdentityProviderStatuses == [IdentityProviderStatus.active, IdentityProviderStatus.testing]);

    assert(IdentityProviderStatus.active.toString == "active");
    assert(IdentityProviderStatus.inactive.toString == "inactive");
    assert(IdentityProviderStatus.testing.toString == "testing");

    assert([IdentityProviderStatus.active, IdentityProviderStatus.testing].toStrings == ["active", "testing"]);
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
ScreenSetFlowType[] toScreenSetFlowTypes(string[] values) {
    return values.map!(toScreenSetFlowType).array;
}
string toString(ScreenSetFlowType type) {
    return type.to!string;
}
string[] toStrings(ScreenSetFlowType[] types) {  
    return types.map!toString.array;
}   
///
unittest {
    mixin(ShowTest!("ScreenSetFlowType"));

    assert("registrationLogin".toScreenSetFlowType == ScreenSetFlowType.registrationLogin);
    assert("profileUpdate".toScreenSetFlowType == ScreenSetFlowType.profileUpdate);
    assert("forgotPassword".toScreenSetFlowType == ScreenSetFlowType.forgotPassword);
    assert("reAuthentication".toScreenSetFlowType == ScreenSetFlowType.reAuthentication);
    assert("linkAccount".toScreenSetFlowType == ScreenSetFlowType.linkAccount);
    assert("liteRegistration".toScreenSetFlowType == ScreenSetFlowType.liteRegistration);

    assert("".toScreenSetFlowType == ScreenSetFlowType.registrationLogin);
    assert("unknown".toScreenSetFlowType == ScreenSetFlowType.registrationLogin);

    assert(["registrationLogin", "forgotPassword"].toScreenSetFlowTypes == [ScreenSetFlowType.registrationLogin, ScreenSetFlowType.forgotPassword]);

    assert(ScreenSetFlowType.registrationLogin.toString == "registrationLogin");
    assert(ScreenSetFlowType.profileUpdate.toString == "profileUpdate");
    assert(ScreenSetFlowType.forgotPassword.toString == "forgotPassword");
    assert(ScreenSetFlowType.reAuthentication.toString == "reAuthentication");
    assert(ScreenSetFlowType.linkAccount.toString == "linkAccount");
    assert(ScreenSetFlowType.liteRegistration.toString == "liteRegistration");

    assert([ScreenSetFlowType.registrationLogin, ScreenSetFlowType.forgotPassword].toStrings == ["registrationLogin", "forgotPassword"]);
}

enum ScreenSetStatus {
    draft,
    active,
    archived
}
ScreenSetStatus toScreenSetStatus(string value) {
    mixin(EnumSwitch!("ScreenSetStatus", "draft"));
}
ScreenSetStatus[] toScreenSetStatuses(string[] values) {
    return values.map!(toScreenSetStatus).array;
}
string toString(ScreenSetStatus status) {
    return status.to!string;
}
string[] toStrings(ScreenSetStatus[] statuses) {
    return statuses.map!toString.array;
}
///
unittest {
    mixin(ShowTest!("ScreenSetStatus"));

    assert("draft".toScreenSetStatus == ScreenSetStatus.draft);
    assert("active".toScreenSetStatus == ScreenSetStatus.active);
    assert("archived".toScreenSetStatus == ScreenSetStatus.archived);

    assert("".toScreenSetStatus == ScreenSetStatus.draft);
    assert("unknown".toScreenSetStatus == ScreenSetStatus.draft);

    assert(["draft", "archived"].toScreenSetStatuses == [ScreenSetStatus.draft, ScreenSetStatus.archived]);

    assert(toString(ScreenSetStatus.draft) == "draft");
    assert(toString(ScreenSetStatus.active) == "active");
    assert(toString(ScreenSetStatus.archived) == "archived");

    assert(toStrings([ScreenSetStatus.draft, ScreenSetStatus.archived]) == ["draft", "archived"]);
}

enum PolicyType {
    password,
    session,
    registration,
    login,
    mfa,
    consent
}
PolicyType toPolicyType(string value) {
    mixin(EnumSwitch!("PolicyType", "password"));
}
PolicyType[] toPolicyTypes(string[] values) {
    return values.map!(toPolicyType).array;
}
string toString(PolicyType type) {
    return type.to!string;
}
string[] toStrings(PolicyType[] types) {
    return types.map!toString.array;
}
///
unittest {
    mixin(ShowTest!("PolicyType"));

    assert(toPolicyType("password") == PolicyType.password);
    assert(toPolicyType("session") == PolicyType.session);
    assert(toPolicyType("registration") == PolicyType.registration);
    assert(toPolicyType("login") == PolicyType.login);
    assert(toPolicyType("mfa") == PolicyType.mfa);
    assert(toPolicyType("consent") == PolicyType.consent);

    assert(toPolicyType("") == PolicyType.password);
    assert(toPolicyType("unknown") == PolicyType.password);

    assert(["password", "mfa"].toPolicyTypes == [PolicyType.password, PolicyType.mfa]);

    assert(PolicyType.password.toString == "password");
    assert(PolicyType.session.toString == "session");
    assert(PolicyType.registration.toString == "registration");
    assert(PolicyType.login.toString == "login");
    assert(PolicyType.mfa.toString == "mfa");
    assert(PolicyType.consent.toString == "consent");

    assert(toStrings([PolicyType.password, PolicyType.mfa]) == ["password", "mfa"]);
}   

enum MfaMethod {
    none,
    email,
    sms,
    totp,
    push
}

MfaMethod toMfaMethod(string value) {
    mixin(EnumSwitch!("MfaMethod", "none"));
}
MfaMethod[] toMfaMethods(string[] values) {
    return values.map!(toMfaMethod).array;
}
string toString(MfaMethod method) {
    return method.to!string;
}
string[] toStrings(MfaMethod[] methods) {
    return methods.map!toString.array;
}
///
unittest {
    mixin(ShowTest!("MfaMethod"));

    assert(toMfaMethod("none") == MfaMethod.none);
    assert(toMfaMethod("email") == MfaMethod.email);
    assert(toMfaMethod("sms") == MfaMethod.sms);
    assert(toMfaMethod("totp") == MfaMethod.totp);
    assert(toMfaMethod("push") == MfaMethod.push);

    assert(toMfaMethod("") == MfaMethod.none);
    assert(toMfaMethod("unknown") == MfaMethod.none);

    assert(["none", "email"].toMfaMethods == [MfaMethod.none, MfaMethod.email]);

    assert(toString(MfaMethod.none) == "none");
    assert(toString(MfaMethod.email) == "email");
    assert(toString(MfaMethod.sms) == "sms");
    assert(toString(MfaMethod.totp) == "totp");
    assert(toString(MfaMethod.push) == "push"); 

    assert(toStrings([MfaMethod.none, MfaMethod.email]) == ["none", "email"]);
}

enum PasswordComplexity {
    low,
    medium,
    high,
    custom
}
PasswordComplexity toPasswordComplexity(string value) {
    mixin(EnumSwitch!("PasswordComplexity", "low"));
}
PasswordComplexity[] toPasswordComplexities(string[] values) {
    return values.map!(toPasswordComplexity).array;
}
string toString(PasswordComplexity complexity) {
    return complexity.to!string;
}
string[] toStrings(PasswordComplexity[] complexities) {
    return complexities.map!toString.array;
}
///
unittest {
    mixin(ShowTest!("PasswordComplexity")); 

    assert(toPasswordComplexity("low") == PasswordComplexity.low);
    assert(toPasswordComplexity("medium") == PasswordComplexity.medium);
    assert(toPasswordComplexity("high") == PasswordComplexity.high);
    assert(toPasswordComplexity("custom") == PasswordComplexity.custom);    

    assert(toPasswordComplexity("") == PasswordComplexity.low);
    assert(toPasswordComplexity("unknown") == PasswordComplexity.low);

    assert(["low", "high"].toPasswordComplexities == [PasswordComplexity.low, PasswordComplexity.high]);    

    assert(toString(PasswordComplexity.low) == "low");
    assert(toString(PasswordComplexity.medium) == "medium");
    assert(toString(PasswordComplexity.high) == "high");
    assert(toString(PasswordComplexity.custom) == "custom");

    assert(toStrings([PasswordComplexity.low, PasswordComplexity.high]) == ["low", "high"]);
}