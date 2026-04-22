/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.keystore.domain.types;

// ID types
alias KeystoreId = string;
alias KeyEntryId  = string;
alias KeyPasswordId = string;

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
  privateKey,
  certificate,
  secretKey,
  trustedCertificate,
}

// Helper: parse KeystoreFormat from string
KeystoreFormat parseKeystoreFormat(string s) @safe {
  import std.uni : toLower;
  switch (s.toLower) {
    case "jceks": return KeystoreFormat.jceks;
    case "p12":   return KeystoreFormat.p12;
    case "pem":   return KeystoreFormat.pem;
    default:      return KeystoreFormat.jks;
  }
}

// Helper: format KeystoreFormat to string
string keystoreFormatToString(KeystoreFormat f) @safe {
  final switch (f) {
    case KeystoreFormat.jks:   return "jks";
    case KeystoreFormat.jceks: return "jceks";
    case KeystoreFormat.p12:   return "p12";
    case KeystoreFormat.pem:   return "pem";
  }
}

// Helper: parse KeystoreLevel from string
KeystoreLevel parseKeystoreLevel(string s) @safe {
  import std.uni : toLower;
  switch (s.toLower) {
    case "application":  return KeystoreLevel.application;
    case "subscription": return KeystoreLevel.subscription;
    default:             return KeystoreLevel.account;
  }
}

// Helper: parse KeyEntryType from string
KeyEntryType parseKeyEntryType(string s) @safe {
  import std.uni : toLower;
  switch (s.toLower) {
    case "certificate":        return KeyEntryType.certificate;
    case "secretkey":          return KeyEntryType.secretKey;
    case "trustedcertificate": return KeyEntryType.trustedCertificate;
    default:                   return KeyEntryType.privateKey;
  }
}

// Shared timestamp helper
long currentTimestamp() @trusted {
  import core.time : MonoTime;
  import std.datetime : Clock;
  return Clock.currStdTime;
}
