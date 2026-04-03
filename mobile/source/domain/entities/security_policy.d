/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.mobile.domain.entities.security_policy;

import uim.platform.mobile.domain.types;

/// Security policy governing mobile app behavior.
struct SecurityPolicy
{
  SecurityPolicyId id;
  TenantId tenantId;
  string name;
  string description;
  EnforcementLevel enforcementLevel = EnforcementLevel.recommended;
  // Authentication
  MobileAuthType[] allowedAuthTypes;
  int sessionTimeoutMinutes = 30;
  int maxFailedLogins = 5;
  bool requireBiometric = false;
  bool allowOfflineAccess = true;
  int offlineAccessDurationHours = 168; // 7 days
  // Data protection
  bool encryptLocalStorage = true;
  bool preventScreenCapture = false;
  bool preventCopyPaste = false;
  bool enableDataLossPrevention = false;
  // Network
  bool requireSsl = true;
  bool enableCertificatePinning = false;
  string[] pinnedCertificates;
  bool blockJailbroken = true;
  bool blockRooted = true;
  // App integrity
  bool enableAppIntegrityCheck = true;
  string minimumOsVersion;
  string[] allowedIpRanges;
  string[] blockedCountries;
  // Logging & compliance
  bool enableAuditLogging = true;
  int logRetentionDays = 90;
  string createdBy;
  long createdAt;
  long updatedAt;
}
