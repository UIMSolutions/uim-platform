/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Identity User entity — core identity directory record.
module uim.platform.identity.domain.entities.user;

import uim.platform.identity;

mixin(ShowModule!());

@safe:

struct User {
    mixin TenantEntity!(UserId);

    string userName;         // Unique login name
    string email;
    string displayName;
    string firstName;
    string lastName;
    string phoneNumber;
    string language;         // Preferred language, e.g. "en"
    string locale;           // e.g. "en_US"
    string timeZone;
    UserStatus status = UserStatus.active;
    UserType type_ = UserType.employee;
    string[] groups;         // Group IDs this user belongs to
    string[] roles;          // Role/authorization strings
    string passwordHash;     // Stored hashed password (never returned in API)
    long lastLoginAt;
    long passwordChangedAt;

    Json toJson() const {
        auto j = entityToJson
            .set("userName", userName)
            .set("email", email)
            .set("displayName", displayName)
            .set("firstName", firstName)
            .set("lastName", lastName)
            .set("phoneNumber", phoneNumber)
            .set("language", language)
            .set("locale", locale)
            .set("timeZone", timeZone)
            .set("status", status.to!string)
            .set("type", type_.to!string)
            .set("lastLoginAt", lastLoginAt)
            .set("passwordChangedAt", passwordChangedAt);
        // Expose group membership but never passwordHash
        auto grpArr = Json.emptyArray;
        foreach (g; groups) grpArr ~= Json(g);
        j["groups"] = grpArr;
        return j;
    }
}
