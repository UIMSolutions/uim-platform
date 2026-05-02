/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.keystore.domain.entities.key_entry;

// import uim.platform.keystore.domain.types;
import uim.platform.keystore;

mixin(ShowModule!());

@safe:

/// A single entry (key or certificate) within a keystore.
struct KeyEntry {
  KeyEntryId id;
  KeystoreId keystoreId;
  string alias_; // entry alias within the keystore
  KeyEntryType entryType; // privateKey | certificate | secretKey | trustedCertificate
  string content; // base64-encoded DER/PEM of the key or certificate
  string format; // optional format hint (e.g., "X.509", "PKCS#8")
  string subject; // certificate subject DN
  string issuer; // certificate issuer DN
  string serialNumber; // certificate serial number
  long notBefore; // certificate validity start (epoch micros)
  long notAfter; // certificate validity end (epoch micros)
  long createdAt;
}
