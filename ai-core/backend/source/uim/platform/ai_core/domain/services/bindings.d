/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Consistency of configurations with their executable: every bound
/// parameter and input artifact must be declared, mandatory parameters and
/// all input slots must be bound, artifacts must belong to the scenario and
/// match the kind of their slot.
module uim.platform.ai_core.domain.services.bindings;

import uim.platform.ai_core;

mixin(ShowModule!());

@safe:

void checkParameterBindings(const Executable e, const Label[] bindings) {
  foreach (b; bindings)
    if (!e.parameters.any!(p => p.key == b.key))
      throw AiCoreException.invalid("Executable '" ~ e.id.value ~ "' has no parameter '" ~ b.key ~ "'");
  foreach (p; e.parameters)
    if (p.required && labelValue(bindings, p.key).length == 0)
      throw AiCoreException.invalid("Parameter '" ~ p.key ~ "' of executable '" ~ e.id.value ~ "' is mandatory");
}

/// lookup returns Artifact.init for unknown ids.
void checkArtifactBindings(const Executable e, const ArtifactRef[] refs, scope Artifact delegate(ArtifactId) @safe lookup) {
  string[] bound;
  foreach (r; refs) {
    auto slot = e.inputArtifacts.find!(s => s.key == r.key);
    if (slot.empty)
      throw AiCoreException.invalid("Executable '" ~ e.id.value ~ "' has no input artifact '" ~ r.key ~ "'");
    if (bound.canFind(r.key))
      throw AiCoreException.invalid("Input artifact '" ~ r.key ~ "' is bound twice");
    bound ~= r.key;
    auto a = lookup(r.artifactId);
    if (a.isNull)
      throw AiCoreException.invalid("Artifact '" ~ r.artifactId.value ~ "' bound to '" ~ r.key ~ "' does not exist");
    if (a.scenarioId != e.scenarioId)
      throw AiCoreException.invalid("Artifact '" ~ a.id.value ~ "' belongs to scenario '" ~ a.scenarioId.value ~ "'");
    if (slot.front.kind != ArtifactKind.other && a.kind != slot.front.kind)
      throw AiCoreException.invalid("Input artifact '" ~ r.key ~ "' expects a " ~ cast(string) slot.front.kind
          ~ ", artifact '" ~ a.id.value ~ "' is a " ~ cast(string) a.kind);
  }
  foreach (s; e.inputArtifacts)
    if (!bound.canFind(s.key))
      throw AiCoreException.invalid("Input artifact '" ~ s.key ~ "' of executable '" ~ e.id.value ~ "' is not bound");
}

/// The effective parameters of a run: bindings plus defaults.
Label[] effectiveParameters(const Executable e, const Label[] bindings) {
  Label[] result;
  foreach (p; e.parameters) {
    auto v = labelValue(bindings, p.key);
    result ~= Label(p.key, v.length > 0 ? v : p.defaultValue);
  }
  return result;
}

///
unittest {
  Executable e;
  e.id = ExecutableId("train");
  e.scenarioId = ScenarioId("s1");
  e.parameters = [ParameterDef("epochs", "string", "10"), ParameterDef("dataset")];
  e.inputArtifacts = [ArtifactSlot("data", ArtifactKind.dataset)];

  checkParameterBindings(e, [Label("dataset", "x")]);
  assert(failsWith(AiCoreErrorKind.invalid, () { checkParameterBindings(e, []); }));
  assert(failsWith(AiCoreErrorKind.invalid, () { checkParameterBindings(e, [Label("dataset", "x"), Label("foo", "1")]); }));
  assert(effectiveParameters(e, [Label("dataset", "x")]) == [Label("epochs", "10"), Label("dataset", "x")]);

  Artifact a;
  a.id = ArtifactId("a1");
  a.scenarioId = ScenarioId("s1");
  a.kind = ArtifactKind.dataset;
  auto lookup = (ArtifactId id) @safe => id.value == "a1" ? a : Artifact.init;
  checkArtifactBindings(e, [ArtifactRef("data", ArtifactId("a1"))], lookup);
  assert(failsWith(AiCoreErrorKind.invalid, () { checkArtifactBindings(e, [], lookup); }));
  assert(failsWith(AiCoreErrorKind.invalid, () { checkArtifactBindings(e, [ArtifactRef("data", ArtifactId("zz"))], lookup); }));
  a.kind = ArtifactKind.model;
  assert(failsWith(AiCoreErrorKind.invalid, () { checkArtifactBindings(e, [ArtifactRef("data", ArtifactId("a1"))], lookup); }));
}
