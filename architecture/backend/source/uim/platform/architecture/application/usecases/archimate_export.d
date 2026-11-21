/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Interactor: export to the ArchiMate Model Exchange File Format 3.1
/// (The Open Group) — importable by Archi, BiZZdesign, Sparx EA, LeanIX, ...
/// Building blocks become elements (their TOGAF kind, status, version and
/// owner become properties); relationships and SBB realizations become
/// relationships.
module uim.platform.architecture.application.usecases.archimate_export;

import uim.platform.architecture;

mixin(ShowModule!());

@safe:

enum string archimateNamespace = "http://www.opengroup.org/xsd/archimate/3.0/";

class ExportArchiMateUseCase : ArchitectureInteractor, IExportArchitecture {
  this(ArchitectureRepositories repos, IClock clock) {
    super(repos, clock, null);
  }

  string exportArchiMate(TenantId t, string modelName = "") {
    requireTenant(t);
    auto blocks = repos.blocks.findAll(t);
    auto relationships = repos.relationships.findAll(t);
    return archimateExchangeXml(modelName.strip.length ? modelName.strip : "Architecture repository (" ~ t.value ~ ")",
      t.value, blocks, relationships);
  }
}

/// The exchange document (pure function, used by tests and the CLI).
string archimateExchangeXml(string modelName, string tenant, BuildingBlock[] blocks, Relationship[] relationships) {
  enum properties = ["kind", "status", "version", "owner"];
  auto x = appender!string;
  x ~= `<?xml version="1.0" encoding="UTF-8"?>` ~ "\n";
  x ~= `<model xmlns="` ~ archimateNamespace ~ `" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"`;
  x ~= ` xsi:schemaLocation="` ~ archimateNamespace ~ ` http://www.opengroup.org/xsd/archimate/3.1/archimate3_Diagram.xsd"`;
  x ~= ` identifier="` ~ xmlId("model-" ~ tenant) ~ `">` ~ "\n";
  x ~= `  <name xml:lang="en">` ~ xmlEscape(modelName) ~ "</name>\n";

  if (blocks.length) {
    x ~= "  <elements>\n";
    foreach (b; blocks) {
      x ~= `    <element identifier="` ~ xmlId(b.id.value) ~ `" xsi:type="` ~ b.effectiveElementType ~ `">` ~ "\n";
      x ~= `      <name xml:lang="en">` ~ xmlEscape(b.name) ~ "</name>\n";
      if (b.description.length)
        x ~= `      <documentation xml:lang="en">` ~ xmlEscape(b.description) ~ "</documentation>\n";
      x ~= "      <properties>\n";
      foreach (i, value; [abbreviation(b.kind), cast(string) b.status, b.versionLabel, b.owner])
        if (value.length)
          x ~= `        <property propertyDefinitionRef="` ~ xmlId("prop-" ~ properties[i]) ~ `"><value xml:lang="en">`
            ~ xmlEscape(value) ~ "</value></property>\n";
      x ~= "      </properties>\n";
      x ~= "    </element>\n";
    }
    x ~= "  </elements>\n";
  }

  auto ids = blocks.map!(b => b.id.value).array;
  bool exported(BuildingBlockId id) {
    return ids.canFind(id.value);
  }

  auto relationshipXml = appender!string;
  foreach (r; relationships)
    if (exported(r.sourceId) && exported(r.targetId)) {
      relationshipXml ~= `    <relationship identifier="` ~ xmlId(r.id.value) ~ `" source="` ~ xmlId(r.sourceId.value)
        ~ `" target="` ~ xmlId(r.targetId.value) ~ `" xsi:type="` ~ exchangeName(r.type) ~ `"`;
      relationshipXml ~= r.description.length ? ">\n      <name xml:lang=\"en\">" ~ xmlEscape(r.description) ~ "</name>\n    </relationship>\n"
        : "/>\n";
    }
  foreach (b; blocks)
    if (!b.realizesId.isNull && exported(b.realizesId))
      relationshipXml ~= `    <relationship identifier="` ~ xmlId("realizes-" ~ b.id.value) ~ `" source="` ~ xmlId(b.id.value)
        ~ `" target="` ~ xmlId(b.realizesId.value) ~ `" xsi:type="Realization"/>` ~ "\n";
  if (relationshipXml.data.length)
    x ~= "  <relationships>\n" ~ relationshipXml.data ~ "  </relationships>\n";

  x ~= "  <propertyDefinitions>\n";
  foreach (p; properties)
    x ~= `    <propertyDefinition identifier="` ~ xmlId("prop-" ~ p) ~ `" type="string"><name xml:lang="en">` ~ p
      ~ "</name></propertyDefinition>\n";
  x ~= "  </propertyDefinitions>\n";
  x ~= "</model>\n";
  return x.data;
}

/// xs:ID: must start with a letter; anything but [A-Za-z0-9_.-] becomes '_'.
string xmlId(string id) pure {
  string result = "id-";
  foreach (c; id)
    result ~= (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || (c >= '0' && c <= '9') || c == '-' || c == '.' || c == '_'
      ? c : '_';
  return result;
}

string xmlEscape(string text) pure {
  auto r = appender!string;
  foreach (c; text) {
    switch (c) {
    case '&':
      r ~= "&amp;";
      break;
    case '<':
      r ~= "&lt;";
      break;
    case '>':
      r ~= "&gt;";
      break;
    case '"':
      r ~= "&quot;";
      break;
    default:
      r ~= c;
    }
  }
  return r.data;
}

///
unittest {
  BuildingBlock abb;
  abb.id = BuildingBlockId("abb-crm");
  abb.kind = BlockKind.architecture;
  abb.name = "CRM & Sales";
  BuildingBlock sbb;
  sbb.id = BuildingBlockId("sbb-crm");
  sbb.kind = BlockKind.solution;
  sbb.name = "Sales Cloud";
  sbb.realizesId = abb.id;
  Relationship r;
  r.id = RelationshipId("r1");
  r.type = ArchiMateRelationshipType.serving;
  r.sourceId = sbb.id;
  r.targetId = abb.id;

  auto xml = archimateExchangeXml("Test", "t1", [abb, sbb], [r]);
  assert(xml.canFind(`<element identifier="id-abb-crm" xsi:type="ApplicationComponent">`));
  assert(xml.canFind("CRM &amp; Sales"));
  assert(xml.canFind(`xsi:type="Serving"/>`) && xml.canFind(`identifier="id-realizes-sbb-crm"`));
  assert(xml.canFind(`<value xml:lang="en">ABB</value>`));
  assert(xmlId("a b") == "id-a_b");
}
