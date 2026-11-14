/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.identity_authentication.presentation.odata.metadata;

import std.array : appender;
import uim.platform.identity_authentication;
import uim.platform.identity_authentication.presentation.odata.model;

mixin(ShowModule!());

@safe:

/// Escape a string for use in an XML attribute.
string xmlEscape(string value) pure {
  return value.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")
    .replace("\"", "&quot;").replace("'", "&apos;");
}

/// Generate the CSDL (EDMX 4.0) document served at $metadata.
string buildMetadataXml(const ODataServiceModel model) {
  auto x = appender!string;
  auto ns = model.namespace_;

  x ~= `<?xml version="1.0" encoding="utf-8"?>` ~ "\n";
  x ~= `<edmx:Edmx Version="4.0" xmlns:edmx="http://docs.oasis-open.org/odata/ns/edmx">` ~ "\n";
  x ~= `  <edmx:Reference Uri="https://oasis-tcs.github.io/odata-vocabularies/vocabularies/Org.OData.Capabilities.V1.xml">`
    ~ `<edmx:Include Alias="Capabilities" Namespace="Org.OData.Capabilities.V1"/></edmx:Reference>` ~ "\n";
  x ~= `  <edmx:Reference Uri="https://sap.github.io/odata-vocabularies/vocabularies/Common.xml">`
    ~ `<edmx:Include Alias="Common" Namespace="com.sap.vocabularies.Common.v1"/></edmx:Reference>` ~ "\n";
  x ~= `  <edmx:DataServices>` ~ "\n";
  x ~= `    <Schema Namespace="` ~ ns ~ `" xmlns="http://docs.oasis-open.org/odata/ns/edm">` ~ "\n";

  void properties(const ODataPropertyDef[] props) {
    foreach (prop; props) {
      x ~= `        <Property Name="` ~ prop.name ~ `" Type="` ~ prop.edmType ~ `"`;
      if (!prop.nullable)
        x ~= ` Nullable="false"`;
      x ~= "/>\n";
    }
  }

  foreach (set; model.entitySets) {
    x ~= `      <EntityType Name="` ~ set.entityType ~ `">` ~ "\n";
    x ~= `        <Key><PropertyRef Name="` ~ set.key ~ `"/></Key>` ~ "\n";
    properties(set.properties);
    x ~= "      </EntityType>\n";
  }

  foreach (ct; model.complexTypes) {
    x ~= `      <ComplexType Name="` ~ ct.name ~ `">` ~ "\n";
    properties(ct.properties);
    x ~= "      </ComplexType>\n";
  }

  foreach (action; model.actions) {
    x ~= `      <Action Name="` ~ action.name ~ `" IsBound="false">` ~ "\n";
    foreach (param; action.parameters)
      x ~= `        <Parameter Name="` ~ param.name ~ `" Type="` ~ param.edmType ~ `"`
        ~ (param.nullable ? "" : ` Nullable="false"`) ~ "/>\n";
    if (action.returnType.length > 0)
      x ~= `        <ReturnType Type="` ~ action.returnType ~ `"/>` ~ "\n";
    x ~= "      </Action>\n";
  }

  x ~= `      <EntityContainer Name="` ~ model.containerName ~ `">` ~ "\n";
  foreach (set; model.entitySets) {
    if (set.singleton)
      x ~= `        <Singleton Name="` ~ set.name ~ `" Type="` ~ model.qualified(set.entityType) ~ `"/>` ~ "\n";
    else
      x ~= `        <EntitySet Name="` ~ set.name ~ `" EntityType="` ~ model.qualified(set.entityType) ~ `"/>` ~ "\n";
  }
  foreach (action; model.actions) {
    x ~= `        <ActionImport Name="` ~ action.name ~ `" Action="` ~ model.qualified(action.name) ~ `"`;
    if (action.returnEntitySet.length > 0)
      x ~= ` EntitySet="` ~ action.returnEntitySet ~ `"`;
    x ~= "/>\n";
  }
  x ~= "      </EntityContainer>\n";

  // ── Annotations: labels and capabilities ────────────────────────────────
  foreach (set; model.entitySets) {
    foreach (prop; set.properties) {
      if (prop.label.length == 0)
        continue;
      x ~= `      <Annotations Target="` ~ model.qualified(set.entityType) ~ "/" ~ prop.name ~ `">`
        ~ `<Annotation Term="Common.Label" String="` ~ xmlEscape(prop.label) ~ `"/></Annotations>` ~ "\n";
    }
    if (set.singleton)
      continue;

    auto target = model.qualified(model.containerName) ~ "/" ~ set.name;
    x ~= `      <Annotations Target="` ~ target ~ `">` ~ "\n";
    x ~= `        <Annotation Term="Capabilities.InsertRestrictions"><Record><PropertyValue Property="Insertable" Bool="`
      ~ (set.insertable ? "true" : "false") ~ `"/></Record></Annotation>` ~ "\n";
    x ~= `        <Annotation Term="Capabilities.UpdateRestrictions"><Record><PropertyValue Property="Updatable" Bool="`
      ~ (set.updatable ? "true" : "false") ~ `"/></Record></Annotation>` ~ "\n";
    x ~= `        <Annotation Term="Capabilities.DeleteRestrictions"><Record><PropertyValue Property="Deletable" Bool="`
      ~ (set.deletable ? "true" : "false") ~ `"/></Record></Annotation>` ~ "\n";
    x ~= "      </Annotations>\n";
  }

  x ~= "    </Schema>\n";
  x ~= "  </edmx:DataServices>\n";
  x ~= "</edmx:Edmx>\n";
  return x.data;
}

/// The OData service document (JSON) listing all entity sets and singletons.
Json buildServiceDocument(const ODataServiceModel model, string metadataUrl) {
  auto value = Json.emptyArray;
  foreach (set; model.entitySets) {
    auto entry = Json.emptyObject;
    entry["name"] = set.name;
    entry["kind"] = set.singleton ? "Singleton" : "EntitySet";
    entry["url"] = set.name;
    value ~= entry;
  }
  auto doc = Json.emptyObject;
  doc["@odata.context"] = metadataUrl;
  doc["value"] = value;
  return doc;
}

///
unittest {
  mixin(ShowTest!("buildMetadataXml"));

  auto xml = buildMetadataXml(identityODataModel());
  assert(xml.canFind(`<EntitySet Name="Users" EntityType="uim.ias.User"/>`));
  assert(xml.canFind(`<Singleton Name="Statistics" Type="uim.ias.Statistic"/>`));
  assert(xml.canFind(`<ActionImport Name="SetUserStatus" Action="uim.ias.SetUserStatus" EntitySet="Users"/>`));
  assert(xml.canFind(`<Parameter Name="id" Type="Edm.String" Nullable="false"/>`));
  assert(xml.canFind(`<Property Name="failedLoginAttempts" Type="Edm.Int32"/>`));
  assert(!xml.canFind("passwordHash") && !xml.canFind("mfaSecret") && !xml.canFind("clientSecretHash"));
  assert(xmlEscape(`a<b & "c"`) == "a&lt;b &amp; &quot;c&quot;");
}
