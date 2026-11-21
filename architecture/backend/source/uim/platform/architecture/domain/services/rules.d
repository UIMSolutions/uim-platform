/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Relationship rules: a pragmatic subset of the ArchiMate 3.2 relationship
/// table (Appendix B) plus TOGAF and governance rules.
///
///   composition / aggregation  same domain, or the whole is a composite (Grouping, Plateau, ...)
///   assignment                 the source is an active structure element
///   access                     behavior/active structure → passive structure
///   serving / triggering / flow  between behavior or active structure elements
///   influence                  the target is a motivation element
///   specialization             between elements of the same type
///   realization                never ABB → SBB (an SBB realizes an ABB, not vice versa)
///   association                always allowed
/// No relationship to itself; retired blocks take no new relationships.
module uim.platform.architecture.domain.services.rules;

import uim.platform.architecture;

mixin(ShowModule!());

@safe:

private alias T = ArchiMateRelationshipType;
private alias A = ArchiMateAspect;

/// Reason why the relationship is not allowed, or "" if it is.
string relationshipViolation(const BuildingBlock source, const BuildingBlock target, ArchiMateRelationshipType type) {
  if (source.id == target.id)
    return "A building block cannot relate to itself";
  if (source.status == LifecycleStatus.retired || target.status == LifecycleStatus.retired)
    return "Retired building blocks cannot get new relationships";

  auto s = elementTypeInfo(source.effectiveElementType);
  auto t = elementTypeInfo(target.effectiveElementType);
  auto rel = cast(string) type;
  string notAllowed(string why) {
    return format("%s from %s (%s) to %s (%s) is not allowed: %s", rel, source.id.value, s.name, target.id.value, t.name, why);
  }

  final switch (type) {
  case T.composition, T.aggregation:
    if (s.aspect != A.composite && s.domain != t.domain)
      return notAllowed("the parts must belong to the same layer as the whole");
    break;
  case T.assignment:
    if (s.aspect != A.activeStructure)
      return notAllowed("only active structure elements are assigned");
    break;
  case T.access:
    if (t.aspect != A.passiveStructure)
      return notAllowed("only passive structure elements (data, objects, artifacts) are accessed");
    if (s.aspect == A.passiveStructure)
      return notAllowed("a passive structure element cannot access");
    break;
  case T.serving, T.triggering, T.flow:
    if (s.aspect == A.passiveStructure || t.aspect == A.passiveStructure)
      return notAllowed("passive structure elements do not serve, trigger or flow");
    if (type != T.serving && (s.aspect == A.motivation || t.aspect == A.motivation))
      return notAllowed("motivation elements have no dynamic relationships");
    break;
  case T.influence:
    if (t.aspect != A.motivation)
      return notAllowed("only motivation elements are influenced");
    break;
  case T.specialization:
    if (s.name != t.name)
      return notAllowed("specialization needs two elements of the same type");
    break;
  case T.realization:
    if (source.kind == BlockKind.architecture && target.kind == BlockKind.solution)
      return notAllowed("an architecture building block is realized by a solution building block, not vice versa");
    if (s.aspect == A.motivation)
      return notAllowed("motivation elements do not realize");
    break;
  case T.association:
    break;
  }
  return "";
}

void requireValidRelationship(const BuildingBlock source, const BuildingBlock target, ArchiMateRelationshipType type) {
  auto violation = relationshipViolation(source, target, type);
  if (violation.length > 0)
    throw ArchitectureException.ruleViolation(violation);
}

/// Direction of dependency for impact analysis: true if a change of the
/// source affects the target (target depends on source), false if a change
/// of the target affects the source. Association carries no dependency.
bool sourceImpactsTarget(ArchiMateRelationshipType type) pure {
  final switch (type) {
  case T.serving, T.realization, T.assignment, T.triggering, T.flow, T.influence:
    return true; // the served / realized / triggered element depends on the source
  case T.access, T.composition, T.aggregation, T.specialization, T.association:
    return false; // the accessor / whole / specialization depends on the target
  }
}

bool carriesDependency(ArchiMateRelationshipType type) pure {
  return type != T.association;
}

version (unittest) {
  private BuildingBlock block(string id, BlockKind kind, string element) {
    BuildingBlock b;
    b.id = BuildingBlockId(id);
    b.kind = kind;
    b.name = id;
    b.elementType = element;
    return b;
  }
}

///
unittest {
  auto app = block("app", BlockKind.solution, "ApplicationComponent");
  auto data = block("data", BlockKind.data, "DataObject");
  auto node = block("node", BlockKind.technology, "Node");
  auto abb = block("abb", BlockKind.architecture, "ApplicationComponent");
  auto goal = block("goal", BlockKind.business, "Goal");

  assert(relationshipViolation(app, data, T.access) == "");
  assert(relationshipViolation(data, app, T.access).length > 0);
  assert(relationshipViolation(node, app, T.serving) == "");
  assert(relationshipViolation(app, data, T.serving).length > 0);
  assert(relationshipViolation(node, app, T.composition).length > 0); // different layers
  assert(relationshipViolation(app, abb, T.realization) == "");
  assert(relationshipViolation(abb, app, T.realization).length > 0);
  assert(relationshipViolation(app, abb, T.specialization) == ""); // both ApplicationComponent
  assert(relationshipViolation(app, goal, T.influence) == "");
  assert(relationshipViolation(app, app, T.association).length > 0);
  app.status = LifecycleStatus.retired;
  assert(failsWith(ArchitectureErrorKind.ruleViolation, () { requireValidRelationship(app, abb, T.association); }));
  assert(sourceImpactsTarget(T.serving) && !sourceImpactsTarget(T.access));
}
