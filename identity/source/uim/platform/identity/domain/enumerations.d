/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Domain enumerations for the Identity Service.
module uim.platform.identity.domain.enumerations;

import uim.platform.identity;

// mixin(ShowModule!());

@safe:

/// Status of an identity user.
enum UserStatus : string {
    active    = "active",
    inactive  = "inactive",
    locked    = "locked",
    shadow    = "shadow"
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

/// Type of a group.
enum GroupType : string {
    userGroup     = "userGroup",
    authorization = "authorization"
}

/// Protocol supported by a registered application.
enum AppProtocol : string {
    oidc = "oidc",
    saml = "saml"
}

/// Application status.
enum AppStatus : string {
    active   = "active",
    inactive = "inactive"
}

/// Type of external Identity Provider.
enum IdpType : string {
    oidc      = "oidc",
    saml      = "saml",
    corporate = "corporate"
}

/// Status of an external Identity Provider.
enum IdpStatus : string {
    active   = "active",
    inactive = "inactive"
}

/// Provisioning job type (IPS).
enum JobType : string {
    read   = "read",
    write  = "write",
    resync = "resync"
}

/// Provisioning job lifecycle status.
enum JobStatus : string {
    pending   = "pending",
    running   = "running",
    success   = "success",
    failed    = "failed",
    cancelled = "cancelled"
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

/// Persistence backend selection.
enum PersistenceBackend {
    memory,
    file_,
    mongodb
}
