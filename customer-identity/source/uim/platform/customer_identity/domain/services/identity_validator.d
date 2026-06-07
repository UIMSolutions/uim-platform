/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.customer_identity.domain.services.identity_validator;

import uim.platform.customer_identity;

// mixin(ShowModule!());

@safe:

struct IdentityValidator {
    static bool isValidCustomer(Customer c) {
        return c.tenantId.value.length > 0 && c.email.length > 0;
    }

    static bool isValidEmail(string email) {
        import std.string : indexOf;
        return email.length > 3 && email.indexOf('@') > 0;
    }

    static bool isValidPassword(string password, int minLength = 8) {
        return password.length >= minLength;
    }

    static bool isValidSession(CustomerSession s) {
        return s.tenantId.value.length > 0 && s.customerId.value.length > 0 && s.token.length > 0;
    }

    static bool isValidSocialIdentity(SocialIdentity si) {
        return si.tenantId.value.length > 0 && si.customerId.value.length > 0 && si.providerUserId.length > 0;
    }

    static bool isValidConsentRecord(ConsentRecord cr) {
        return cr.tenantId.value.length > 0 && cr.customerId.value.length > 0;
    }

    static bool isValidAuditLog(AuditLog al) {
        return al.tenantId.value.length > 0 && al.actorId.length > 0;
    }

    static bool isValidIdentityProvider(IdentityProvider ip) {
        return ip.tenantId.value.length > 0 && ip.name.length > 0 && ip.clientId.length > 0;
    }

    static bool isValidScreenSet(ScreenSet ss) {
        return ss.tenantId.value.length > 0 && ss.name.length > 0;
    }

    static bool isValidSitePolicy(SitePolicy sp) {
        return sp.tenantId.value.length > 0 && sp.name.length > 0;
    }
}
