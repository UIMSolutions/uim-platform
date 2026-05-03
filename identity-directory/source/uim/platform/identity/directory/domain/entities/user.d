/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity.directory.domain.entities.user;

// import uim.platform.identity.directory.domain.types;
import uim.platform.identity.directory;

mixin(ShowModule!());

@safe:
/// SCIM 2.0 user name component.
struct UserName {
  string formatted;
  string familyName;
  string givenName;
  string middleName;
  string honorificPrefix;
  string honorificSuffix;
}

/// SCIM 2.0 email entry.
struct Email {
  string value;
  string type; // "work", "home", "other"
  bool primary;
}

/// SCIM 2.0 phone number entry.
struct PhoneNumber {
  string value;
  string type; // "work", "mobile", "fax", "other"
  bool primary;
}

/// SCIM 2.0 address entry.
struct Address {
  string formatted;
  string streetAddress;
  string locality;
  string region;
  string postalCode;
  string country;
  string type; // "work", "home"
  bool primary;
}

/// Extended attributes stored as key-value pairs (custom schema extensions).
struct ExtendedAttribute {
  string schemaId;
  string attributeName;
  string value;
}

/// Core user entity — SCIM 2.0 compliant.
struct User {
  UserId id;
  TenantId tenantId;
  string externalId;
  string userName;
  UserName name;
  string displayName;
  string nickName;
  string profileUrl;
  string userType; // "employee", "partner", "customer", "public"
  string title;
  string preferredLanguage;
  string locale;
  string timezone;
  bool active = true;
  UserStatus status = UserStatus.active;
  string passwordHash;
  Email[] emails;
  PhoneNumber[] phoneNumbers;
  Address[] addresses;
  string[] groupIds;
  ExtendedAttribute[] extendedAttributes;
  string[] schemas; // SCIM schema URNs
  long createdAt;
  long updatedAt;

  /// SCIM displayName or formatted name.
  string getDisplayName() const {
    if (displayName.length > 0)
      return displayName;
    if (name.formatted.length > 0)
      return name.formatted;
    return name.givenName ~ " " ~ name.familyName;
  }

  bool isActive() const {
    return status == UserStatus.active && active;
  }

  /// Primary email address.
  string primaryEmail() const {
    foreach (e; emails) {
      if (e.primary)
        return e.value;
    }
    return emails.length > 0 ? emails[0].value : "";
  }

  Json toJson() {
    auto nameJson = Json.emptyObject
      .set("formatted", name.formatted)
      .set("familyName", name.familyName)
      .set("givenName", name.givenName)
      .set("middleName", name.middleName)
      .set("honorificPrefix", name.honorificPrefix)
      .set("honorificSuffix", name.honorificSuffix);

    auto j = Json.emptyObject
      .set("id", id)
      .set("externalId", externalId)
      .set("userName", userName)
      .set("displayName", getDisplayName())
      .set("userType", userType)
      .set("active", isActive())
      .set("preferredLanguage", preferredLanguage)
      .set("locale", locale)
      .set("timezone", timezone);

    // Name
    j["name"] = nameJson;

    // Emails
    j["emails"] = toJsonArray(emails);

    // Phone numbers
    j["phoneNumbers"] = toJsonArray(phoneNumbers);

    // Groups
    auto groups = Json.emptyArray;
    foreach (gid; groupIds) {
      auto g = Json.emptyObject;
      g["value"] = Json(gid);
      groups ~= g;
    }
    j["groups"] = groups;

    // Schemas
    auto schemas = Json.emptyArray;
    schemas ~= Json("urn:ietf:params:scim:schemas:core:2.0:User");
    foreach (s; schemas)
      schemas ~= Json(s);
    j["schemas"] = schemas;

    // Meta
    auto meta = Json.emptyObject;
    meta["resourceType"] = Json("User");
    meta["created"] = Json(createdAt);
    meta["lastModified"] = Json(updatedAt);
    j["meta"] = meta;

    return j;
  }
}

Json serializeUsers(User[] users) {
  return users.map!(u => u).array.toJson;
}
