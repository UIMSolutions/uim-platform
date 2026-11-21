/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Driven ports of the aggregates.
module uim.platform.architecture.ports.repositories.repositories;

import uim.platform.architecture;

mixin(ShowModule!());

@safe:

interface IBuildingBlockRepository : IArchitectureRepository!(BuildingBlock, BuildingBlockId) {
  /// Solution blocks whose realizesId points to the architecture block.
  BuildingBlock[] findRealizing(TenantId t, BuildingBlockId abb);
}

interface IRelationshipRepository : IArchitectureRepository!(Relationship, RelationshipId) {
  /// Relationships with the block as source or target.
  Relationship[] findByBlock(TenantId t, BuildingBlockId block);
  /// Remove all relationships of a block; returns the number removed.
  size_t removeByBlock(TenantId t, BuildingBlockId block);
}

/// All repositories (passed to the interactors as one bundle).
struct ArchitectureRepositories {
  IBuildingBlockRepository blocks;
  IRelationshipRepository relationships;
}
