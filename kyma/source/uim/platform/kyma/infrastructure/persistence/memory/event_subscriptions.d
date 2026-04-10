/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.kyma.infrastructure.persistence.memory.event_subscriptions;

// import uim.platform.kyma.domain.types;
// import uim.platform.kyma.domain.entities.event_subscription;
// import uim.platform.kyma.domain.ports.repositories.event_subscriptions;

// import std.algorithm : filter;
// import std.array : array;
import uim.platform.kyma;

mixin(ShowModule!());

@safe:
class MemoryEventSubscriptionRepository : EventSubscriptionRepository {
  private EventSubscription[EventSubscriptionId] store;

  bool existsById(EventSubscriptionId id) {
    return (id in store) ? true : false;
  }

  EventSubscription findById(EventSubscriptionId id) {
    if (existsById(id))
      return store[id];
    return EventSubscription.init;
  }

  bool existsByName(NamespaceId nsId, string name) {
    return findByNamespace(nsId).any!(e => e.name == name);
  }

  EventSubscription findByName(NamespaceId nsId, string name) {
    foreach (ref e; findByNamespace(nsId))
      if (e.name == name)
        return e;
    return EventSubscription.init;
  }

  EventSubscription[] findByNamespace(NamespaceId nsId) {
    return store.byValue().filter!(e => e.namespaceId == nsId).array;
  }

  EventSubscription[] findByEnvironment(KymaEnvironmentId envId) {
    return store.byValue().filter!(e => e.environmentId == envId).array;
  }

  EventSubscription[] findBySource(string source) {
    return store.byValue().filter!(e => e.source == source).array;
  }

  EventSubscription[] findByStatus(SubscriptionStatus status) {
    return store.byValue().filter!(e => e.status == status).array;
  }

  void save(EventSubscription sub) {
    store[sub.id] = sub;
  }

  void update(EventSubscription sub) {
    store[sub.id] = sub;
  }

  void remove(EventSubscriptionId id) {
    store.remove(id);
  }
}
