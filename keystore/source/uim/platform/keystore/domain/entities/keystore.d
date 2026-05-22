/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.keystore.domain.entities.keystore;

import uim.platform.keystore;

mixin(ShowModule!());

@safe:
/// A named keystore file containing cryptographic keys and/or certificates.
/// Corresponds to JKS, JCEKS, P12 or PEM file uploaded to SAP BTP Keystore Service.
struct Keystore {
  mixin TenantEntity!KeystoreId;

  string name; // unique per (accountId, applicationId, level)
  string description;
  KeystoreFormat format; // jks | jceks | p12 | pem
  KeystoreLevel level; // account | application | subscription
  string content; // base64-encoded binary content of the keystore file
  string accountId;
  string applicationId; // empty for account-level keystores
  string subscriptionId; // non-empty only for subscription-level

  Json toJson() const {
    return entityToJson
      .set("name", name)
      .set("description", description)
      .set("format", format.to!string)
      .set("level", level.to!string)
      .set("accountId", accountId)
      .set("applicationId", applicationId)
      .set("subscriptionId", subscriptionId);
  }
}
