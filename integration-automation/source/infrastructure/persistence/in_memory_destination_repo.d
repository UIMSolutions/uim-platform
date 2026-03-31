module infrastructure.persistence.in_memory_destination_repo;

import domain.types;
import domain.entities.destination;
import domain.ports.destination_repository;

import std.algorithm : filter;
import std.array : array;

class InMemoryDestinationRepository : DestinationRepository
{
  private Destination[DestinationId] store;

  Destination[] findByTenant(TenantId tenantId)
  {
    return store.byValue().filter!(e => e.tenantId == tenantId).array;
  }

  Destination* findById(DestinationId id, TenantId tenantId)
  {
    if (auto p = id in store)
      if (p.tenantId == tenantId)
        return p;
    return null;
  }

  Destination[] findBySystem(TenantId tenantId, SystemId systemId)
  {
    return store.byValue()
      .filter!(e => e.tenantId == tenantId && e.systemId == systemId)
      .array;
  }

  Destination* findByName(TenantId tenantId, string name)
  {
    foreach (ref d; store.byValue())
      if (d.tenantId == tenantId && d.name == name)
        return &d;
    return null;
  }

  Destination[] findEnabled(TenantId tenantId)
  {
    return store.byValue()
      .filter!(e => e.tenantId == tenantId && e.isEnabled)
      .array;
  }

  void save(Destination destination)
  {
    store[destination.id] = destination;
  }

  void update(Destination destination)
  {
    store[destination.id] = destination;
  }

  void remove(DestinationId id, TenantId tenantId)
  {
    if (auto p = id in store)
      if (p.tenantId == tenantId)
        store.remove(id);
  }
}
