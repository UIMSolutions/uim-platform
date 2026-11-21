/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// ArchiMate 3.2: element types (with their layer/domain and aspect) and
/// relationship types. The element type of a building block determines
/// its domain and aspect, which drive the relationship rules.
module uim.platform.architecture.domain.enumerations.archimate;

import uim.platform.architecture;

mixin(ShowModule!());

@safe:

/// Layers / extensions of the ArchiMate framework.
enum ArchiMateDomain : string {
  common = "common",
  motivation = "motivation",
  strategy = "strategy",
  business = "business",
  application = "application",
  technology = "technology", /// incl. the physical elements
  implementationAndMigration = "implementationAndMigration"
}

/// Aspects of the ArchiMate framework.
enum ArchiMateAspect : string {
  activeStructure = "activeStructure",
  behavior = "behavior",
  passiveStructure = "passiveStructure",
  motivation = "motivation",
  composite = "composite"
}

/// Relationship types (structural, dependency, dynamic, other).
enum ArchiMateRelationshipType : string {
  composition = "composition",
  aggregation = "aggregation",
  assignment = "assignment",
  realization = "realization",
  serving = "serving",
  access = "access",
  influence = "influence",
  triggering = "triggering",
  flow = "flow",
  specialization = "specialization",
  association = "association"
}

struct ElementTypeInfo {
  string name; /// exchange format name, e.g. "ApplicationComponent"
  ArchiMateDomain domain;
  ArchiMateAspect aspect;
}

private alias D = ArchiMateDomain;
private alias A = ArchiMateAspect;

/// The element catalogue of ArchiMate 3.2.
immutable ElementTypeInfo[] archimateElementTypes = [
  // motivation
  ElementTypeInfo("Stakeholder", D.motivation, A.motivation),
  ElementTypeInfo("Driver", D.motivation, A.motivation),
  ElementTypeInfo("Assessment", D.motivation, A.motivation),
  ElementTypeInfo("Goal", D.motivation, A.motivation),
  ElementTypeInfo("Outcome", D.motivation, A.motivation),
  ElementTypeInfo("Principle", D.motivation, A.motivation),
  ElementTypeInfo("Requirement", D.motivation, A.motivation),
  ElementTypeInfo("Constraint", D.motivation, A.motivation),
  ElementTypeInfo("Meaning", D.motivation, A.motivation),
  ElementTypeInfo("Value", D.motivation, A.motivation),
  // strategy
  ElementTypeInfo("Resource", D.strategy, A.passiveStructure),
  ElementTypeInfo("Capability", D.strategy, A.behavior),
  ElementTypeInfo("ValueStream", D.strategy, A.behavior),
  ElementTypeInfo("CourseOfAction", D.strategy, A.behavior),
  // business
  ElementTypeInfo("BusinessActor", D.business, A.activeStructure),
  ElementTypeInfo("BusinessRole", D.business, A.activeStructure),
  ElementTypeInfo("BusinessCollaboration", D.business, A.activeStructure),
  ElementTypeInfo("BusinessInterface", D.business, A.activeStructure),
  ElementTypeInfo("BusinessProcess", D.business, A.behavior),
  ElementTypeInfo("BusinessFunction", D.business, A.behavior),
  ElementTypeInfo("BusinessInteraction", D.business, A.behavior),
  ElementTypeInfo("BusinessEvent", D.business, A.behavior),
  ElementTypeInfo("BusinessService", D.business, A.behavior),
  ElementTypeInfo("BusinessObject", D.business, A.passiveStructure),
  ElementTypeInfo("Contract", D.business, A.passiveStructure),
  ElementTypeInfo("Representation", D.business, A.passiveStructure),
  ElementTypeInfo("Product", D.business, A.composite),
  // application
  ElementTypeInfo("ApplicationComponent", D.application, A.activeStructure),
  ElementTypeInfo("ApplicationCollaboration", D.application, A.activeStructure),
  ElementTypeInfo("ApplicationInterface", D.application, A.activeStructure),
  ElementTypeInfo("ApplicationFunction", D.application, A.behavior),
  ElementTypeInfo("ApplicationInteraction", D.application, A.behavior),
  ElementTypeInfo("ApplicationProcess", D.application, A.behavior),
  ElementTypeInfo("ApplicationEvent", D.application, A.behavior),
  ElementTypeInfo("ApplicationService", D.application, A.behavior),
  ElementTypeInfo("DataObject", D.application, A.passiveStructure),
  // technology (incl. physical)
  ElementTypeInfo("Node", D.technology, A.activeStructure),
  ElementTypeInfo("Device", D.technology, A.activeStructure),
  ElementTypeInfo("SystemSoftware", D.technology, A.activeStructure),
  ElementTypeInfo("TechnologyCollaboration", D.technology, A.activeStructure),
  ElementTypeInfo("TechnologyInterface", D.technology, A.activeStructure),
  ElementTypeInfo("Path", D.technology, A.activeStructure),
  ElementTypeInfo("CommunicationNetwork", D.technology, A.activeStructure),
  ElementTypeInfo("TechnologyFunction", D.technology, A.behavior),
  ElementTypeInfo("TechnologyProcess", D.technology, A.behavior),
  ElementTypeInfo("TechnologyInteraction", D.technology, A.behavior),
  ElementTypeInfo("TechnologyEvent", D.technology, A.behavior),
  ElementTypeInfo("TechnologyService", D.technology, A.behavior),
  ElementTypeInfo("Artifact", D.technology, A.passiveStructure),
  ElementTypeInfo("Equipment", D.technology, A.activeStructure),
  ElementTypeInfo("Facility", D.technology, A.activeStructure),
  ElementTypeInfo("DistributionNetwork", D.technology, A.activeStructure),
  ElementTypeInfo("Material", D.technology, A.passiveStructure),
  // implementation & migration
  ElementTypeInfo("WorkPackage", D.implementationAndMigration, A.behavior),
  ElementTypeInfo("Deliverable", D.implementationAndMigration, A.passiveStructure),
  ElementTypeInfo("ImplementationEvent", D.implementationAndMigration, A.behavior),
  ElementTypeInfo("Plateau", D.implementationAndMigration, A.composite),
  ElementTypeInfo("Gap", D.implementationAndMigration, A.composite),
  // composite / common
  ElementTypeInfo("Grouping", D.common, A.composite),
  ElementTypeInfo("Location", D.common, A.composite),
];

/// The names of all element types.
string[] archimateElementNames() {
  return archimateElementTypes.map!(e => cast(string) e.name).array;
}

/// Look up an element type (canonical spelling); throws invalid if unknown.
ElementTypeInfo elementTypeInfo(string name) {
  auto canonical = parseNamedValue(name, archimateElementNames(), "ArchiMate element type");
  foreach (e; archimateElementTypes)
    if (e.name == canonical)
      return e;
  assert(0);
}

bool isKnownElementType(string name) {
  auto key = enumKey(name);
  return archimateElementTypes.any!(e => enumKey(e.name) == key);
}

/// "serving" → "Serving" (exchange format xsi:type).
string exchangeName(ArchiMateRelationshipType t) pure {
  auto s = cast(string) t;
  return [cast(char)(s[0] - 32)].idup ~ s[1 .. $];
}

ArchiMateRelationshipType parseRelationshipType(string text) {
  // historic spellings: "used-by" / "uses" (ArchiMate 2) map to serving
  switch (enumKey(text)) {
  case "usedby", "uses":
    return ArchiMateRelationshipType.serving;
  case "realisation":
    return ArchiMateRelationshipType.realization;
  default:
    return parseEnumValue!ArchiMateRelationshipType(text, "Relationship type");
  }
}

///
unittest {
  auto info = elementTypeInfo("application-component");
  assert(info.name == "ApplicationComponent" && info.domain == ArchiMateDomain.application);
  assert(info.aspect == ArchiMateAspect.activeStructure);
  assert(elementTypeInfo("DataObject").aspect == ArchiMateAspect.passiveStructure);
  assert(isKnownElementType("node") && !isKnownElementType("Server"));
  assert(failsWith(ArchitectureErrorKind.invalid, () { elementTypeInfo("Server"); }));
  assert(exchangeName(ArchiMateRelationshipType.serving) == "Serving");
  assert(parseRelationshipType("used-by") == ArchiMateRelationshipType.serving);
  assert(archimateElementTypes.length == 60);
}
