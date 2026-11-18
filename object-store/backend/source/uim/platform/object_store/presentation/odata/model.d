/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.object_store.presentation.odata.model;

import uim.platform.object_store;
import uim.platform.object_store.presentation.resources;

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
  string name; /// entity set name, e.g. "Buckets"
  string entityType; /// entity type name, e.g. "Bucket"
  string key = "id";
  ODataPropertyDef[] properties;
  bool insertable;
  bool updatable;
  bool deletable;
  bool singleton; /// exposed as <Singleton> instead of <EntitySet>

  bool hasProperty(string propertyName) const {
    return properties.any!(p => p.name == propertyName);
  }

  /// Names of the Edm.Int64 properties (written as strings for IEEE754Compatible clients).
  string[] int64Properties() const {
    return properties.filter!(p => p.type == Edm.int64 && !p.collection).map!(p => p.name.idup).array;
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
enum objectStoreODataNamespace = "uim.objectstore";

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
  case ValueKind.largeInteger:
    p.type = Edm.int64;
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
    p.type = objectStoreODataNamespace ~ "." ~ f.recordType;
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

/// The EDM model of the object store OData service, generated from the resource registry.
ODataServiceModel objectStoreODataModel(ResourceRegistry registry) {
  enum ns = objectStoreODataNamespace;
  auto m = new ODataServiceModel(ns, "ObjectStoreService");

  void complexType(string name, FieldInfo[] fields) {
    if (!m.complexTypes.any!(c => c.name == name))
      m.complexTypes ~= ODataComplexTypeDef(name, toODataProperties(fields, ""));
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
    set.insertable = a.creatable;
    set.updatable = a.updatable;
    set.deletable = a.deletable;
    m.entitySets ~= set;
    foreach (t; a.recordTypes)
      complexType(t.name, t.fields);

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
  statistics.properties = toODataProperties(describe!ObjectStoreStatistics(), "tenantId");
  m.entitySets ~= statistics;
  foreach (t; recordTypesOf!ObjectStoreStatistics())
    complexType(t.name, t.fields);

  complexType("AccessDecision", describe!AccessDecision());
  complexType("CorsDecision", describe!CorsDecision());
  complexType("CredentialCheck", describe!CredentialCheck());
  complexType("LifecycleRunReport", describe!LifecycleRunReport());

  auto headers = text("requestHeaders");
  headers.collection = true;
  m.actions ~= ODataActionDef("EvaluateAccess", [
    text("bucketId", true), text("principal"), text("action", true), text("key")
  ], ns ~ ".AccessDecision");
  m.actions ~= ODataActionDef("CheckCors", [
    text("bucketId", true), text("origin", true), text("method", true), headers
  ], ns ~ ".CorsDecision");
  m.actions ~= ODataActionDef("VerifyCredentials", [
    text("accessKeyId", true), text("secretAccessKey", true)
  ], ns ~ ".CredentialCheck");
  m.actions ~= ODataActionDef("ApplyLifecycle", [text("bucketId")], ns ~ ".LifecycleRunReport");
  auto metadata = ODataPropertyDef("metadata", ns ~ ".MetadataEntry");
  metadata.collection = true;
  m.actions ~= ODataActionDef("PutObjectContent", [
    text("bucketId", true), text("key", true), text("content"), text("contentEncoding"), text("contentType"), metadata
  ], ns ~ ".StorageObject");
  return m;
}
