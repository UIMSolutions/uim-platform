/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Interactor: create, change, transition and delete building blocks.
module uim.platform.architecture.application.usecases.manage.blocks;

import uim.platform.architecture;

mixin(ShowModule!());

@safe:

class ManageBuildingBlocksUseCase : ArchitectureInteractor, IManageBuildingBlocks {
  this(ArchitectureRepositories repos, IClock clock, IArchitectureEventPublisher events = null) {
    super(repos, clock, events);
  }

  BuildingBlock createBlock(CreateBlockRequest r) {
    requireTenant(r.tenantId);
    BuildingBlock b;
    b.tenantId = r.tenantId;
    b.kind = parseBlockKind(r.kind);
    auto id = r.id.strip;
    if (id.length == 0)
      id = abbreviation(b.kind).toLower ~ "-" ~ newResourceId();
    requireResourceId(id, "Building block ID");
    b.id = BuildingBlockId(id);
    if (repos.blocks.existsById(r.tenantId, b.id))
      throw ArchitectureException.conflict("Building block '" ~ id ~ "' already exists");
    if (!r.values.status.isNull)
      b.status = parseLifecycleStatus(r.values.status.get);
    applyValues(b, r.values);
    checkRealization(b);
    b.validate();
    stamp(b, r.actor);
    repos.blocks.save(b);
    emit("block.created", b.tenantId, id, Json([
        "kind": Json(cast(string) b.kind), "status": Json(cast(string) b.status)
      ]));
    return b;
  }

  BuildingBlock updateBlock(UpdateBlockRequest r) {
    requireTenant(r.tenantId);
    auto b = loadBlock(r.tenantId, r.id);
    auto before = b.status;
    applyValues(b, r.values);
    if (!r.values.status.isNull) {
      auto next = parseLifecycleStatus(r.values.status.get);
      requireTransition(before, next);
      b.status = next;
    }
    checkRealization(b);
    b.validate();
    touch(b, r.actor);
    repos.blocks.save(b);
    emit("block.updated", b.tenantId, b.id.value);
    if (b.status != before)
      emit("block.statusChanged", b.tenantId, b.id.value, Json([
          "from": Json(cast(string) before), "to": Json(cast(string) b.status)
        ]));
    return b;
  }

  BuildingBlock changeStatus(TenantId t, BuildingBlockId id, string status, UserId actor) {
    requireText(status, "Status");
    UpdateBlockRequest r;
    r.tenantId = t;
    r.actor = actor;
    r.id = id;
    r.values.status = status;
    return updateBlock(r);
  }

  BuildingBlock getBlock(TenantId t, BuildingBlockId id) {
    requireTenant(t);
    return loadBlock(t, id);
  }

  BuildingBlock[] listBlocks(TenantId t, BlockFilter f = BlockFilter.init) {
    requireTenant(t);
    auto kind = f.kind.strip.length ? parseBlockKind(f.kind) : BlockKind.init;
    auto status = f.status.strip.length ? parseLifecycleStatus(f.status) : LifecycleStatus.init;
    auto tag = f.tag.strip.toLower;
    BuildingBlock[] result;
    foreach (b; repos.blocks.findAll(t)) {
      if (f.kind.strip.length && b.kind != kind)
        continue;
      if (f.status.strip.length && b.status != status)
        continue;
      if (f.owner.strip.length && b.owner != f.owner.strip)
        continue;
      if (tag.length && !b.tags.canFind(tag))
        continue;
      if (f.search.strip.length && !(containsText(b.id.value, f.search.strip) || containsText(b.name, f.search.strip)
          || containsText(b.description, f.search.strip) || containsText(b.capability, f.search.strip)
          || containsText(b.vendor, f.search.strip)))
        continue;
      result ~= b;
    }
    return result;
  }

  void deleteBlock(TenantId t, BuildingBlockId id, UserId actor) {
    requireTenant(t);
    auto b = loadBlock(t, id);
    requireDeletable(b);
    auto removed = repos.relationships.removeByBlock(t, id);
    size_t unlinked;
    foreach (sbb; repos.blocks.findRealizing(t, id)) {
      sbb.realizesId = BuildingBlockId.init;
      touch(sbb, actor);
      repos.blocks.save(sbb);
      unlinked++;
    }
    repos.blocks.removeById(t, id);
    emit("block.deleted", t, id.value, Json([
        "relationshipsRemoved": Json(removed), "realizationsCleared": Json(unlinked)
      ]));
  }

  /// SBB.realizesId must reference an existing, not retired ABB.
  protected void checkRealization(const BuildingBlock b) {
    if (b.realizesId.isNull)
      return;
    auto abb = repos.blocks.findById(b.tenantId, b.realizesId);
    if (abb.isNull)
      throw ArchitectureException.invalid("Realized building block '" ~ b.realizesId.value ~ "' does not exist");
    if (abb.kind != BlockKind.architecture)
      throw ArchitectureException.ruleViolation("A solution building block realizes an architecture building block; '"
          ~ abb.id.value ~ "' is a " ~ cast(string) abb.kind ~ " building block");
    if (abb.status == LifecycleStatus.retired)
      throw ArchitectureException.ruleViolation("Architecture building block '" ~ abb.id.value ~ "' is retired");
  }
}

/// Apply the set values (status is handled by the caller: lifecycle rules).
void applyValues(ref BuildingBlock b, const BlockValues v) {
  static string text(const Nullable!string n) {
    return n.get.strip.idup;
  }

  if (!v.name.isNull)
    b.name = text(v.name);
  if (!v.description.isNull)
    b.description = v.description.get.idup;
  if (!v.owner.isNull)
    b.owner = text(v.owner);
  if (!v.versionLabel.isNull)
    b.versionLabel = text(v.versionLabel);
  if (!v.tags.isNull)
    b.tags = normalizeList(v.tags.get, true);
  if (!v.elementType.isNull)
    b.elementType = text(v.elementType).length ? elementTypeInfo(text(v.elementType)).name : "";
  if (!v.viewpoint.isNull)
    b.viewpoint = text(v.viewpoint);
  if (!v.capability.isNull)
    b.capability = text(v.capability);
  if (!v.interfaces.isNull)
    b.interfaces = normalizeList(v.interfaces.get);
  if (!v.realizesId.isNull)
    b.realizesId = BuildingBlockId(text(v.realizesId));
  if (!v.vendor.isNull)
    b.vendor = text(v.vendor);
  if (!v.endpoint.isNull)
    b.endpoint = text(v.endpoint);
  if (!v.dataClassification.isNull)
    b.dataClassification = parseDataClassification(text(v.dataClassification));
  if (!v.dataOwner.isNull)
    b.dataOwner = text(v.dataOwner);
  if (!v.sourceSystem.isNull)
    b.sourceSystem = text(v.sourceSystem);
  if (!v.factSheetType.isNull)
    b.factSheetType = parseFactSheetType(text(v.factSheetType));
  if (!v.factSheetId.isNull)
    b.factSheetId = text(v.factSheetId);
  if (!v.validUntil.isNull)
    b.validUntil = parseIsoTime(text(v.validUntil));
}
