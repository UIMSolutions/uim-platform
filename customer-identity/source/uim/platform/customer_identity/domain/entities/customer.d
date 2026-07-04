/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.customer_identity.domain.entities.customer;

import uim.platform.customer_identity;

mixin(ShowModule!());

@safe:

struct Customer {
    mixin TenantEntity!(CustomerId);

    string email;
    string phone;
    string firstName;
    string lastName;
    string passwordHash;
    CustomerStatus status = CustomerStatus.pending;
    LoginProvider loginProvider = LoginProvider.site;
    string locale;
    string country;
    string birthDate;
    CustomerGender gender = CustomerGender.unspecified;
    string profileData;
    string progressiveData;
    bool emailVerified;
    bool phoneVerified;
    long lastLoginAt;
    string lastLoginIp;

    Json toJson() const {
        return entityToJson
            .set("email", email)
            .set("phone", phone)
            .set("firstName", firstName)
            .set("lastName", lastName)
            .set("status", status.to!string)
            .set("loginProvider", loginProvider.to!string)
            .set("locale", locale)
            .set("country", country)
            .set("birthDate", birthDate)
            .set("gender", gender.to!string)
            .set("profileData", profileData)
            .set("progressiveData", progressiveData)
            .set("emailVerified", emailVerified)
            .set("phoneVerified", phoneVerified)
            .set("lastLoginAt", lastLoginAt)
            .set("lastLoginIp", lastLoginIp);
    }
}
