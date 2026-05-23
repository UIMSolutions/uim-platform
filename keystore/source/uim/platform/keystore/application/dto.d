/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.keystore.application.dto;
import uim.platform.keystore;

mixin(ShowModule!());

@safe:
// ---------------------------------------------------------------------------
// Keystore DTOs
// ---------------------------------------------------------------------------
struct UploadKeystoreRequest {
  TenantId tenantId;

  string accountId;
  string applicationId;   // empty = account-level
  string subscriptionId;  // non-empty = subscription-level
  string level;           // "account" | "application" | "subscription"
  string name;
  string description;
  string format;          // "jks" | "jceks" | "p12" | "pem"
  string content;         // base64-encoded keystore file bytes
  UserId createdBy;
}

struct UpdateKeystoreRequest {
  TenantId tenantId;

  string description;
  string content;         // base64-encoded replacement content (optional)
  UserId updatedBy;
}
// ---------------------------------------------------------------------------
// KeyEntry DTOs
// ---------------------------------------------------------------------------
struct ImportKeyEntryRequest {
  TenantId tenantId;

  string keystoreId;
  string alias_;
  string entryType;       // "privateKey" | "certificate" | "secretKey" | "trustedCertificate"
  string content;         // base64-encoded key/cert DER bytes
  string format;
  string subject;
  string issuer;
  string serialNumber;
  long   notBefore;
  long   notAfter;
}
// ---------------------------------------------------------------------------
// KeyPassword DTOs
// ---------------------------------------------------------------------------
struct SetPasswordRequest {
  TenantId tenantId;
  
  string accountId;
  string applicationId;
  string alias_;
  string passwordValue;
}

struct GetPasswordRequest {
  TenantId tenantId;
  string accountId;
  string applicationId;
  string alias_;
}

struct DeletePasswordRequest {
  TenantId tenantId;
  string accountId;
  string applicationId;
  string alias_;
}
