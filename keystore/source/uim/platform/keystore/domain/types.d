/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.keystore.domain.types;

import uim.platform.keystore;

mixin(ShowModule!());

@safe:
// ID types
struct KeystoreId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}
struct KeyEntryId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}
struct KeyPasswordId {
  string value;

  this(string value) {
    this.value = value;
  }

  mixin DomainId;
}


// Keystore format
enum KeystoreFormat {
  jks,
  jceks,
  p12,
  pem,
}
// Keystore scope level (search order: subscription > application > account)
enum KeystoreLevel {
  account,
  application,
  subscription,
}
// Type of entry within a keystore
enum KeyEntryType {
  trustedCertificate,
  privateKey,
  certificate,
  secretKey,
}
// Helper: parse KeystoreFormat from string
KeystoreFormat parseKeystoreFormat(string s) @safe {
  import std.uni : toLower;

  switch (s.toLower) {
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
// Helper: format KeystoreFormat to string
string keystoreFormatToString(KeystoreFormat f) @safe {
  final switch (f) {
  case KeystoreFormat.jks:
    return "jks";
  case KeystoreFormat.jceks:
    return "jceks";
  case KeystoreFormat.p12:
    return "p12";
  case KeystoreFormat.pem:
    return "pem";
  }
}
// Helper: parse KeystoreLevel from string
KeystoreLevel parseKeystoreLevel(string s) @safe {
  import std.uni : toLower;

  switch (s.toLower) {
  case "application":
    return KeystoreLevel.application;
  case "subscription":
    return KeystoreLevel.subscription;
  default:
    return KeystoreLevel.account;
  }
}
