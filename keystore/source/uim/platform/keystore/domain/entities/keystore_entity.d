/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.keystore.domain.entities.keystore_entity;

import uim.platform.keystore.domain.types;

@safe:

/// A named keystore file containing cryptographic keys and/or certificates.
/// Corresponds to JKS, JCEKS, P12 or PEM file uploaded to SAP BTP Keystore Service.
struct KeystoreEntity {
  KeystoreId    id;
  string        name;           // unique per (accountId, applicationId, level)
  string        description;
  KeystoreFormat format;        // jks | jceks | p12 | pem
  KeystoreLevel  level;         // account | application | subscription
  string        content;        // base64-encoded binary content of the keystore file
  string        accountId;
  string        applicationId;  // empty for account-level keystores
  string        subscriptionId; // non-empty only for subscription-level
  string        createdBy;
  string        updatedBy;
  long          createdAt;
  long          updatedAt;
}
