/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Domain validation service for identity entities.
module uim.platform.identity.domain.services.identity_validator;

import uim.platform.identity;

// mixin(ShowModule!());

@safe:

class IdentityValidator {
    static bool isValidUser(const User u) {
        return u.userName.length > 0 && u.email.length > 0;
    }

    static bool isValidGroup(const IDMGroup g) {
        return g.name.length > 0;
    }

    static bool isValidApplication(const Application a) {
        return a.name.length > 0 && a.clientId.length > 0;
    }

    static bool isValidIdentityProvider(const IdentityProvider idp) {
        return idp.name.length > 0 && idp.entityId.length > 0;
    }

    static bool isValidProvisioningJob(const ProvisioningJob j) {
        return j.sourceSystem.length > 0 && j.targetSystem.length > 0;
    }

    static bool isValidEmail(string email) {
        import std.string : indexOf;
        return email.length > 3 && email.indexOf('@') > 0;
    }
}
