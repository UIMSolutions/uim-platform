/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Concrete repositories (driven port implementations).
module uim.platform.architecture.persistence.repositories.repositories;

import uim.platform.architecture;

mixin(ShowModule!());

@safe:

class BuildingBlockRepository : DocumentRepository!(BuildingBlock, BuildingBlockId, blockToRecord, recordToBlock),
IBuildingBlockRepository {
  this(IDocumentStore store) {
    super(store, Collections.blocks);
  }

  BuildingBlock[] findRealizing(TenantId t, BuildingBlockId abb) {
    return findAll(t).filter!(b => b.realizesId == abb).array;
  }
}

class RelationshipRepository : DocumentRepository!(Relationship, RelationshipId, relationshipToRecord, recordToRelationship),
IRelationshipRepository {
  this(IDocumentStore store) {
    super(store, Collections.relationships);
  }

  Relationship[] findByBlock(TenantId t, BuildingBlockId block) {
    return findAll(t).filter!(r => r.involves(block)).array;
  }

  size_t removeByBlock(TenantId t, BuildingBlockId block) {
    size_t removed;
    foreach (r; findByBlock(t, block))
      if (removeById(t, r.id))
        removed++;
    return removed;
  }
}

/// All repositories over one document store.
ArchitectureRepositories createRepositories(IDocumentStore store) {
  ArchitectureRepositories r;
  r.blocks = new BuildingBlockRepository(store);
  r.relationships = new RelationshipRepository(store);
  return r;
}

///
unittest {
  auto repos = createRepositories(new MemoryDocumentStore);
  auto t = TenantId("t");
  BuildingBlock b;
  b.tenantId = t;
  b.id = BuildingBlockId("sbb-a");
  b.kind = BlockKind.solution;
  b.realizesId = BuildingBlockId("abb-a");
  repos.blocks.save(b);
  assert(repos.blocks.existsById(t, b.id) && repos.blocks.countAll(t) == 1);
  assert(repos.blocks.findRealizing(t, BuildingBlockId("abb-a")).length == 1);
  assert(repos.blocks.findById(TenantId("other"), b.id).isNull); // tenant isolation

  Relationship r;
  r.tenantId = t;
  r.id = RelationshipId("r1");
  r.sourceId = b.id;
  r.targetId = BuildingBlockId("x");
  repos.relationships.save(r);
  assert(repos.relationships.findByBlock(t, BuildingBlockId("x")).length == 1);
  assert(repos.relationships.removeByBlock(t, b.id) == 1 && repos.relationships.countAll(t) == 0);
}
