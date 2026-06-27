/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.destination.infrastructure.persistence.memory.fragments;
// import uim.platform.destination.domain.types;
// import uim.platform.destination.domain.entities.destination_fragment;
// import uim.platform.destination.domain.ports.repositories.fragments;
// 
//  
import uim.platform.destination;

// mixin(ShowModule!());

@safe:
class MemoryFragmentRepository : TentRepository!(DestinationFragment, DestinationFragmentId), FragmentRepository {

  bool existsByName(TenantId tenantId, SubaccountId subaccountId, string name) {
    return findByTenant(tenantId).any!(e => e.tenantId == tenantId && e.subaccountId == subaccountId && e.name == name);
  }
  DestinationFragment findByName(TenantId tenantId, SubaccountId subaccountId, string name) {
    foreach (e; findByTenant(tenantId))
      if (e.subaccountId == subaccountId && e.name == name)
        return e;
    return DestinationFragment.init;
  }

  void removeByName(TenantId tenantId, SubaccountId subaccountId, string name) {
    remove(findByName(tenantId, subaccountId, name));
  }

  size_t countBySubaccount(TenantId tenantId, SubaccountId subaccountId) {
    return findBySubaccount(tenantId, subaccountId).length;
  }

  DestinationFragment[] filterBySubaccount(DestinationFragment[] fragments, SubaccountId subaccountId) {
    return fragments.filter!(e => e.subaccountId == subaccountId).array;
  }

  DestinationFragment[] findBySubaccount(TenantId tenantId, SubaccountId subaccountId) {
    return filterBySubaccount(findByTenant(tenantId), subaccountId);
  }

  void removeBySubaccount(TenantId tenantId, SubaccountId subaccountId) {
    findBySubaccount(tenantId, subaccountId).each!(e => remove(e));
  }

  size_t countByLevel(TenantId tenantId, DestinationLevel level) {
    return findByLevel(tenantId, level).length;
  }

   DestinationFragment[] filterByLevel(DestinationFragment[] fragments, DestinationLevel level) {
    return fragments.filter!(e => e.level == level).array;
  } 

  DestinationFragment[] findByLevel(TenantId tenantId, DestinationLevel level) {
    return filterByLevel(findByTenant(tenantId), level);
  }

   void removeByLevel(TenantId tenantId, DestinationLevel level) {
    findByLevel(tenantId, level).each!(e => remove(e));
  }

}

unittest {
  auto repo = new MemoryFragmentRepository();
  auto tenantId = TenantId("test-tenant");
  auto subaccountId = SubaccountId("test-subaccount");

  // Create fragments
  DestinationFragment f1;
  f1.initEntity(tenantId);
  f1.createdBy = "user1";
  f1.subaccountId = subaccountId;
  f1.name = "Fragment A";
  f1.level = DestinationLevel.serviceInstance;
  repo.save(f1);

  DestinationFragment f2;
  f2.initEntity(tenantId);
  f2.createdBy = "user2";
  f2.subaccountId = subaccountId;
  f2.name = "Fragment B";
  f2.level = DestinationLevel.subaccount;
  repo.save(f2);

  DestinationFragment f3;
  f3.initEntity(tenantId);
  f3.createdBy = "user3";
  f3.subaccountId = SubaccountId("other-subaccount");
  f3.name = "Fragment C";
  f3.level = DestinationLevel.serviceInstance;
  repo.save(f3);

  // Test findByName
  assert(repo.findByName(tenantId, subaccountId, "Fragment A").name == "Fragment A");
  assert(repo.existsByName(tenantId, subaccountId, "Fragment B"));
  repo.removeByName(tenantId, subaccountId, "Fragment B");
  assert(!repo.existsByName(tenantId, subaccountId, "Fragment B")); 
  
  // Test findBySubaccount
  auto subFragments = repo.findBySubaccount(tenantId, subaccountId);
  assert(subFragments.length == 1);
  
  // Test findByLevel
  auto serviceInstanceFragments = repo.findByLevel(tenantId, DestinationLevel.serviceInstance);
  assert(serviceInstanceFragments.length == 2);
  assert(serviceInstanceFragments[0].name == "Fragment A" || serviceInstanceFragments[0].name == "Fragment C");
  assert(serviceInstanceFragments[1].name == "Fragment A" || serviceInstanceFragments[1].name == "Fragment C"); 

   // Test removeBySubaccount

  // Test countBySubaccount
  assert(repo.countBySubaccount(tenantId, subaccountId) == 1);

  // Test countByLevel
  assert(repo.countByLevel(tenantId, DestinationLevel.serviceInstance) == 2);
  assert(repo.countByLevel(tenantId, DestinationLevel.subaccount) == 0);
  assert(repo.countByLevel(tenantId, DestinationLevel.serviceInstance) == 2);
}

