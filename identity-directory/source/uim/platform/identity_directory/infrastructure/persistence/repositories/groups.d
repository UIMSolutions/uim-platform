/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_directory.infrastructure.persistence.repositories.groups;
// import uim.platform.identity_directory.domain.entities.group;

// import uim.platform.identity_directory.domain.ports.repositories.groups;
import uim.platform.identity_directory;

mixin(ShowModule!());

@safe:
/// In-memory adapter for group persistence.
class GroupRepository : TenantRepository!(IDGroup, GroupId), IGroupRepository {

  bool existsByDisplayName(TenantId tenantId, string displayName) {
    return findByTenant(tenantId).any!(g => g.displayName == displayName);
  }
  
  IDGroup findByDisplayName(TenantId tenantId, string displayName) {
    foreach (g; findByTenant(tenantId)) {
      if (g.displayName == displayName)
        return g;
    }
    return IDGroup.init;
  }

  void removeByDisplayName(TenantId tenantId, string displayName) {
    remove(findByDisplayName(tenantId, displayName));
  }

  // #region ByMember
  size_t countByMember(TenantId tenantId, string memberId) {
    return findByMember(tenantId, memberId).length;
  }
  IDGroup[] filterByMember(IDGroup[] groups, string memberId, size_t offset = 0, size_t limit = 100) {
    return groups.filter!(g => g.hasMember(memberId)).array.skip(offset).limit(limit);
  }
  IDGroup[] findByMember(TenantId tenantId, string memberId) {
    return findByTenant(tenantId).filter!(g => g.hasMember(memberId)).array;
  }

  void removeByMember(TenantId tenantId, string memberId) {
    findByMember(tenantId, memberId).each!(g => remove(g)); // Update the group in the store after modification
  }
  // #endregion ByMember

}

///
unittest {
  mixin(ShowTest!("GroupRepository"));
  
  void testExistsByDisplayName() {
    auto repo = new GroupRepository();
    auto tenantId = TenantId("test-tenant");
    auto group = IDGroup(tenantId, GroupId("group1"));
    group.displayName = "Test Group";
    repo.save(group);

    assert(repo.existsByDisplayName(tenantId, "Test Group") == true);
    assert(repo.existsByDisplayName(tenantId, "Nonexistent Group") == false);
  }

  void testFindByDisplayName() {
    auto repo = new GroupRepository();
    auto tenantId = TenantId("test-tenant");
    auto group = IDGroup(tenantId, GroupId("group1"));
    group.displayName = "Test Group";
    repo.save(group);
    
    assert(repo.findByDisplayName(tenantId, "Test Group") == group);
    assert(repo.findByDisplayName(tenantId, "Nonexistent Group") == IDGroup.init);
  }

  void testRemoveByDisplayName() {
    auto repo = new GroupRepository();
    auto tenantId = TenantId("test-tenant");
    auto group = IDGroup(tenantId, GroupId("group1"));
    group.displayName = "Test Group";
    repo.save(group);
    
    repo.removeByDisplayName(tenantId, "Test Group");
    assert(repo.existsByDisplayName(tenantId, "Test Group") == false);
  }
  
  void testCountByMember() {
    auto repo = new GroupRepository();
    auto tenantId = TenantId("test-tenant");
    auto group = IDGroup(tenantId, GroupId("group1"));
    group.addMember(UserId("member1"), "Member 1");
    repo.save(group);
    
    assert(repo.countByMember(tenantId, "member1") == 1);
    assert(repo.countByMember(tenantId, "member2") == 0);
  }

  void testFindByMember() {
    auto repo = new GroupRepository();
    auto tenantId = TenantId("test-tenant");
    auto group = IDGroup(tenantId, GroupId("group1"));
    group.addMember(UserId("member1"), "Member 1");
    repo.save(group);
    
    assert(repo.findByMember(tenantId, "member1").length == 1);
    assert(repo.findByMember(tenantId, "member2").length == 0);
  }

  void testRemoveByMember() {
    auto repo = new GroupRepository();
    auto tenantId = TenantId("test-tenant");
    auto group = IDGroup(tenantId, GroupId("group1"));
    group.addMember(UserId("member1"), "Member 1");
    repo.save(group);
    
    repo.removeByMember(tenantId, "member1");
    assert(repo.countByMember(tenantId, "member1") == 0);
  }

  void testAll() {
    testExistsByDisplayName();
    testFindByDisplayName();
    testRemoveByDisplayName();
    testCountByMember();
    testFindByMember();
    testRemoveByMember();
  }

  testAll();
}

