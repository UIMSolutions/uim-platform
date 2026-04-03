/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.management.domain.services.entitlement_evaluator;

// import uim.platform.management.domain.entities.entitlement;
// import uim.platform.management.domain.types;
import uim.platform.management;

mixin(ShowModule!());

@safe:
/// Domain service: evaluates entitlement quota constraints,
/// checks availability of service plan quotas.
class EntitlementEvaluator
{
  /// Check if a quota assignment is valid.
  QuotaValidation validateQuotaAssignment(int requestedQuota,
      int currentlyAssigned, int maxAvailable, bool unlimited)
  {
    QuotaValidation v;
    v.valid = true;

    if (requestedQuota <= 0)
    {
      v.valid = false;
      v.reason = "Requested quota must be greater than zero";
      return v;
    }

    if (!unlimited && (currentlyAssigned + requestedQuota) > maxAvailable)
    {
      v.valid = false;
      // import std.conv : to;

      v.reason = "Insufficient quota: requested " ~ requestedQuota.to!string ~ ", available " ~ (
          maxAvailable - currentlyAssigned).to!string ~ " of " ~ maxAvailable.to!string;
      return v;
    }

    return v;
  }

  /// Calculate remaining quota after an assignment.
  int calculateRemaining(int assigned, int used)
  {
    auto rem = assigned - used;
    return rem > 0 ? rem : 0;
  }

  /// Check if an entitlement has exceeded its quota.
  bool isOverQuota(Entitlement ent)
  {
    if (ent.unlimited)
      return false;
    return ent.quotaUsed > ent.quotaAssigned;
  }
}

/// Result of quota validation.
struct QuotaValidation
{
  bool valid;
  string reason;
}
