/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.keystore.domain.enumerations;

import uim.platform.keystore;

// mixin(ShowModule!());

@safe:

// Keystore format
enum KeystoreFormat {
  jks,
  jceks,
  p12,
  pem,
}
KeystoreFormat toKeystoreFormat(string s) @safe {
  import std.uni : toLower;

  switch (s.toLower()) {
  case "jceks":
    return KeystoreFormat.jceks;
  case "p12":
    return KeystoreFormat.p12;
  case "pem":
    return KeystoreFormat.pem;
  default:
    return KeystoreFormat.jks;
  }
}
// Keystore scope level (search order: subscription > application > account)
enum KeystoreLevel {
  account,
  application,
  subscription,
}
KeystoreLevel toKeystoreLevel(string s) @safe {
  import std.uni : toLower;

  switch (s.toLower()) {
  case "application":
    return KeystoreLevel.application;
  case "subscription":
    return KeystoreLevel.subscription;
  default:
    return KeystoreLevel.account;
  }
}
// Type of entry within a keystore
enum KeyEntryType {
  trustedCertificate,
  privateKey,
  certificate,
  secretKey,
}
KeyEntryType toKeyEntryType(string s) @safe {
  import std.uni : toLower;

  switch (s.toLower()) {
  case "privatekey":
    return KeyEntryType.privateKey;
  case "certificate":
    return KeyEntryType.certificate;
  case "secretkey":
    return KeyEntryType.secretKey;
  default:
    return KeyEntryType.trustedCertificate;
  }
}
