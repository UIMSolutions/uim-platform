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
}