/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Driving port: manage building blocks.
module uim.platform.architecture.ports.usecases.blocks;

import uim.platform.architecture;

mixin(ShowModule!());

@safe:

interface IManageBuildingBlocks {
  BuildingBlock createBlock(CreateBlockRequest r);
  /// PATCH semantics: only the values that are set change.
  BuildingBlock updateBlock(UpdateBlockRequest r);
  /// Lifecycle transition (see domain.services.lifecycle).
  BuildingBlock changeStatus(TenantId t, BuildingBlockId id, string status, UserId actor);
  BuildingBlock getBlock(TenantId t, BuildingBlockId id);
  BuildingBlock[] listBlocks(TenantId t, BlockFilter filter = BlockFilter.init);
  /// Deletes the block and its relationships; clears realizesId of SBBs pointing to it.
  void deleteBlock(TenantId t, BuildingBlockId id, UserId actor);
}
