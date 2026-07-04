/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.dms_integration.domain.enumerations;

import uim.platform.dms_integration;

mixin(ShowModule!());

@safe:

enum RepositoryType {
    managed,
    external,
    googleWorkspace,
    openText,
    sharepoint,
    s4hanaDms,
    other
}
RepositoryType toRepositoryType(string value) {
  mixin(EnumSwitch("RepositoryType", "managed"));
}
string toString(RepositoryType rt) {
    return rt.to!string; // This will return the enum member name as a string, e.g. "managed", "external", etc.
}
///
unittest {
    assert(toRepositoryType("managed") == RepositoryType.managed);
    assert(toRepositoryType("EXTERNAL") == RepositoryType.external);
    assert(toRepositoryType("GoogleWorkspace") == RepositoryType.googleWorkspace);
    assert(toRepositoryType("openText") == RepositoryType.openText);
    assert(toRepositoryType("SharePoint") == RepositoryType.sharepoint);
    assert(toRepositoryType("s4hanaDms") == RepositoryType.s4hanaDms);
    assert(toRepositoryType("other") == RepositoryType.other);

    assert(RepositoryType.managed.toString == "managed");
    assert(RepositoryType.external.toString == "external");
    assert(RepositoryType.googleWorkspace.toString == "googleWorkspace");
    assert(RepositoryType.openText.toString == "openText");
    assert(RepositoryType.sharepoint.toString == "sharepoint");
    assert(RepositoryType.s4hanaDms.toString == "s4hanaDms");
    assert(RepositoryType.other.toString == "other");
}

enum RepositoryStatus : string {
    active = "active",
    inactive = "inactive",
    maintenance = "maintenance",
    error_ = "error",
    provisioning = "provisioning"
}
RepositoryStatus toRepositoryStatus(string value) {
    switch(value.toLower()) {
        case "active": return RepositoryStatus.active;
        case "inactive": return RepositoryStatus.inactive;
        case "maintenance": return RepositoryStatus.maintenance;
        case "error": return RepositoryStatus.error_;
        case "provisioning": return RepositoryStatus.provisioning;
        default: return RepositoryStatus.active; // default
    }
}
string toString(RepositoryStatus value) {
    return cast(string)value; // This will return the string value of the enum member, e.g. "active", "inactive", etc.
}
///
unittest {
    assert(toRepositoryStatus("active") == RepositoryStatus.active);
    assert(toRepositoryStatus("INACTIVE") == RepositoryStatus.inactive);
    assert(toRepositoryStatus("Maintenance") == RepositoryStatus.maintenance);
    assert(toRepositoryStatus("error") == RepositoryStatus.error_);
    assert(toRepositoryStatus("Provisioning") == RepositoryStatus.provisioning);
    assert(toRepositoryStatus("unknown") == RepositoryStatus.active);

    assert(RepositoryStatus.active.toString == "active");
    assert(RepositoryStatus.inactive.toString == "inactive");
    assert(RepositoryStatus.maintenance.toString == "maintenance");
    assert(RepositoryStatus.error_.toString == "error");
    assert(RepositoryStatus.provisioning.toString == "provisioning");
}

enum DocumentStatus {
    draft,
    active,
    obsolete,
    archived
}
DocumentStatus toDocumentStatus(string value) {
  mixin(EnumSwitch("DocumentStatus", "draft"));
}
string toString(DocumentStatus ds) {
    return ds.to!string; // This will return the enum member name as a string, e.g. "draft", "active", etc.
}
///
unittest {
    assert(toDocumentStatus("draft") == DocumentStatus.draft);
    assert(toDocumentStatus("ACTIVE") == DocumentStatus.active);
    assert(toDocumentStatus("Obsolete") == DocumentStatus.obsolete);  
    assert(toDocumentStatus("archived") == DocumentStatus.archived);
    assert(toDocumentStatus("unknown") == DocumentStatus.draft); 

    assert(DocumentStatus.draft.toString == "draft");
    assert(DocumentStatus.active.toString == "active");
    assert(DocumentStatus.obsolete.toString == "obsolete");
    assert(DocumentStatus.archived.toString == "archived"); 
}

/// Document lifecycle state.
enum LifecycleStatus : string{
    draft = "draft",
    published = "published",
    deprecated_ = "deprecated",
    archived_ = "archived"
}
LifecycleStatus toLifecycleStatus(string value) {
    switch(value.toLower()) {
        case "draft": return LifecycleStatus.draft;
        case "published": return LifecycleStatus.published;
        case "deprecated": return LifecycleStatus.deprecated_;
        case "archived": return LifecycleStatus.archived_;
        default: return LifecycleStatus.draft; // default
    }
}
string toString(LifecycleStatus ls) {
    return cast(string)ls; // This will return the string value of the enum member, e.g. "draft", "published", etc.
}
///
unittest {
    assert(toLifecycleStatus("draft") == LifecycleStatus.draft);
    assert(toLifecycleStatus("PUBLISHED") == LifecycleStatus.published);
    assert(toLifecycleStatus("Deprecated") == LifecycleStatus.deprecated_);
    assert(toLifecycleStatus("archived") == LifecycleStatus.archived_);
    assert(toLifecycleStatus("unknown") == LifecycleStatus.draft);

    assert(LifecycleStatus.draft.toString == "draft");
    assert(LifecycleStatus.published.toString == "published");
    assert(LifecycleStatus.deprecated_.toString == "deprecated");
    assert(LifecycleStatus.archived_.toString == "archived");
}

enum VersioningState {
    none,
    major,
    minor,
    checkedOut
}
VersioningState toVersioningState(string value) {
  mixin(EnumSwitch("VersioningState", "none"));
}
string toString(VersioningState vs) {
    return vs.to!string; // This will return the enum member name as a string, e.g. "none", "major", etc.
}
///
unittest {
    assert(toVersioningState("none") == VersioningState.none);
    assert(toVersioningState("MAJOR") == VersioningState.major);
    assert(toVersioningState("Minor") == VersioningState.minor);
    assert(toVersioningState("checkedOut") == VersioningState.checkedOut);
    assert(toVersioningState("unknown") == VersioningState.none);

    assert(VersioningState.none.toString == "none");
    assert(VersioningState.major.toString == "major");
    assert(VersioningState.minor.toString == "minor");
    assert(VersioningState.checkedOut.toString == "checkedOut");
}

enum CheckoutStatus {
    available,
    checkedOut
}
CheckoutStatus toCheckoutStatus(string value) {
  mixin(EnumSwitch("CheckoutStatus", "available"));
}
string toString(CheckoutStatus cs) {
    return cs.to!string; // This will return the enum member name as a string, e.g. "available", "checkedOut"
}
///
unittest {
    assert(toCheckoutStatus("available") == CheckoutStatus.available);
    assert(toCheckoutStatus("CHECKEDOUT") == CheckoutStatus.checkedOut);
    assert(toCheckoutStatus("unknown") == CheckoutStatus.available);

    assert(CheckoutStatus.available.toString == "available");
    assert(CheckoutStatus.checkedOut.toString == "checkedOut");
}

enum PermissionType : string {
    read = "READ",
    write = "WRITE",
    delete_ = "DELETE",
    full = "FULL",
    readWrite = "READWRITE"
}
PermissionType toPermissionType(string value) {
    switch(value.toLower) {
        case "read": return PermissionType.read;
        case "write": return PermissionType.write;
        case "delete": return PermissionType.delete_;
        case "full": return PermissionType.full;
        case "readwrite": return PermissionType.readWrite;
        default: return PermissionType.read; // default
    }
}
string toString(PermissionType pt) {
    return cast(string)pt; // This will return the string value of the enum member, e.g. "READ", "WRITE", etc.
}
///
unittest {
    assert(toPermissionType("read") == PermissionType.read);
    assert(toPermissionType("WRITE") == PermissionType.write);
    assert(toPermissionType("Delete") == PermissionType.delete_);
    assert(toPermissionType("full") == PermissionType.full);
    assert(toPermissionType("ReadWrite") == PermissionType.readWrite);
    assert(toPermissionType("unknown") == PermissionType.read);

    assert(PermissionType.read.toString == "READ");
    assert(PermissionType.write.toString == "WRITE");
    assert(PermissionType.delete_.toString == "DELETE");
    assert(PermissionType.full.toString == "FULL");
    assert(PermissionType.readWrite.toString == "READWRITE");
}

enum PrincipalType {
    user,
    group,
    everyone
}
PrincipalType toPrincipalType(string value) {
  mixin(EnumSwitch("PrincipalType", "user"));
}
string toString(PrincipalType pt) {
    return pt.to!string; // This will return the enum member name as a string, e.g. "user", "group", "everyone"
}
///
unittest {
    assert(toPrincipalType("user") == PrincipalType.user);
    assert(toPrincipalType("GROUP") == PrincipalType.group);
    assert(toPrincipalType("Everyone") == PrincipalType.everyone);
    assert(toPrincipalType("unknown") == PrincipalType.user);

    assert(toString(PrincipalType.user) == "user");
    assert(toString(PrincipalType.group) == "group");
    assert(toString(PrincipalType.everyone) == "everyone");
}

enum FolderType {
    standard,
    root,
    system,
    virtual,
    archive
}
FolderType toFolderType(string value) {
  mixin(EnumSwitch("FolderType", "standard"));
}
string toString(FolderType ft) {
    return ft.to!string; // This will return the enum member name as a string, e.g. "standard", "root", etc
}
///
unittest {
    assert(toFolderType("standard") == FolderType.standard);
    assert(toFolderType("ROOT") == FolderType.root);
    assert(toFolderType("System") == FolderType.system);
    assert(toFolderType("virtual") == FolderType.virtual);
    assert(toFolderType("Archive") == FolderType.archive);
    assert(toFolderType("unknown") == FolderType.standard);
}

enum ContentStreamAllowed : string {
    notAllowed = "notAllowed",
    allowed = "allowed",
    required_ = "required"
}
ContentStreamAllowed toContentStreamAllowed(string value) {
    switch(value.toLower()) {
        case "notallowed": return ContentStreamAllowed.notAllowed;
        case "allowed": return ContentStreamAllowed.allowed;
        case "required": return ContentStreamAllowed.required_;
        default: return ContentStreamAllowed.notAllowed; // default
    }
}
string toString(ContentStreamAllowed csa) {
    return cast(string)csa; // This will return the string value of the enum member, e.g. "notAllowed", "allowed", etc.
}
///
unittest {
    assert(toContentStreamAllowed("notAllowed") == ContentStreamAllowed.notAllowed);
    assert(toContentStreamAllowed("ALLOWED") == ContentStreamAllowed.allowed);
    assert(toContentStreamAllowed("Required") == ContentStreamAllowed.required_);
    assert(toContentStreamAllowed("unknown") == ContentStreamAllowed.notAllowed);

    assert(ContentStreamAllowed.notAllowed.toString == "notAllowed");
    assert(ContentStreamAllowed.allowed.toString == "allowed");
    assert(ContentStreamAllowed.required_.toString == "required");
}
