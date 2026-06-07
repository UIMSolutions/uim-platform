/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.datasphere_composer.domain.entities.customer_profile;

import uim.platform.datasphere_composer;

// mixin(ShowModule!());

@safe:

/// Unified/harmonized customer profile produced by the composition pipeline.
struct CustomerProfile {
  mixin TenantEntity!(CustomerProfileId);

  string externalId;         /// Identifier from source system
  string firstName;
  string lastName;
  string fullName;
  string email;
  string phone;
  string street;
  string city;
  string postalCode;
  string country;
  string countryCode;
  string[] sourceProductIds; /// Which data products contributed to this profile
  long mergedProfileCount;   /// Number of source records merged
  long lastModifiedAt;
  string[string] attributes; /// Additional harmonized attributes

  Json toJson() const {
    auto srcArr = Json.emptyArray;
    foreach (s; sourceProductIds) srcArr ~= Json(s);

    return entityToJson()
      .set("externalId", externalId)
      .set("firstName", firstName)
      .set("lastName", lastName)
      .set("fullName", fullName)
      .set("email", email)
      .set("phone", phone)
      .set("street", street)
      .set("city", city)
      .set("postalCode", postalCode)
      .set("country", country)
      .set("countryCode", countryCode)
      .set("sourceProductIds", srcArr)
      .set("mergedProfileCount", mergedProfileCount)
      .set("lastModifiedAt", lastModifiedAt);
  }
}
