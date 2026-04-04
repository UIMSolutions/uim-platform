/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.domain.ports.repositories.event_subscriptions;

import uim.platform.kyma.domain.entities.event_subscription;
import uim.platform.kyma.domain.types;

/// Port: outgoing — event subscription persistence.
interface EventSubscriptionRepository {
  EventSubscription findById(EventSubscriptionId id);
  EventSubscription findByName(NamespaceId nsId, string name);
  EventSubscription[] findByNamespace(NamespaceId nsId);
  EventSubscription[] findByEnvironment(KymaEnvironmentId envId);
  EventSubscription[] findBySource(string source);
  EventSubscription[] findByStatus(SubscriptionStatus status);
  void save(EventSubscription sub);
  void update(EventSubscription sub);
  void remove(EventSubscriptionId id);
}
