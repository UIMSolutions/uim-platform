/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Domain enumerations for the Identity Service.
module uim.platform.identity.domain.enumerations;

import uim.platform.identity;

mixin(ShowModule!());

@safe:

/// Status of an identity user.
enum UserStatus : string {
    active    = "active",
    inactive  = "inactive",
    locked    = "locked",
    shadow    = "shadow"
}
UserStatus toUserStatus(string value) {
    mixin(EnumSwitch("UserStatus", "active"));
}
UserStatus[] toUserStatuses(string[] statuses) 
    => statuses.map!toUserStatus.array;

string toString(UserStatus status)
    => status.to!string;

string[] toStrings(UserStatus[] statuses)
    => statuses.map!toString.array;
/// 
unittest {
    mixin(ShowTest!("UserStatus"));

    assert("active".toUserStatus == UserStatus.active);
    assert("inactive".toUserStatus == UserStatus.inactive);
    assert("locked".toUserStatus == UserStatus.locked);
    assert("shadow".toUserStatus == UserStatus.shadow);

    assert(UserStatus.active.toString == "active");
    assert(UserStatus.inactive.toString == "inactive");
    assert(UserStatus.locked.toString == "locked");
    assert(UserStatus.shadow.toString == "shadow");

    assert([UserStatus.active, UserStatus.inactive].toStrings == ["active", "inactive"]);
    assert(["active", "inactive"].toUserStatuses == [UserStatus.active, UserStatus.inactive]);
}

/// Type / persona of a user.
enum UserType : string {
    employee  = "employee",
    partner   = "partner",
    customer  = "customer",
    public_   = "public",
    onboardee = "onboardee",
    external  = "external"
}

UserType toUserType(string value) {
    mixin(EnumSwitch("UserType", "employee"));
}

UserType[] toUserTypes(string[] types)
    => types.map!toUserType.array;

string toString(UserType type)
    => type.to!string;

string[] toStrings(UserType[] types)
    => types.map!toString.array;
/// 
unittest {
    mixin(ShowTest!("UserType"));

    assert("employee".toUserType == UserType.employee);
    assert("partner".toUserType == UserType.partner);
    assert("customer".toUserType == UserType.customer);
    assert("public".toUserType == UserType.public_);
    assert("onboardee".toUserType == UserType.onboardee);
    assert("external".toUserType == UserType.external);

    assert(UserType.employee.toString == "employee");
    assert(UserType.partner.toString == "partner");
    assert(UserType.customer.toString == "customer");
    assert(UserType.public_.toString == "public");
    assert(UserType.onboardee.toString == "onboardee");
    assert(UserType.external.toString == "external");

    assert([UserType.employee, UserType.partner].toStrings == ["employee", "partner"]);
    assert(["employee", "partner"].toUserTypes == [UserType.employee, UserType.partner]);
}

/// Type of a group.
enum GroupType : string {
    userGroup     = "userGroup",
    authorization = "authorization"
}
GroupType toGroupType(string value) {
    mixin(EnumSwitch("GroupType", "userGroup"));
}
GroupType[] toGroupTypes(string[] types)
    => types.map!toGroupType.array;

string toString(GroupType type)
    => type.to!string;

string[] toStrings(GroupType[] types)
    => types.map!toString.array;
///
unittest {
    mixin(ShowTest!("GroupType"));

    assert("userGroup".toGroupType == GroupType.userGroup);
    assert("authorization".toGroupType == GroupType.authorization);

    assert(GroupType.userGroup.toString == "userGroup");
    assert(GroupType.authorization.toString == "authorization");

    assert([GroupType.userGroup, GroupType.authorization].toStrings == ["userGroup", "authorization"]);
    assert(["userGroup", "authorization"].toGroupTypes == [GroupType.userGroup, GroupType.authorization]);
}

/// Protocol supported by a registered application.
enum AppProtocol : string {
    oidc = "oidc",
    saml = "saml"
}
AppProtocol toAppProtocol(string value) {
    mixin(EnumSwitch("AppProtocol", "oidc"));
}
AppProtocol[] toAppProtocols(string[] protocols)
    => protocols.map!toAppProtocol.array;

string toString(AppProtocol protocol)
    => protocol.to!string;

string[] toStrings(AppProtocol[] protocols)
    => protocols.map!toString.array;
/// 
unittest {
    mixin(ShowTest!("AppProtocol"));

    assert("oidc".toAppProtocol == AppProtocol.oidc);
    assert("saml".toAppProtocol == AppProtocol.saml);

    assert(AppProtocol.oidc.toString == "oidc");
    assert(AppProtocol.saml.toString == "saml");

    assert([AppProtocol.oidc, AppProtocol.saml].toStrings == ["oidc", "saml"]);
    assert(["oidc", "saml"].toAppProtocols == [AppProtocol.oidc, AppProtocol.saml]);
}

/// Application status.
enum AppStatus : string {
    active   = "active",
    inactive = "inactive"
}
AppStatus toAppStatus(string value) {
    mixin(EnumSwitch("AppStatus", "active"));
}
AppStatus[] toAppStatuses(string[] statuses)
    => statuses.map!toAppStatus.array;
string toString(AppStatus status)
    => status.to!string;
string[] toStrings(AppStatus[] statuses)
    => statuses.map!toString.array;
/// 
unittest {
    mixin(ShowTest!("AppStatus"));

    assert("active".toAppStatus == AppStatus.active);
    assert("inactive".toAppStatus == AppStatus.inactive);

    assert(AppStatus.active.toString == "active");
    assert(AppStatus.inactive.toString == "inactive");

    assert([AppStatus.active, AppStatus.inactive].toStrings == ["active", "inactive"]);
    assert(["active", "inactive"].toAppStatuses == [AppStatus.active, AppStatus.inactive]);
}

/// Type of external Identity Provider.
enum IdpType : string {
    oidc      = "oidc",
    saml      = "saml",
    corporate = "corporate"
}
IdpType toIdpType(string value) {
    mixin(EnumSwitch("IdpType", "oidc"));
}
IdpType[] toIdpTypes(string[] types)
    => types.map!toIdpType.array;

string toString(IdpType type)
    => type.to!string;

string[] toStrings(IdpType[] types)
    => types.map!toString.array;
/// 
unittest {
    mixin(ShowTest!("IdpType"));

    assert("oidc".toIdpType == IdpType.oidc);
    assert("saml".toIdpType == IdpType.saml);
    assert("corporate".toIdpType == IdpType.corporate);

    assert(IdpType.oidc.toString == "oidc");
    assert(IdpType.saml.toString == "saml");
    assert(IdpType.corporate.toString == "corporate");

    assert([IdpType.oidc, IdpType.saml].toStrings == ["oidc", "saml"]);
    assert(["oidc", "saml"].toIdpTypes == [IdpType.oidc, IdpType.saml]);
}

/// Status of an external Identity Provider.
enum IdpStatus : string {
    active   = "active",
    inactive = "inactive"
} 
IdpStatus toIdpStatus(string value) {
    mixin(EnumSwitch("IdpStatus", "active"));
}
IdpStatus[] toIdpStatuses(string[] statuses)
    => statuses.map!toIdpStatus.array;
string toString(IdpStatus status)
    => status.to!string;
string[] toStrings(IdpStatus[] statuses)
    => statuses.map!toString.array;
/// 
unittest {
    mixin(ShowTest!("IdpStatus"));

    assert("active".toIdpStatus == IdpStatus.active);
    assert("inactive".toIdpStatus == IdpStatus.inactive);

    assert(IdpStatus.active.toString == "active");
    assert(IdpStatus.inactive.toString == "inactive");

    assert([IdpStatus.active, IdpStatus.inactive].toStrings == ["active", "inactive"]);
    assert(["active", "inactive"].toIdpStatuses == [IdpStatus.active, IdpStatus.inactive]);
}

/// Provisioning job type (IPS).
enum JobType : string {
    read   = "read",
    write  = "write",
    resync = "resync"
}
JobType toJobType(string value) {
    mixin(EnumSwitch("JobType", "read"));
}
JobType[] toJobTypes(string[] types)
    => types.map!toJobType.array;
string toString(JobType type)
    => type.to!string;
string[] toStrings(JobType[] types)
    => types.map!toString.array;

/// Provisioning job lifecycle status.
enum JobStatus : string {
    pending   = "pending",
    running   = "running",
    success   = "success",
    failed    = "failed",
    cancelled = "cancelled"
}
JobStatus toJobStatus(string value) {
    mixin(EnumSwitch("JobStatus", "pending"));
}
JobStatus[] toJobStatuses(string[] statuses)
    => statuses.map!toJobStatus.array;
string toString(JobStatus status)
    => status.to!string;
string[] toStrings(JobStatus[] statuses)
    => statuses.map!toString.array;
/// 
unittest {
    mixin(ShowTest!("JobStatus"));

    assert("pending".toJobStatus == JobStatus.pending);
    assert("running".toJobStatus == JobStatus.running);
    assert("success".toJobStatus == JobStatus.success);
    assert("failed".toJobStatus == JobStatus.failed);
    assert("cancelled".toJobStatus == JobStatus.cancelled);

    assert(JobStatus.pending.toString == "pending");
    assert(JobStatus.running.toString == "running");
    assert(JobStatus.success.toString == "success");
    assert(JobStatus.failed.toString == "failed");
    assert(JobStatus.cancelled.toString == "cancelled");

    assert([JobStatus.pending, JobStatus.running].toStrings == ["pending", "running"]);
    assert(["pending", "running"].toJobStatuses == [JobStatus.pending, JobStatus.running]);
}

/// Authentication scheme for applications.
enum AuthScheme : string {
    form    = "form",
    basic   = "basic",
    cert    = "cert",
    token   = "token",
    spnego  = "spnego",
    noAuth  = "noAuth"
}
AuthScheme toAuthScheme(string value) {
    mixin(EnumSwitch("AuthScheme", "form"));
}
AuthScheme[] toAuthSchemes(string[] schemes)
    => schemes.map!toAuthScheme.array;
string toString(AuthScheme scheme)
    => scheme.to!string;
string[] toStrings(AuthScheme[] schemes)    
    => schemes.map!toString.array;
unittest {
    mixin(ShowTest!("AuthScheme"));

    assert("form".toAuthScheme == AuthScheme.form);
    assert("basic".toAuthScheme == AuthScheme.basic);
    assert("cert".toAuthScheme == AuthScheme.cert);
    assert("token".toAuthScheme == AuthScheme.token);
    assert("spnego".toAuthScheme == AuthScheme.spnego);
    assert("noAuth".toAuthScheme == AuthScheme.noAuth);

    assert(AuthScheme.form.toString == "form");
    assert(AuthScheme.basic.toString == "basic");
    assert(AuthScheme.cert.toString == "cert");
    assert(AuthScheme.token.toString == "token");
    assert(AuthScheme.spnego.toString == "spnego");
    assert(AuthScheme.noAuth.toString == "noAuth");

    assert([AuthScheme.form, AuthScheme.basic].toStrings == ["form", "basic"]);
    assert(["form", "basic"].toAuthSchemes == [AuthScheme.form, AuthScheme.basic]);
}

/// Persistence backend selection.
enum PersistenceBackend : string{
    memory = "memory",
    file_ = "file_",
    mongodb = "mongodb"
}
PersistenceBackend toPersistenceBackend(string value) {
    switch(value.toLower()) {
        case "memory": return PersistenceBackend.memory;
        case "file": return PersistenceBackend.file_;
        case "mongodb": return PersistenceBackend.mongodb;
        default: return PersistenceBackend.memory;
    }
}
PersistenceBackend[] toPersistenceBackends(string[] backends)
    => backends.map!toPersistenceBackend.array;
string toString(PersistenceBackend backend)
    => backend.to!string;
string[] toStrings(PersistenceBackend[] backends)
    => backends.map!toString.array; 
///
unittest {
    mixin(ShowTest!("PersistenceBackend"));

    assert("memory".toPersistenceBackend == PersistenceBackend.memory);
    assert("file".toPersistenceBackend == PersistenceBackend.file_);
    assert("mongodb".toPersistenceBackend == PersistenceBackend.mongodb);

    assert(PersistenceBackend.memory.toString == "memory");
    assert(PersistenceBackend.file_.toString == "file_");
    assert(PersistenceBackend.mongodb.toString == "mongodb");

    assert([PersistenceBackend.memory, PersistenceBackend.file_].toStrings == ["memory", "file_"]);
    assert(["memory", "file"].toPersistenceBackends == [PersistenceBackend.memory, PersistenceBackend.file_]);
}
