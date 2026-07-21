/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.keystore.domain.enumerations;

import uim.platform.keystore;

mixin(ShowModule!());

@safe:

// Keystore format
enum KeystoreFormat {
  jks,
  jceks,
  p12,
  pem,
}

KeystoreFormat toKeystoreFormat(string value) {
  mixin(EnumSwitch("KeystoreFormat", "jks"));
}

KeystoreFormat[] toKeystoreFormats(string[] values)
  => values.map!toKeystoreFormat.array;

string toString(KeystoreFormat value)
  => value.to!string;

string[] toStrings(KeystoreFormat[] values)
  => values.map!toString.array;
///
unittest {
  mixin(ShowTest!("KeystoreFormat"));

  assert("jks".toKeystoreFormat == KeystoreFormat.jks);
  assert("jceks".toKeystoreFormat == KeystoreFormat.jceks);
  assert("p12".toKeystoreFormat == KeystoreFormat.p12);
  assert("pem".toKeystoreFormat == KeystoreFormat.pem);

  assert("".toKeystoreFormat == KeystoreFormat.jks);
  assert("unknown".toKeystoreFormat == KeystoreFormat.jks);

  assert(KeystoreFormat.jks.toString == "jks");
  assert(KeystoreFormat.jceks.toString == "jceks");
  assert(KeystoreFormat.p12.toString == "p12");
  assert(KeystoreFormat.pem.toString == "pem");

  assert(["jks", "p12"].toKeystoreFormats == [
      KeystoreFormat.jks, KeystoreFormat.p12
    ]);
  assert([KeystoreFormat.jks, KeystoreFormat.p12].toStrings == ["jks", "p12"]);
}

// Keystore scope level (search order: subscription > application > account)
enum KeystoreLevel {
  account,
  application,
  subscription,
}

KeystoreLevel toKeystoreLevel(string value) {
  mixin(EnumSwitch("KeystoreLevel", "account"));
}

KeystoreLevel[] toKeystoreLevels(string[] values)
  => values.map!toKeystoreLevel.array;

string toString(KeystoreLevel value)
  => value.to!string;

string[] toStrings(KeystoreLevel[] values)
  => values.map!toString.array;
///
unittest {
  mixin(ShowTest!("KeystoreLevel"));

  assert("account".toKeystoreLevel == KeystoreLevel.account);
  assert("application".toKeystoreLevel == KeystoreLevel.application);
  assert("subscription".toKeystoreLevel == KeystoreLevel.subscription);

  assert("".toKeystoreLevel == KeystoreLevel.account);
  assert("unknown".toKeystoreLevel == KeystoreLevel.account);

  assert(KeystoreLevel.account.toString == "account");
  assert(KeystoreLevel.application.toString == "application");
  assert(KeystoreLevel.subscription.toString == "subscription");

  assert(["account", "subscription"].toKeystoreLevels == [
      KeystoreLevel.account, KeystoreLevel.subscription
    ]);
  assert([KeystoreLevel.account, KeystoreLevel.subscription].toStrings == [
      "account", "subscription"
    ]);
}

// Type of entry within a keystore
enum KeyEntryType {
  trustedCertificate,
  privateKey,
  certificate,
  secretKey,
}

KeyEntryType toKeyEntryType(string value) {
  mixin(EnumSwitch("KeyEntryType", "trustedCertificate"));
}

KeyEntryType[] toKeyEntryTypes(string[] values)
  => values.map!toKeyEntryType.array;

string toString(KeyEntryType value)
  => value.to!string;

string[] toStrings(KeyEntryType[] values)
  => values.map!toString.array;
///
unittest {
  mixin(ShowTest!("KeyEntryType"));

  assert("trustedCertificate".toKeyEntryType == KeyEntryType.trustedCertificate);
  assert("privateKey".toKeyEntryType == KeyEntryType.privateKey);
  assert("certificate".toKeyEntryType == KeyEntryType.certificate);
  assert("secretKey".toKeyEntryType == KeyEntryType.secretKey);

  assert("".toKeyEntryType == KeyEntryType.trustedCertificate);
  assert("unknown".toKeyEntryType == KeyEntryType.trustedCertificate);

  assert(KeyEntryType.trustedCertificate.toString == "trustedCertificate");
  assert(KeyEntryType.privateKey.toString == "privateKey");
  assert(KeyEntryType.certificate.toString == "certificate");
  assert(KeyEntryType.secretKey.toString == "secretKey");

  assert(["trustedCertificate", "privateKey"].toKeyEntryTypes == [
      KeyEntryType.trustedCertificate, KeyEntryType.privateKey
    ]);
  assert([KeyEntryType.trustedCertificate, KeyEntryType.privateKey].toStrings == [
      "trustedCertificate", "privateKey"
    ]);
}
