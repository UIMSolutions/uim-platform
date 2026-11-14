/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Response models of the dashboard / overview port.
module uim.platform.management.application.dtos.overview;

import uim.platform.management;

mixin(ShowModule!());

@safe:

/// Figures of a single global account.
struct AccountOverview {
  size_t totalSubaccounts;
  size_t activeSubaccounts;
  size_t totalDirectories;
  size_t totalEntitlements;
  size_t totalEnvironments;
  size_t totalSubscriptions;
  size_t recentEventsCount;

  Json toJson() const {
    return Json.emptyObject
      .set("totalSubaccounts", totalSubaccounts)
      .set("activeSubaccounts", activeSubaccounts)
      .set("totalDirectories", totalDirectories)
      .set("totalEntitlements", totalEntitlements)
      .set("totalEnvironments", totalEnvironments)
      .set("totalSubscriptions", totalSubscriptions)
      .set("recentEventsCount", recentEventsCount);
  }
}

/// Figures of a whole tenant (all global accounts) — the cockpit header.
struct TenantOverview {
  TenantId tenantId;
  size_t globalAccounts;
  size_t activeGlobalAccounts;
  size_t suspendedGlobalAccounts;
  size_t directories;
  size_t subaccounts;
  size_t activeSubaccounts;
  size_t suspendedSubaccounts;
  size_t entitlements;
  size_t revokedEntitlements;
  size_t overQuotaEntitlements;
  long quotaAssigned;
  long quotaUsed;
  size_t environments;
  size_t subscriptions;
  size_t servicePlans;
  size_t labels;
  size_t events;
  size_t warningEvents; // warning, error or critical
  long lastEventAt; // stdTime, 0 = none

  Json toJson() const {
    return Json.emptyObject
      .set("tenantId", tenantId.value)
      .set("globalAccounts", globalAccounts)
      .set("activeGlobalAccounts", activeGlobalAccounts)
      .set("suspendedGlobalAccounts", suspendedGlobalAccounts)
      .set("directories", directories)
      .set("subaccounts", subaccounts)
      .set("activeSubaccounts", activeSubaccounts)
      .set("suspendedSubaccounts", suspendedSubaccounts)
      .set("entitlements", entitlements)
      .set("revokedEntitlements", revokedEntitlements)
      .set("overQuotaEntitlements", overQuotaEntitlements)
      .set("quotaAssigned", quotaAssigned)
      .set("quotaUsed", quotaUsed)
      .set("environments", environments)
      .set("subscriptions", subscriptions)
      .set("servicePlans", servicePlans)
      .set("labels", labels)
      .set("events", events)
      .set("warningEvents", warningEvents)
      .set("lastEventAt", lastEventAt);
  }
}
