/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.credential_store.domain.services.keyring_manager;

import uim.platform.credential_store.domain.types;

import std.conv : to;

struct KeyringManager {
  // Check if a keyring can be deleted (must be disabled for >= 7 days)
  static bool canDelete(long disabledAt, long currentTime) {
    enum sevenDaysMs = 7 * 24 * 60 * 60 * 1000L;
    if (disabledAt == 0)
      return false; // not disabled
    return (currentTime - disabledAt) >= sevenDaysMs;
  }

  // Check if auto-rotation is due
  static bool isRotationDue(long lastRotatedAt, long currentTime, int rotationPeriodDays) {
    auto periodMs = cast(long) rotationPeriodDays * 24 * 60 * 60 * 1000L;
    return (currentTime - lastRotatedAt) >= periodMs;
  }

  // Validate rotation period (30-365 days)
  static bool validateRotationPeriod(int days) {
    return days >= 30 && days <= 365;
  }

  // Generate a simple placeholder key material (in production, use proper crypto)
  static string generateKeyMaterial() {
    import std.uuid : randomUUID;

    return randomUUID().to!string ~ randomUUID().to!string;
  }
}
