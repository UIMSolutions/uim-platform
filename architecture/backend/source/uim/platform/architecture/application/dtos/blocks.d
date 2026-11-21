/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Request models of the building block use cases. Values are optional
/// (Nullable) so that one model serves create and PATCH.
module uim.platform.architecture.application.dtos.blocks;

public import std.typecons : Nullable;
import uim.platform.architecture;

mixin(ShowModule!());

@safe:

/// Attribute values of a building block; unset values are left unchanged
/// (update) or take their defaults (create). Enumerations are passed as
/// text and parsed by the use case (one error message for every adapter).
struct BlockValues {
  Nullable!string name;
  Nullable!string description;
  Nullable!string owner;
  Nullable!string status;
  Nullable!string versionLabel;
  Nullable!(string[]) tags;
  Nullable!string elementType;
  Nullable!string viewpoint;
  Nullable!string capability;
  Nullable!(string[]) interfaces;
  Nullable!string realizesId;
  Nullable!string vendor;
  Nullable!string endpoint;
  Nullable!string dataClassification;
  Nullable!string dataOwner;
  Nullable!string sourceSystem;
  Nullable!string factSheetType;
  Nullable!string factSheetId;
  Nullable!string validUntil; /// ISO 8601 date or timestamp, "" = none
}

struct CreateBlockRequest {
  TenantId tenantId;
  UserId actor;
  string id; /// optional stable id ("abb-crm"); generated if empty
  string kind; /// architecture | solution | data | business | technology (or ABB, SBB, ...)
  BlockValues values;
}

struct UpdateBlockRequest {
  TenantId tenantId;
  UserId actor;
  BuildingBlockId id;
  BlockValues values;
}

/// List filter; empty values match everything.
struct BlockFilter {
  string kind;
  string status;
  string owner;
  string tag;
  string search; /// case-insensitive substring of id, name, description, capability, vendor
}
