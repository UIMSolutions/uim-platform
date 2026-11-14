/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Background worker: removes expired / revoked tokens and codes of the
/// configured tenants periodically (vibe.d timer, same fiber scheduler as the server).
module uim.platform.oauth.infrastructure.workers.expiry_purge;

import vibe.core.core : setTimer, Timer;
import uim.platform.oauth;

mixin(ShowModule!());

@safe:

class ExpiryPurgeWorker {
  protected IManageTokens tokens;
  protected string[] tenants;
  protected Timer timer;

  this(IManageTokens tokens, string[] tenants) {
    this.tokens = tokens;
    this.tenants = tenants;
  }

  /// Start the periodic purge (0 = disabled).
  void start(uint intervalSeconds) @trusted {
    if (intervalSeconds == 0 || tenants.length == 0)
      return;
    timer = setTimer(dur!"seconds"(intervalSeconds), () @safe nothrow { runOnce(); }, true);
  }

  /// One purge run over all tenants (never throws).
  RevocationResult runOnce() nothrow {
    RevocationResult total;
    foreach (t; tenants) {
      try {
        auto r = tokens.purgeExpired(TenantId(t));
        total.add(r);
        if (r.total > 0)
          logServiceEvent("info", "purged expired tokens", Json([
              "tenant": Json(t), "accessTokens": Json(r.accessTokens), "refreshTokens": Json(r.refreshTokens),
              "codes": Json(r.codes)
            ]));
      } catch (Exception e) {
        try
          logServiceEvent("error", "purge failed", Json(["tenant": Json(t), "error": Json(e.msg)]));
        catch (Exception) {
        }
      }
    }
    return total;
  }
}
