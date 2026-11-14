/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.ports.repositories.event_subscriptions;

import uim.platform.kyma;

mixin(ShowModule!());

@safe:

/// Driven port: persistence of eventing subscriptions (namespace scoped).
interface IEventSubscriptionRepository : ITenantRepository!(EventSubscription, EventSubscriptionId) {
  EventSubscription findByName(TenantId tenantId, NamespaceId namespaceId, string name);
  EventSubscription[] findByNamespace(TenantId tenantId, NamespaceId namespaceId);
  EventSubscription[] findByEnvironment(TenantId tenantId, KymaEnvironmentId environmentId);
}
