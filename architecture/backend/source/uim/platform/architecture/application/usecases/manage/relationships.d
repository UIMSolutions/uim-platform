/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Interactor: ArchiMate relationships between building blocks.
module uim.platform.architecture.application.usecases.manage.relationships;

import uim.platform.architecture;

mixin(ShowModule!());

@safe:

class ManageRelationshipsUseCase : ArchitectureInteractor, IManageRelationships {
  this(ArchitectureRepositories repos, IClock clock, IArchitectureEventPublisher events = null) {
    super(repos, clock, events);
  }

  Relationship createRelationship(CreateRelationshipRequest r) {
    requireTenant(r.tenantId);
    Relationship rel;
    rel.tenantId = r.tenantId;
    rel.type = parseRelationshipType(r.type);
    requireText(r.sourceId, "Source building block");
    requireText(r.targetId, "Target building block");
    rel.sourceId = BuildingBlockId(r.sourceId.strip);
    rel.targetId = BuildingBlockId(r.targetId.strip);
    rel.description = r.description;

    auto source = repos.blocks.findById(r.tenantId, rel.sourceId);
    if (source.isNull)
      throw ArchitectureException.invalid("Source building block '" ~ rel.sourceId.value ~ "' does not exist");
    auto target = repos.blocks.findById(r.tenantId, rel.targetId);
    if (target.isNull)
      throw ArchitectureException.invalid("Target building block '" ~ rel.targetId.value ~ "' does not exist");
    requireValidRelationship(source, target, rel.type);

    foreach (other; repos.relationships.findByBlock(r.tenantId, rel.sourceId))
      if (other.sourceId == rel.sourceId && other.targetId == rel.targetId && other.type == rel.type)
        throw ArchitectureException.conflict(format("%s %s → %s already exists (%s)", cast(string) rel.type,
            rel.sourceId.value, rel.targetId.value, other.id.value));

    auto id = r.id.strip;
    rel.id = RelationshipId(id.length ? id : "rel-" ~ newResourceId());
    if (repos.relationships.existsById(r.tenantId, rel.id))
      throw ArchitectureException.conflict("Relationship '" ~ rel.id.value ~ "' already exists");
    rel.validate();
    stamp(rel, r.actor);
    repos.relationships.save(rel);
    emit("relationship.created", rel.tenantId, rel.id.value, Json([
        "type": Json(cast(string) rel.type), "source": Json(rel.sourceId.value), "target": Json(rel.targetId.value)
      ]));
    return rel;
  }

  Relationship updateRelationship(UpdateRelationshipRequest r) {
    auto rel = getRelationship(r.tenantId, r.id);
    if (!r.description.isNull)
      rel.description = r.description.get;
    rel.validate();
    touch(rel, r.actor);
    repos.relationships.save(rel);
    emit("relationship.updated", rel.tenantId, rel.id.value);
    return rel;
  }

  Relationship getRelationship(TenantId t, RelationshipId id) {
    requireTenant(t);
    auto rel = repos.relationships.findById(t, id);
    if (rel.isNull)
      throw ArchitectureException.notFound("Relationship '" ~ id.value ~ "'");
    return rel;
  }

  Relationship[] listRelationships(TenantId t, RelationshipFilter f = RelationshipFilter.init) {
    requireTenant(t);
    auto all = f.blockId.strip.length ? repos.relationships.findByBlock(t, BuildingBlockId(f.blockId.strip))
      : repos.relationships.findAll(t);
    if (f.type.strip.length == 0)
      return all;
    auto type = parseRelationshipType(f.type);
    return all.filter!(r => r.type == type).array;
  }

  void deleteRelationship(TenantId t, RelationshipId id, UserId actor) {
    getRelationship(t, id);
    repos.relationships.removeById(t, id);
    emit("relationship.deleted", t, id.value);
  }
}
