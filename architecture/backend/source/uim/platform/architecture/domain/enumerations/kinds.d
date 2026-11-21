/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// TOGAF building block kinds (Enterprise Continuum).
module uim.platform.architecture.domain.enumerations.kinds;

import uim.platform.architecture;

mixin(ShowModule!());

@safe:

enum BlockKind : string {
  architecture = "architecture", /// ABB — what is needed (capability, requirements); vendor neutral
  solution = "solution", /// SBB — how it is realized (product, component); realizes an ABB
  data = "data", /// DBB — information / data objects
  business = "business", /// BBB — business functions, processes, services
  technology = "technology" /// TBB — platforms, nodes, system software
}

/// The usual abbreviation ("ABB", "SBB", ...).
string abbreviation(BlockKind kind) pure {
  final switch (kind) {
  case BlockKind.architecture:
    return "ABB";
  case BlockKind.solution:
    return "SBB";
  case BlockKind.data:
    return "DBB";
  case BlockKind.business:
    return "BBB";
  case BlockKind.technology:
    return "TBB";
  }
}

/// The ArchiMate element type used when a block does not name one.
string defaultElementType(BlockKind kind) pure {
  final switch (kind) {
  case BlockKind.architecture:
  case BlockKind.solution:
    return "ApplicationComponent";
  case BlockKind.data:
    return "DataObject";
  case BlockKind.business:
    return "BusinessProcess";
  case BlockKind.technology:
    return "Node";
  }
}

/// Parse "architecture", "ABB", "solution-building-block", ...
BlockKind parseBlockKind(string text) {
  auto key = enumKey(text);
  foreach (k; [EnumMembers!BlockKind])
    if (key == enumKey(abbreviation(k)) || key == k ~ "block" || key == k ~ "buildingblock")
      return k;
  return parseEnumValue!BlockKind(text, "Building block kind");
}

///
unittest {
  assert(parseBlockKind("ABB") == BlockKind.architecture);
  assert(parseBlockKind("solution") == BlockKind.solution);
  assert(parseBlockKind("Technology-Building-Block") == BlockKind.technology);
  assert(abbreviation(BlockKind.data) == "DBB" && defaultElementType(BlockKind.data) == "DataObject");
  assert(failsWith(ArchitectureErrorKind.invalid, () { parseBlockKind("pattern"); }));
}

private import std.traits : EnumMembers;
