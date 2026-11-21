/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// A typed, directed ArchiMate relationship between two building blocks.
module uim.platform.architecture.domain.entities.relationship;

import uim.platform.architecture;

mixin(ShowModule!());

@safe:

struct Relationship {
  mixin TenantEntity!RelationshipId;

  ArchiMateRelationshipType type;
  BuildingBlockId sourceId;
  BuildingBlockId targetId;
  string description;

  void validate() const {
    requireResourceId(id.value, "Relationship ID");
    requireText(sourceId.value, "Source building block");
    requireText(targetId.value, "Target building block");
    requireMaxLength(description, 1000, "Description");
  }

  bool involves(BuildingBlockId block) const {
    return sourceId == block || targetId == block;
  }
}

///
unittest {
  Relationship r;
  r.id = RelationshipId("r1");
  r.type = ArchiMateRelationshipType.serving;
  r.sourceId = BuildingBlockId("a");
  r.targetId = BuildingBlockId("b");
  r.validate();
  assert(r.involves(BuildingBlockId("b")) && !r.involves(BuildingBlockId("c")));
  r.targetId = BuildingBlockId.init;
  assert(failsWith(ArchitectureErrorKind.invalid, () { r.validate(); }));
}
