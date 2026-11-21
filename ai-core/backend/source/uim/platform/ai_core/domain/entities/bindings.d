/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Building blocks of executables and configurations.
module uim.platform.ai_core.domain.entities.bindings;

import uim.platform.ai_core;

mixin(ShowModule!());

@safe:

/// A parameter declared by an executable. Parameters without a default are
/// mandatory in every configuration.
struct ParameterDef {
  string key;
  string type = "string";
  string defaultValue;
  string description;

  bool required() const {
    return defaultValue.length == 0;
  }
}

/// An input or output artifact slot declared by an executable.
struct ArtifactSlot {
  string key;
  ArtifactKind kind = ArtifactKind.other;
  string description;
}

/// Binding of an artifact slot to a concrete artifact.
struct ArtifactRef {
  string key;
  ArtifactId artifactId;
}

/// "key:kind" ↔ ArtifactSlot (OData / CLI text form).
string slotText(const ArtifactSlot s) {
  return s.key ~ ":" ~ cast(string) s.kind;
}

ArtifactSlot parseSlot(string text) {
  auto t = text.strip;
  auto pos = t.indexOf(':');
  if (pos < 0)
    return ArtifactSlot(t, ArtifactKind.other);
  return ArtifactSlot(t[0 .. pos].strip, parseDomainEnum!ArtifactKind(t[pos + 1 .. $], "artifact kind"));
}

/// "key=default" ↔ ParameterDef (OData / CLI text form; "key" = mandatory).
string parameterText(const ParameterDef p) {
  return p.defaultValue.length > 0 ? p.key ~ "=" ~ p.defaultValue : p.key;
}

ParameterDef parseParameter(string text) {
  auto l = parseLabel(text);
  return ParameterDef(l.key, "string", l.value);
}

/// "key=artifactId" ↔ ArtifactRef
string refText(const ArtifactRef r) {
  return r.key ~ "=" ~ r.artifactId.value;
}

ArtifactRef parseRef(string text) {
  auto l = parseLabel(text);
  return ArtifactRef(l.key, ArtifactId(l.value));
}

/// Keys: 1-256 characters of [A-Za-z0-9_.-].
bool isValidBindingKey(string key) pure {
  if (key.length == 0 || key.length > 256)
    return false;
  foreach (c; key)
    if (!(isAlphaNum(c) || c == '_' || c == '-' || c == '.'))
      return false;
  return true;
}

///
unittest {
  assert(parseSlot("model:model") == ArtifactSlot("model", ArtifactKind.model));
  assert(parseSlot("raw") == ArtifactSlot("raw", ArtifactKind.other));
  assert(slotText(ArtifactSlot("d", ArtifactKind.dataset)) == "d:dataset");
  assert(parseParameter("epochs=10") == ParameterDef("epochs", "string", "10"));
  assert(parseParameter("lr").required);
  assert(parseRef("training=abc").artifactId.value == "abc");
  assert(isValidBindingKey("learning_rate") && !isValidBindingKey("bad key"));
}
