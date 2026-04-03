module uim.platform.abap_enviroment.infrastructure.persistence.memory.system_instance_repo;

// import uim.platform.abap_enviroment.domain.types;
// import uim.platform.abap_enviroment.domain.entities.system_instance;
// import uim.platform.abap_enviroment.domain.ports.system_instance_repository;
// 
// // import std.algorithm : filter;
// // import std.array : array;
import uim.platform.abap_enviroment;

mixin(ShowModule!());
@safe:
class MemorySystemInstanceRepository : SystemInstanceRepository
{
  private SystemInstance[SystemInstanceId] store;

  SystemInstance findById(SystemInstanceId id)
  {
    if (id in store)
      return store[id];
    return SystemInstance.init;
  }

  SystemInstance[] findByTenant(TenantId tenantId)
  {
    return store.byValue().filter!(e => e.tenantId == tenantId).array;
  }

  SystemInstance findByName(TenantId tenantId, string name)
  {
    foreach (e; store.byValue())
      if (e.tenantId == tenantId && e.name == name)
        return e;
    return SystemInstance.init;
  }

  SystemInstance[] findByStatus(TenantId tenantId, SystemStatus status)
  {
    return store.byValue().filter!(e => e.tenantId == tenantId && e.status == status).array;
  }

  void save(SystemInstance instance)
  {
    store[instance.id] = instance;
  }

  void update(SystemInstance instance)
  {
    store[instance.id] = instance;
  }

  void remove(SystemInstanceId id)
  {
    store.remove(id);
  }
}
