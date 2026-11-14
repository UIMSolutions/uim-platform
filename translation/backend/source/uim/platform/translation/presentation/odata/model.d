/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.translation.presentation.odata.model;

import uim.platform.translation;
import uim.platform.translation.presentation.resources;

mixin(ShowModule!());

@safe:

/// Primitive EDM types used by the service.
enum Edm : string {
  string_ = "Edm.String",
  int32 = "Edm.Int32",
  boolean = "Edm.Boolean",
  int64 = "Edm.Int64",
  dateTimeOffset = "Edm.DateTimeOffset",
}

/// A structural property of an entity or complex type.
struct ODataPropertyDef {
  string name;
  string type; /// Edm.* or a qualified complex type name
  bool nullable = true;
  bool collection;
  string label; /// Common.Label for Fiori

  string edmType() const {
    return collection ? "Collection(" ~ type ~ ")" : type;
  }
}

/// A complex type (no key).
struct ODataComplexTypeDef {
  string name;
  ODataPropertyDef[] properties;
}

/// Entity type + entity set (1:1 in this service).
struct ODataEntitySetDef {
  string name; /// entity set name, e.g. "TranslationProjects"
  string entityType; /// entity type name, e.g. "TranslationProject"
  string key = "id";
  ODataPropertyDef[] properties;
  bool insertable;
  bool updatable;
  bool deletable;
  bool singleton; /// exposed as <Singleton> instead of <EntitySet>

  bool hasProperty(string propertyName) const {
    return properties.any!(p => p.name == propertyName);
  }
}

/// An unbound action.
struct ODataActionDef {
  string name;
  ODataPropertyDef[] parameters;
  string returnType;
}

/// The whole EDM model of a service.
class ODataServiceModel {
  string namespace_;
  string containerName;
  ODataEntitySetDef[] entitySets;
  ODataComplexTypeDef[] complexTypes;
  ODataActionDef[] actions;

  this(string namespace_, string containerName) {
    this.namespace_ = namespace_;
    this.containerName = containerName;
  }

  /// True if an entity set or singleton with this name exists.
  bool has(string name) const {
    return entitySets.any!(s => s.name == name);
  }

  /// The entity set or singleton with this name (ODataEntitySetDef.init if unknown).
  const(ODataEntitySetDef) find(string name) const {
    foreach (s; entitySets)
      if (s.name == name)
        return s;
    return ODataEntitySetDef.init;
  }

  string qualified(string typeName) const {
    return namespace_ ~ "." ~ typeName;
  }
}

/// Namespace of the OData service.
enum translationODataNamespace = "uim.translation";

/// EDM type of a reflected field.
ODataPropertyDef toODataProperty(const FieldInfo f, bool key = false) {
  ODataPropertyDef p;
  p.name = f.name;
  p.label = f.label;
  p.nullable = !key;
  final switch (f.kind) {
  case ValueKind.text, ValueKind.enumeration:
    p.type = Edm.string_;
    break;
  case ValueKind.integer:
    p.type = Edm.int32;
    break;
  case ValueKind.boolean:
    p.type = Edm.boolean;
    break;
  case ValueKind.dateTime:
    p.type = Edm.dateTimeOffset;
    break;
  case ValueKind.textList, ValueKind.enumList:
    p.type = Edm.string_;
    p.collection = true;
    break;
  case ValueKind.records:
    p.type = translationODataNamespace ~ "." ~ f.recordType;
    p.collection = true;
    break;
  }
  return p;
}

ODataPropertyDef[] toODataProperties(const FieldInfo[] fields, string key) {
  ODataPropertyDef[] props;
  foreach (f; fields)
    props ~= toODataProperty(f, f.name == key);
  return props;
}

/// The EDM model of the translation OData service, generated from the resource registry.
ODataServiceModel translationODataModel(ResourceRegistry registry) {
  enum ns = translationODataNamespace;
  auto m = new ODataServiceModel(ns, "TranslationService");

  void complexType(RecordTypeInfo t) {
    if (!m.complexTypes.any!(c => c.name == t.name))
      m.complexTypes ~= ODataComplexTypeDef(t.name, toODataProperties(t.fields, ""));
  }

  ODataPropertyDef text(string name, bool required = false) {
    return ODataPropertyDef(name, cast(string) Edm.string_, !required);
  }

  foreach (a; registry.adapters) {
    ODataEntitySetDef set;
    set.name = a.setName;
    set.entityType = a.typeName;
    set.key = "id";
    set.properties = toODataProperties(a.fields, "id");
    set.insertable = !a.readOnly;
    set.updatable = a.updatable;
    set.deletable = !a.readOnly;
    m.entitySets ~= set;
    foreach (t; a.recordTypes)
      complexType(t);

    foreach (act; a.actions) {
      ODataActionDef def;
      def.name = act.odataName;
      def.parameters ~= text("id", true);
      foreach (param; act.parameters)
        def.parameters ~= text(param);
      def.returnType = ns ~ "." ~ a.typeName;
      m.actions ~= def;
    }
  }

  ODataEntitySetDef statistics;
  statistics.name = "Statistics";
  statistics.entityType = "Statistic";
  statistics.key = "tenantId";
  statistics.singleton = true;
  statistics.properties = toODataProperties(describe!TranslationStatistics(), "tenantId");
  m.entitySets ~= statistics;

  foreach (t; recordTypesOf!TranslateTextsResult())
    complexType(t);
  m.complexTypes ~= ODataComplexTypeDef("TranslateTextsResult", toODataProperties(describe!TranslateTextsResult(), ""));
  m.complexTypes ~= ODataComplexTypeDef("DocumentTranslationResult",
    toODataProperties(describe!DocumentTranslationResult(), ""));
  m.complexTypes ~= ODataComplexTypeDef("JobRunReport", toODataProperties(describe!JobRunReport(), ""));

  auto texts = text("texts", true);
  texts.collection = true;
  m.actions ~= ODataActionDef("TranslateTexts", [
    text("sourceLanguage", true), text("targetLanguage", true), texts, text("provider"), text("domainName"),
    text("textType")
  ], ns ~ ".TranslateTextsResult");
  m.actions ~= ODataActionDef("TranslateDocument", [
    text("sourceLanguage", true), text("targetLanguage", true), text("content", true), text("contentType"),
    text("provider"), text("domainName")
  ], ns ~ ".DocumentTranslationResult");
  m.actions ~= ODataActionDef("ProcessJobs", null, ns ~ ".JobRunReport");
  return m;
}
