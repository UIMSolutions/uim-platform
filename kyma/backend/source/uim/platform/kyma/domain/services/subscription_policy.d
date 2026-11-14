/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.domain.services.subscription_policy;

import uim.platform.kyma;

mixin(ShowModule!());

@safe:

/// Domain service: rules for eventing subscriptions.
class SubscriptionPolicy {
  void validate(const ref EventSubscription sub) {
    import uim.platform.kyma.domain.exceptions.kyma : check = validate;

    validateResourceName("Subscription", sub.name);
    check(sub.source.length > 0, "Subscription source is required (e.g. the application name)");
    check(sub.eventTypes.length > 0, "Subscription needs at least one event type");
    foreach (t; sub.eventTypes)
      check(t.length > 0 && !t.canFind(" "), "Invalid event type '" ~ t ~ "'");
    if (sub.typeEncoding == EventTypeEncoding.exact)
      foreach (t; sub.eventTypes)
        check(t.canFind("."), "Exact event type '" ~ t ~ "' must be qualified, e.g. sap.s4.beh.salesorder.v1.SalesOrder.Created.v1");
    check(sub.sinkUrl.startsWith("http://") || sub.sinkUrl.startsWith("https://"),
      "Sink must be an http(s) URL or a service name");
    check(sub.maxInFlightMessages >= 1 && sub.maxInFlightMessages <= 1000,
      "maxInFlightMessages must be between 1 and 1000");
  }

  /// Derive the sink URL from a service reference if none is given.
  static string resolveSink(string sinkUrl, string serviceName, int port, string namespaceName) {
    if (sinkUrl.length > 0 || serviceName.length == 0)
      return sinkUrl;
    return "http://" ~ serviceName ~ "." ~ namespaceName ~ ".svc.cluster.local"
      ~ (port > 0 && port != 80 ? ":" ~ port.to!string : "");
  }
}

///
unittest {
  assert(SubscriptionPolicy.resolveSink("", "orders", 8080, "shop") == "http://orders.shop.svc.cluster.local:8080");
  assert(SubscriptionPolicy.resolveSink("https://x", "orders", 80, "shop") == "https://x");
}
