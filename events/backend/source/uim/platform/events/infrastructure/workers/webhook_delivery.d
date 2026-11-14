/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Periodic webhook push delivery (deliveryIntervalSeconds > 0).
module uim.platform.events.infrastructure.workers.webhook_delivery;

import vibe.core.core : setTimer, Timer;
import uim.platform.events;

mixin(ShowModule!());

@safe:

class WebhookDeliveryWorker {
  protected IDeliverWebhooks delivery;
  protected IConsumeMessages consumer;
  protected string[] tenants;
  protected Timer timer;
  protected bool running;

  this(IDeliverWebhooks delivery, IConsumeMessages consumer, string[] tenants) {
    this.delivery = delivery;
    this.consumer = consumer;
    this.tenants = tenants;
  }

  /// Start the periodic timer (no-op for 0).
  void start(uint intervalSeconds) {
    if (intervalSeconds == 0)
      return;
    timer = setTimer(intervalSeconds.seconds, &tick, true);
    logServiceEvent("info", "webhook delivery worker started", Json(["intervalSeconds": Json(intervalSeconds)]));
  }

  void stop() {
    if (timer)
      timer.stop();
  }

  /// One delivery round over all configured tenants (skipped while a round runs).
  void tick() nothrow {
    if (running)
      return;
    running = true;
    scope (exit)
      running = false;
    foreach (t; tenants) {
      try {
        auto expired = consumer.removeExpired(TenantId(t));
        size_t delivered, failed;
        foreach (r; delivery.deliverAll(TenantId(t), UserId("webhook-delivery"))) {
          delivered += r.delivered;
          failed += r.attempted - r.delivered;
        }
        if (delivered + failed + expired > 0)
          logServiceEvent(failed ? "warn" : "info", "webhook delivery", Json([
                "tenant": Json(t), "delivered": Json(delivered), "failed": Json(failed), "expired": Json(expired)
              ]));
      } catch (Exception e) {
        try
          logServiceEvent("error", "webhook delivery failed", Json(["tenant": Json(t), "error": Json(e.msg)]));
        catch (Exception) {
        }
      }
    }
  }
}
