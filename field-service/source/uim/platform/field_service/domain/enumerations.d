module uim.platform.field_service.domain.enumerations;
import uim.platform.field_service;

mixin(ShowModule!());

@safe:

/// Represents the status of a service call in the field service domain.  
enum ServiceCallStatus : string {
    /// The service call is in draft state and has not been submitted yet.
    draft = "draft",
    /// The service call has been created and is new.
    new_ = "new",
    /// The service call has been assigned to a technician or team.
    assigned = "assigned",
    /// The service call is currently in progress and being worked on.
    inProgress = "inProgress",
    /// The service call is on hold and waiting for further action.
    onHold = "onHold",
    /// The service call has been resolved and the issue has been addressed.
    resolved = "resolved",
    /// The service call has been closed and is no longer active.
    closed = "closed",
    /// The service call has been cancelled and will not be completed.
    cancelled = "cancelled"
}
ServiceCallStatus toServiceCallStatus(string status) {
    final switch (status.toLower()) {
        case "draft": return ServiceCallStatus.draft;
        case "new": return ServiceCallStatus.new_;
        case "assigned": return ServiceCallStatus.assigned;
        case "inprogress": return ServiceCallStatus.inProgress;
        case "onhold": return ServiceCallStatus.onHold;
        case "resolved": return ServiceCallStatus.resolved;
        case "closed": return ServiceCallStatus.closed;
        case "cancelled": return ServiceCallStatus.cancelled;
        default: return ServiceCallStatus.draft; // Default to draft if unknown
    }
}
ServiceCallStatus[] toServiceCallStatusArray(string[] statuses) {
    return statuses.map!(toServiceCallStatus).array;
}
string toString(ServiceCallStatus status) {
    return cast(string)status;
}
string[] toStringArray(ServiceCallStatus[] statuses) {
    return statuses.map!(toString).array;
}
///
unittest {
    mixin(ShowTest!("ServiceCallStatus enumeration"));

    assert("draft".toServiceCallStatus == ServiceCallStatus.draft);
    assert("new".toServiceCallStatus == ServiceCallStatus.new_);
    assert("assigned".toServiceCallStatus == ServiceCallStatus.assigned);
    assert("inProgress".toServiceCallStatus == ServiceCallStatus.inProgress);
    assert("onHold".toServiceCallStatus == ServiceCallStatus.onHold);
    assert("resolved".toServiceCallStatus == ServiceCallStatus.resolved);
    assert("closed".toServiceCallStatus == ServiceCallStatus.closed);
    assert("cancelled".toServiceCallStatus == ServiceCallStatus.cancelled);

    assert("".toServiceCallStatus == ServiceCallStatus.draft); // Default case
    assert("unknown".toServiceCallStatus == ServiceCallStatus.draft); // Default case

    assert(ServiceCallStatus.draft.toString == "draft");
    assert(ServiceCallStatus.new_.toString == "new");
    assert(ServiceCallStatus.assigned.toString == "assigned");
    assert(ServiceCallStatus.inProgress.toString == "inProgress");
    assert(ServiceCallStatus.onHold.toString == "onHold");
    assert(ServiceCallStatus.resolved.toString == "resolved"); 
    assert(ServiceCallStatus.closed.toString == "closed");
    assert(ServiceCallStatus.cancelled.toString == "cancelled");

    assert(toServiceCallStatusArray(["draft", "new", "assigned"]) == [ServiceCallStatus.draft, ServiceCallStatus.new_, ServiceCallStatus.assigned]);
    assert(toStringArray([ServiceCallStatus.draft, ServiceCallStatus.new_, ServiceCallStatus.assigned]) == ["draft", "new", "assigned"]);   
}

enum ServiceCallPriority {
    low,
    medium,
    high,
    critical
}
ServiceCallPriority toServiceCallPriority(string value) {
    mixin(EnumSwitch!("ServiceCallPriority", "priority"));
}
ServiceCallPriority[] toServiceCallPriorityArray(string[] values) {
    return values.map!(toServiceCallPriority).array;
}
string toString(ServiceCallPriority priority) {
    return cast(string)priority;
}
string[] toString(ServiceCallPriority[] priorities) {
    return priorities.map!(toString).array;
}
///
unittest {
    mixin(ShowTest!("ServiceCallPriority enumeration"));

    assert("low".toServiceCallPriority == ServiceCallPriority.low);
    assert("medium".toServiceCallPriority == ServiceCallPriority.medium);
    assert("high".toServiceCallPriority == ServiceCallPriority.high);
    assert("critical".toServiceCallPriority == ServiceCallPriority.critical);

    assert("".toServiceCallPriority == ServiceCallPriority.low); // Default case
    assert("unknown".toServiceCallPriority == ServiceCallPriority.low); // Default case

    assert(ServiceCallPriority.low.toString == "low");
    assert(ServiceCallPriority.medium.toString == "medium");
    assert(ServiceCallPriority.high.toString == "high");
    assert(ServiceCallPriority.critical.toString == "critical");

    assert(toServiceCallPriorityArray(["low", "medium", "high"]) == [ServiceCallPriority.low, ServiceCallPriority.medium, ServiceCallPriority.high]);
    assert(toStringArray([ServiceCallPriority.low, ServiceCallPriority.medium, ServiceCallPriority.high]) == ["low", "medium", "high"]);   
}

enum ServiceCallOrigin {
    manual,
    selfService,
    email,
    phone,
    iot,
    integration
}
ServiceCallOrigin toServiceCallOrigin(string value) {
    mixin(EnumSwitch!("ServiceCallOrigin", "origin"));
}
ServiceCallOrigin[] toServiceCallOriginArray(string[] values) {
    return values.map!(toServiceCallOrigin).array;
}
string toString(ServiceCallOrigin origin) {
    return origin.to!string;
}
string[] toString(ServiceCallOrigin[] origins) {
    return origins.map!(toString).array;
}
/// 
unittest {
    mixin(ShowTest!("ServiceCallOrigin enumeration"));

    assert("manual".toServiceCallOrigin == ServiceCallOrigin.manual);
    assert("selfService".toServiceCallOrigin == ServiceCallOrigin.selfService);
    assert("email".toServiceCallOrigin == ServiceCallOrigin.email);
    assert("phone".toServiceCallOrigin == ServiceCallOrigin.phone);
    assert("iot".toServiceCallOrigin == ServiceCallOrigin.iot);
    assert("integration".toServiceCallOrigin == ServiceCallOrigin.integration);

    assert("".toServiceCallOrigin == ServiceCallOrigin.manual); // Default case
    assert("unknown".toServiceCallOrigin == ServiceCallOrigin.manual); // Default case

    assert(ServiceCallOrigin.manual.toString == "manual");
    assert(ServiceCallOrigin.selfService.toString == "selfService");
    assert(ServiceCallOrigin.email.toString == "email");
    assert(ServiceCallOrigin.phone.toString == "phone");
    assert(ServiceCallOrigin.iot.toString == "iot");
    assert(ServiceCallOrigin.integration.toString == "integration");

    assert(toServiceCallOriginArray(["manual", "selfService", "email"]) == [ServiceCallOrigin.manual, ServiceCallOrigin.selfService, ServiceCallOrigin.email]);
    assert(toStringArray([ServiceCallOrigin.manual, ServiceCallOrigin.selfService, ServiceCallOrigin.email]) == ["manual", "selfService", "email"]);   
}

enum ServiceCallCategory {
    repair,
    installation,
    maintenance,
    inspection,
    warranty,
    emergency,
    consultation,
    other
}
ServiceCallCategory toServiceCallCategory(string value) {
    mixin(EnumSwitch!("ServiceCallCategory", "category"));
}
ServiceCallCategory[] toServiceCallCategoryArray(string[] values) {
    return values.map!(toServiceCallCategory).array;
}
string toString(ServiceCallCategory category) {
    return category.to!string;
}
string[] toString(ServiceCallCategory[] categories) {   
    return categories.map!(toString).array;
}
///
unittest {
    mixin(ShowTest!("ServiceCallCategory enumeration"));

    assert("repair".toServiceCallCategory == ServiceCallCategory.repair);
    assert("installation".toServiceCallCategory == ServiceCallCategory.installation);
    assert("maintenance".toServiceCallCategory == ServiceCallCategory.maintenance);
    assert("inspection".toServiceCallCategory == ServiceCallCategory.inspection);
    assert("warranty".toServiceCallCategory == ServiceCallCategory.warranty);
    assert("emergency".toServiceCallCategory == ServiceCallCategory.emergency);
    assert("consultation".toServiceCallCategory == ServiceCallCategory.consultation);
    assert("other".toServiceCallCategory == ServiceCallCategory.other);

    assert("".toServiceCallCategory == ServiceCallCategory.other); // Default case
    assert("unknown".toServiceCallCategory == ServiceCallCategory.other); // Default case

    assert(ServiceCallCategory.repair.toString == "repair");
    assert(ServiceCallCategory.installation.toString == "installation");
    assert(ServiceCallCategory.maintenance.toString == "maintenance");
    assert(ServiceCallCategory.inspection.toString == "inspection");
    assert(ServiceCallCategory.warranty.toString == "warranty");
    assert(ServiceCallCategory.emergency.toString == "emergency");
    assert(ServiceCallCategory.consultation.toString == "consultation");
    assert(ServiceCallCategory.other.toString == "other");

    assert(toServiceCallCategoryArray(["repair", "installation", "maintenance"]) == [ServiceCallCategory.repair, ServiceCallCategory.installation, ServiceCallCategory.maintenance]);
    assert(toStringArray([ServiceCallCategory.repair, ServiceCallCategory.installation, ServiceCallCategory.maintenance]) == ["repair", "installation", "maintenance"]);   
}

enum ActivityType {
    serviceTask,
    meeting,
    phoneCall,
    travelTime,
    breakTime,
    followUp,
    inspection,
    installation,
    repair,
    maintenance
}

enum ActivityStatus {
    draft,
    planned,
    released,
    dispatched,
    accepted,
    inTravel,
    onSite,
    inProgress,
    completed,
    cancelled
}

enum AssignmentStatus {
    proposed,
    assigned,
    accepted,
    rejected,
    inProgress,
    completed,
    cancelled
}

enum EquipmentStatus {
    active,
    inactive,
    inRepair,
    decommissioned,
    scrapped
}

enum EquipmentType {
    machine,
    tool,
    vehicle,
    sensor,
    hvac,
    electrical,
    plumbing,
    it,
    custom
}

enum TechnicianStatus {
    available,
    busy,
    onLeave,
    offline,
    inactive
}

enum CustomerType {
    commercial,
    residential,
    industrial,
    government,
    internal
}

enum CustomerStatus {
    active,
    inactive,
    prospect,
    blocked
}

enum SkillCategory {
    technical,
    certification,
    product,
    safety,
    language,
    soft,
    custom
}

enum ProficiencyLevel {
    beginner,
    intermediate,
    advanced,
    expert,
    master
}

enum SmartformType {
    checklist,
    serviceReport,
    inspection,
    safety,
    feedback,
    survey,
    workInstruction,
    handover,
    custom
}

enum SmartformStatus {
    draft,
    inProgress,
    submitted,
    approved,
    rejected,
    archived
}
