/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Which extensions a dev space effectively has, and what templates need.
module uim.platform.application_studio.domain.services.extension_resolution;

import uim.platform.application_studio;

mixin(ShowModule!());

@safe:

/// The type's predefined extensions followed by the dev space's additional ones (no duplicates).
string[] effectiveExtensions(const DevSpaceType type, const DevSpace ds) {
  return normalizedNames(type.predefinedExtensions ~ ds.extensions);
}

/// The required names that are not available (order of `required`).
string[] missingNames(const string[] required, const string[] available) {
  string[] missing;
  foreach (r; required)
    if (!available.canFind(r) && !missing.canFind(r))
      missing ~= r;
  return missing;
}

/// Extension names plus their (transitive) dependencies, resolved through `lookup`
/// (which returns Extension.init for unknown names). Unknown names are kept so that
/// the caller can report them.
string[] withDependencies(const string[] names, scope Extension delegate(string) @safe lookup) {
  string[] result;
  void add(string name, size_t depth) {
    if (result.canFind(name) || depth > 16)
      return;
    result ~= name;
    auto ext = lookup(name);
    foreach (d; ext.dependencies)
      add(d, depth + 1);
  }

  foreach (n; names)
    add(n, 0);
  return result;
}

/// A project type is supported by a dev space type (empty list = all types).
bool supportsProjectType(const DevSpaceType type, ProjectType projectType) {
  return type.supportedProjectTypes.length == 0 || type.supportedProjectTypes.canFind(projectType);
}

///
unittest {
  DevSpaceType t;
  t.predefinedExtensions = ["sap.fiori-tools", "sap.ux-help"];
  DevSpace ds;
  ds.extensions = ["sap.ux-help", "sap.cds"];
  assert(effectiveExtensions(t, ds) == ["sap.fiori-tools", "sap.ux-help", "sap.cds"]);
  assert(missingNames(["sap.cds", "sap.mdk"], effectiveExtensions(t, ds)) == ["sap.mdk"]);

  Extension lookup(string name) {
    Extension e;
    e.name = name;
    if (name == "sap.fiori-tools")
      e.dependencies = ["sap.ux-help", "sap.ui5-language"];
    if (name == "sap.ui5-language")
      e.dependencies = ["sap.fiori-tools"]; // cycle
    return e;
  }

  assert(withDependencies(["sap.fiori-tools"], &lookup) == ["sap.fiori-tools", "sap.ux-help", "sap.ui5-language"]);
  t.supportedProjectTypes = [ProjectType.sapFiori];
  assert(supportsProjectType(t, ProjectType.sapFiori) && !supportsProjectType(t, ProjectType.capJava));
}
