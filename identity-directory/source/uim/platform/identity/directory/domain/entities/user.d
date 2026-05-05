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

  Json toJson() const {
    return Json.emptyObject
      .set("formatted", formatted)
      .set("familyName", familyName)
      .set("givenName", givenName)
      .set("middleName", middleName)
      .set("honorificPrefix", honorificPrefix)
      .set("honorificSuffix", honorificSuffix);
  }
}

/// SCIM 2.0 email entry.
struct Email {
  string value;
  string type; // "work", "home", "other"
  bool primary;

  Json toJson() const {
    return Json.emptyObject
      .set("value", value)
      .set("type", type)
      .set("primary", primary);
  }
}

/// SCIM 2.0 phone number entry.
struct PhoneNumber {
  string value;
  string type; // "work", "mobile", "fax", "other"
  bool primary;

  Json toJson() const {
    return Json.emptyObject
      .set("value", value)
      .set("type", type)
      .set("primary", primary);
  }
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

  Json toJson() const {
    return Json.emptyObject
      .set("formatted", formatted)
      .set("streetAddress", streetAddress)
      .set("locality", locality)
      .set("region", region)
      .set("postalCode", postalCode)
      .set("country", country)
      .set("type", type)
      .set("primary", primary);
  }
}

/// Extended attributes stored as key-value pairs (custom schema extensions).
struct ExtendedAttribute {
  string schemaId;
  string attributeName;
  string value;

  Json toJson() const {
    return Json.emptyObject
      .set("schemaId", schemaId)
      .set("attributeName", attributeName)
      .set("value", value);
  }
}

/// Core user entity — SCIM 2.0 compliant.
struct User {
  mixin TenantEntity!UserId;

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

  Json toJson() const {
    auto emailsJson = emails.map!(e => e.toJson()).array;

    auto phonesJson = phoneNumbers.map!(p => p.toJson()).array;

    auto addressesJson = addresses.map!(a => a.toJson()).array;

    auto extendedAttrsJson = extendedAttributes.map!(ea => ea.toJson()).array;

    return entityToJson
      .set("externalId", externalId)
      .set("userName", userName)
      .set("name", Json.emptyObject
        .set("formatted", name.formatted)
        .set("familyName", name.familyName)
        .set("givenName", name.givenName)
        .set("middleName", name.middleName)
        .set("honorificPrefix", name.honorificPrefix)
        .set("honorificSuffix", name.honorificSuffix))
      .set("displayName", displayName)
      .set("nickName", nickName)
      .set("profileUrl", profileUrl)
      .set("userType", userType)
      .set("title", title)
      .set("preferredLanguage", preferredLanguage)
      .set("locale", locale)
      .set("timezone", timezone)
      .set("active", active)
      .set("status", status.to!string())
      // Note: passwordHash is intentionally excluded from JSON representation for security reasons
      .set("emails", emailsJson)
      .set("phoneNumbers", phonesJson)
      .set("addresses", addressesJson)
      .set("groupIds", groupIds)
      .set("extendedAttributes", extendedAttrsJson)
      .set("schemas", schemas); 
  }
}
