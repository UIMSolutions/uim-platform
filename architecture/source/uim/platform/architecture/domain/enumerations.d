module uim.platform.architecture.domain.enumerations;

import uim.platform.architecture;

mixin(ShowModule!());

@safe:

enum BuildingBlockType {
    architecture,
    solution,
    data,
    business,
    technology
}

/// ArchiMateDomain aligns architecture blocks with ArchiMate core and extension domains.
enum ArchiMateDomain {
    common,
    motivation,
    strategy,
    business,
    application,
    technology,
    implementationAndMigration
}

/// ArchiMateAspect aligns elements with ArchiMate structure/behavior aspects.
enum ArchiMateAspect {
    activeStructure,
    behavior,
    passiveStructure,
    motivation,
    composite
}

/// ArchiMateRelationshipType captures the core relationship families from the spec.
enum ArchiMateRelationshipType {
    aggregation,
    composition,
    assignment,
    realization,
    serving,
    access,
    influence,
    association,
    triggering,
    flow,
    specialization
}

/// LifecycleStatus represents the lifecycle status of a building block.
enum LifecycleStatus {
    proposed,
    approved,
    inDevelopment,
    active,
    deprecated_
}

LifecycleStatus toLifecycleStatus(string status) {
    switch (status) {
        case "proposed": return LifecycleStatus.proposed;
        case "approved": return LifecycleStatus.approved;
        case "inDevelopment": return LifecycleStatus.inDevelopment;
        case "active": return LifecycleStatus.active;
        case "deprecated": return LifecycleStatus.deprecated_;
        default: return LifecycleStatus.proposed; // Default to proposed if unknown
    }
}

LifecycleStatus[] toLifecycleStatus(string[] status) {
    return status.map!toLifecycleStatus.array;
}

string toString(LifecycleStatus status) {
    final switch (status) {
        case LifecycleStatus.proposed: return "proposed";
        case LifecycleStatus.approved: return "approved";
        case LifecycleStatus.inDevelopment: return "inDevelopment";
        case LifecycleStatus.active: return "active";
        case LifecycleStatus.deprecated_: return "deprecated";
    }
}

string[] toString(LifecycleStatus[] status) {
    return status.map!toString.array;
}

ArchiMateDomain toArchiMateDomain(string domain) {
    switch (domain) {
        case "common": return ArchiMateDomain.common;
        case "motivation": return ArchiMateDomain.motivation;
        case "strategy": return ArchiMateDomain.strategy;
        case "business": return ArchiMateDomain.business;
        case "application": return ArchiMateDomain.application;
        case "technology": return ArchiMateDomain.technology;
        case "implementationAndMigration":
        case "implementation-migration":
        case "implementation_and_migration":
            return ArchiMateDomain.implementationAndMigration;
        default: return ArchiMateDomain.application;
    }
}

string toString(ArchiMateDomain domain) {
    final switch (domain) {
        case ArchiMateDomain.common: return "common";
        case ArchiMateDomain.motivation: return "motivation";
        case ArchiMateDomain.strategy: return "strategy";
        case ArchiMateDomain.business: return "business";
        case ArchiMateDomain.application: return "application";
        case ArchiMateDomain.technology: return "technology";
        case ArchiMateDomain.implementationAndMigration: return "implementationAndMigration";
    }
}

ArchiMateAspect toArchiMateAspect(string aspect) {
    switch (aspect) {
        case "activeStructure":
        case "active-structure":
        case "active_structure":
            return ArchiMateAspect.activeStructure;
        case "behavior": return ArchiMateAspect.behavior;
        case "passiveStructure":
        case "passive-structure":
        case "passive_structure":
            return ArchiMateAspect.passiveStructure;
        case "motivation": return ArchiMateAspect.motivation;
        case "composite": return ArchiMateAspect.composite;
        default: return ArchiMateAspect.behavior;
    }
}

string toString(ArchiMateAspect aspect) {
    final switch (aspect) {
        case ArchiMateAspect.activeStructure: return "activeStructure";
        case ArchiMateAspect.behavior: return "behavior";
        case ArchiMateAspect.passiveStructure: return "passiveStructure";
        case ArchiMateAspect.motivation: return "motivation";
        case ArchiMateAspect.composite: return "composite";
    }
}

ArchiMateRelationshipType toArchiMateRelationshipType(string relationshipType) {
    switch (relationshipType) {
        case "aggregation": return ArchiMateRelationshipType.aggregation;
        case "composition": return ArchiMateRelationshipType.composition;
        case "assignment": return ArchiMateRelationshipType.assignment;
        case "realization": return ArchiMateRelationshipType.realization;
        case "serving": return ArchiMateRelationshipType.serving;
        case "access": return ArchiMateRelationshipType.access;
        case "influence": return ArchiMateRelationshipType.influence;
        case "association": return ArchiMateRelationshipType.association;
        case "triggering": return ArchiMateRelationshipType.triggering;
        case "flow": return ArchiMateRelationshipType.flow;
        case "specialization": return ArchiMateRelationshipType.specialization;
        default: return ArchiMateRelationshipType.association;
    }
}

string toString(ArchiMateRelationshipType relationshipType) {
    final switch (relationshipType) {
        case ArchiMateRelationshipType.aggregation: return "aggregation";
        case ArchiMateRelationshipType.composition: return "composition";
        case ArchiMateRelationshipType.assignment: return "assignment";
        case ArchiMateRelationshipType.realization: return "realization";
        case ArchiMateRelationshipType.serving: return "serving";
        case ArchiMateRelationshipType.access: return "access";
        case ArchiMateRelationshipType.influence: return "influence";
        case ArchiMateRelationshipType.association: return "association";
        case ArchiMateRelationshipType.triggering: return "triggering";
        case ArchiMateRelationshipType.flow: return "flow";
        case ArchiMateRelationshipType.specialization: return "specialization";
    }
}

///
unittest {
    assert(toString(LifecycleStatus.proposed) == "proposed");
    assert(toString(LifecycleStatus.approved) == "approved");
    assert(toString(LifecycleStatus.inDevelopment) == "inDevelopment");
    assert(toString(LifecycleStatus.active) == "active");
    assert(toString(LifecycleStatus.deprecated_) == "deprecated");

    assert(toLifecycleStatus("proposed") == LifecycleStatus.proposed);
    assert(toLifecycleStatus("approved") == LifecycleStatus.approved);
    assert(toLifecycleStatus("inDevelopment") == LifecycleStatus.inDevelopment);
    assert(toLifecycleStatus("active") == LifecycleStatus.active);
    assert(toLifecycleStatus("deprecated") == LifecycleStatus.deprecated_);

    assert(toArchiMateDomain("application") == ArchiMateDomain.application);
    assert(toArchiMateDomain("implementation-migration") == ArchiMateDomain.implementationAndMigration);
    assert(toString(ArchiMateDomain.strategy) == "strategy");

    assert(toArchiMateAspect("active-structure") == ArchiMateAspect.activeStructure);
    assert(toArchiMateAspect("passiveStructure") == ArchiMateAspect.passiveStructure);
    assert(toString(ArchiMateAspect.composite) == "composite");

    assert(toArchiMateRelationshipType("flow") == ArchiMateRelationshipType.flow);
    assert(toArchiMateRelationshipType("unknown") == ArchiMateRelationshipType.association);
    assert(toString(ArchiMateRelationshipType.realization) == "realization");
}