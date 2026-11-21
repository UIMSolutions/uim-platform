/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// The building block aggregate. One type for all TOGAF kinds; the kind
/// decides which optional attributes are meaningful and which ArchiMate
/// element types are allowed.
module uim.platform.architecture.domain.entities.building_block;

import uim.platform.architecture;

mixin(ShowModule!());

@safe:

struct BuildingBlock {
  mixin TenantEntity!BuildingBlockId;

  BlockKind kind;
  string name;
  string description;
  string owner; /// accountable team or person
  LifecycleStatus status = LifecycleStatus.proposed;
  string versionLabel = "1.0.0";
  string[] tags;

  // ArchiMate
  string elementType; /// ArchiMate 3.2 element type, e.g. "ApplicationComponent"
  string viewpoint; /// e.g. "Application Cooperation"

  // TOGAF
  string capability; /// capability provided (ABB/BBB)
  string[] interfaces; /// provided / required interfaces (e.g. "OData v4", "AMQP")
  BuildingBlockId realizesId; /// SBB only: the ABB it realizes
  string vendor; /// product / component (SBB/TBB), e.g. "PostgreSQL 16"
  string endpoint; /// deployment endpoint / URL

  // data building blocks
  string dataClassification; /// public | internal | confidential | restricted
  string dataOwner;
  string sourceSystem; /// system of record

  // SAP LeanIX cross reference
  string factSheetType;
  string factSheetId;

  long validUntil; /// std time; 0 = no planned end of life

  ArchiMateDomain domain() const {
    return elementTypeInfo(effectiveElementType).domain;
  }

  ArchiMateAspect aspect() const {
    return elementTypeInfo(effectiveElementType).aspect;
  }

  string effectiveElementType() const {
    return elementType.length > 0 ? elementType : defaultElementType(kind);
  }

  /// "ABB: Customer Relationship Management"
  string displayName() const {
    return abbreviation(kind) ~ ": " ~ name;
  }

  /// Field level invariants (cross-aggregate rules live in the use cases).
  void validate() const {
    requireResourceId(id.value, "Building block ID");
    requireText(name, "Name");
    requireMaxLength(name, 256, "Name");
    requireMaxLength(description, 5000, "Description");
    requireMaxLength(owner, 128, "Owner");
    requireText(versionLabel, "Version");
    requireMaxLength(versionLabel, 32, "Version");
    requireMaxLength(viewpoint, 128, "Viewpoint");
    requireMaxLength(capability, 256, "Capability");
    requireMaxLength(vendor, 256, "Vendor / component");
    requireMaxLength(endpoint, 1024, "Endpoint");
    requireMaxLength(dataOwner, 128, "Data owner");
    requireMaxLength(sourceSystem, 256, "Source system");
    requireMaxLength(factSheetId, 128, "LeanIX fact sheet ID");
    requireList(tags, "Tags");
    requireList(interfaces, "Interfaces");

    auto info = elementTypeInfo(effectiveElementType);
    final switch (kind) {
    case BlockKind.data:
      if (info.aspect != ArchiMateAspect.passiveStructure)
        throw ArchitectureException.invalid("A data building block must be a passive structure element (e.g. DataObject, "
            ~ "BusinessObject, Artifact), not " ~ info.name);
      break;
    case BlockKind.business:
      if (![ArchiMateDomain.business, ArchiMateDomain.strategy, ArchiMateDomain.motivation].canFind(info.domain))
        throw ArchitectureException.invalid("A business building block must be a business, strategy or motivation element, not "
            ~ info.name);
      break;
    case BlockKind.technology:
      if (info.domain != ArchiMateDomain.technology)
        throw ArchitectureException.invalid("A technology building block must be a technology element (e.g. Node, "
            ~ "SystemSoftware, TechnologyService), not " ~ info.name);
      break;
    case BlockKind.architecture, BlockKind.solution:
      break;
    }

    if (!realizesId.isNull && kind != BlockKind.solution)
      throw ArchitectureException.invalid("Only solution building blocks realize an architecture building block");
    if (realizesId == id)
      throw ArchitectureException.invalid("A building block cannot realize itself");
    if (dataClassification.length > 0)
      parseDataClassification(dataClassification);
    if (dataClassification.length > 0 && kind != BlockKind.data)
      throw ArchitectureException.invalid("Data classification applies to data building blocks only");
    if (factSheetType.length > 0)
      parseFactSheetType(factSheetType);
  }
}

///
unittest {
  BuildingBlock b;
  b.id = BuildingBlockId("abb-crm");
  b.kind = BlockKind.architecture;
  b.name = "Customer Relationship Management";
  b.validate();
  assert(b.effectiveElementType == "ApplicationComponent" && b.domain == ArchiMateDomain.application);
  assert(b.displayName == "ABB: Customer Relationship Management");

  b.realizesId = BuildingBlockId("abb-other");
  assert(failsWith(ArchitectureErrorKind.invalid, () { b.validate(); })); // ABBs don't realize

  BuildingBlock d;
  d.id = BuildingBlockId("dbb-customer");
  d.kind = BlockKind.data;
  d.name = "Customer";
  d.dataClassification = "confidential";
  d.validate();
  d.elementType = "Node";
  assert(failsWith(ArchitectureErrorKind.invalid, () { d.validate(); })); // data must be passive

  BuildingBlock t;
  t.id = BuildingBlockId("tbb-x");
  t.kind = BlockKind.technology;
  t.name = "X";
  t.elementType = "BusinessProcess";
  assert(failsWith(ArchitectureErrorKind.invalid, () { t.validate(); }));
}
