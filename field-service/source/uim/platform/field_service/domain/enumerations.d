/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
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
    switch (status.toLower()) {
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
    /// The service call has a low priority and can be addressed in due course.
    low,
    /// The service call has a medium priority and should be addressed in a timely manner.
    medium,
    /// The service call has a high priority and requires immediate attention.
    high,
    /// The service call has a critical priority and requires urgent attention.
    critical
}
ServiceCallPriority toServiceCallPriority(string value) {
    mixin(EnumSwitch("ServiceCallPriority", "low"));
}
ServiceCallPriority[] toServiceCallPriorityArray(string[] values) {
    return values.map!(toServiceCallPriority).array;
}
string toString(ServiceCallPriority priority) {
    return priority.to!string;
}
string[] toStrings(ServiceCallPriority[] priorities) {
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
    assert(toString([ServiceCallPriority.low, ServiceCallPriority.medium, ServiceCallPriority.high]) == ["low", "medium", "high"]);   
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
    mixin(EnumSwitch("ServiceCallOrigin", "manual"));
}
ServiceCallOrigin[] toServiceCallOriginArray(string[] values) {
    return values.map!(toServiceCallOrigin).array;
}
string toString(ServiceCallOrigin origin) {
    return origin.to!string;
}
string[] toStrings(ServiceCallOrigin[] origins) {
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
    assert(toString([ServiceCallOrigin.manual, ServiceCallOrigin.selfService, ServiceCallOrigin.email]) == ["manual", "selfService", "email"]);
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
    mixin(EnumSwitch("ServiceCallCategory", "other"));
}
ServiceCallCategory[] toServiceCallCategory(string[] values) {
    return values.map!(toServiceCallCategory).array;
}
string toString(ServiceCallCategory category) {
    return category.to!string;
}
string[] toStrings(ServiceCallCategory[] categories) {   
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

    assert(toServiceCallCategory(["repair", "installation", "maintenance"]) == [ServiceCallCategory.repair, ServiceCallCategory.installation, ServiceCallCategory.maintenance]);
    assert(toString([ServiceCallCategory.repair, ServiceCallCategory.installation, ServiceCallCategory.maintenance]) == ["repair", "installation", "maintenance"]);   
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
ActivityType toActivityType(string value) {
    mixin(EnumSwitch("ActivityType", "serviceTask"));
}
ActivityType[] toActivityType(string[] values) {
    return values.map!(toActivityType).array;
}
string toString(ActivityType activity) {
    return activity.to!string;
}
string[] toStrings(ActivityType[] activities) {   
    return activities.map!(toString).array;
}
///
unittest {
    mixin(ShowTest!("ActivityType enumeration"));

    assert("serviceTask".toActivityType == ActivityType.serviceTask);
    assert("meeting".toActivityType == ActivityType.meeting);
    assert("phoneCall".toActivityType == ActivityType.phoneCall);
    assert("travelTime".toActivityType == ActivityType.travelTime);
    assert("breakTime".toActivityType == ActivityType.breakTime);
    assert("followUp".toActivityType == ActivityType.followUp);
    assert("inspection".toActivityType == ActivityType.inspection);
    assert("installation".toActivityType == ActivityType.installation);
    assert("repair".toActivityType == ActivityType.repair);
    assert("maintenance".toActivityType == ActivityType.maintenance);

    assert("".toActivityType == ActivityType.serviceTask); // Default case
    assert("unknown".toActivityType == ActivityType.serviceTask); // Default case

    assert(ActivityType.serviceTask.toString == "serviceTask");
    assert(ActivityType.meeting.toString == "meeting");
    assert(ActivityType.phoneCall.toString == "phoneCall");
    assert(ActivityType.travelTime.toString == "travelTime");
    assert(ActivityType.breakTime.toString == "breakTime");
    assert(ActivityType.followUp.toString == "followUp");
    assert(ActivityType.inspection.toString == "inspection");
    assert(ActivityType.installation.toString == "installation");
    assert(ActivityType.repair.toString == "repair");
    assert(ActivityType.maintenance.toString == "maintenance");

    assert(toActivityType(["serviceTask", "meeting", "phoneCall"]) == [ActivityType.serviceTask, ActivityType.meeting, ActivityType.phoneCall]);
    assert(toString([ActivityType.serviceTask, ActivityType.meeting, ActivityType.phoneCall]) == ["serviceTask", "meeting", "phoneCall"]);   
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
ActivityStatus toActivityStatus(string value) {
    mixin(EnumSwitch("ActivityStatus", "draft"));
}
ActivityStatus[] toActivityStatus(string[] values) {
    return values.map!(toActivityStatus).array;
}
string toString(ActivityStatus status) {
    return status.to!string;
}
string[] toStrings(ActivityStatus[] statuses) {
    return statuses.map!(toString).array;
}   
///
unittest {
    mixin(ShowTest!("ActivityStatus enumeration"));

    assert("draft".toActivityStatus == ActivityStatus.draft);
    assert("planned".toActivityStatus == ActivityStatus.planned);
    assert("released".toActivityStatus == ActivityStatus.released);
    assert("dispatched".toActivityStatus == ActivityStatus.dispatched);
    assert("accepted".toActivityStatus == ActivityStatus.accepted);
    assert("inTravel".toActivityStatus == ActivityStatus.inTravel);
    assert("onSite".toActivityStatus == ActivityStatus.onSite);
    assert("inProgress".toActivityStatus == ActivityStatus.inProgress);
    assert("completed".toActivityStatus == ActivityStatus.completed);
    assert("cancelled".toActivityStatus == ActivityStatus.cancelled);

    assert("".toActivityStatus == ActivityStatus.draft); // Default case
    assert("unknown".toActivityStatus == ActivityStatus.draft); // Default case

    assert(ActivityStatus.draft.toString == "draft");
    assert(ActivityStatus.planned.toString == "planned");
    assert(ActivityStatus.released.toString == "released");
    assert(ActivityStatus.dispatched.toString == "dispatched");
    assert(ActivityStatus.accepted.toString == "accepted");
    assert(ActivityStatus.inTravel.toString == "inTravel");
    assert(ActivityStatus.onSite.toString == "onSite");
    assert(ActivityStatus.inProgress.toString == "inProgress");
    assert(ActivityStatus.completed.toString == "completed");
    assert(ActivityStatus.cancelled.toString == "cancelled");}

enum AssignmentStatus {
    proposed,
    assigned,
    accepted,
    rejected,
    inProgress,
    completed,
    cancelled
}
AssignmentStatus toAssignmentStatus(string value) {
    mixin(EnumSwitch("AssignmentStatus", "proposed"));
}
AssignmentStatus[] toAssignmentStatus(string[] values) {
    return values.map!(toAssignmentStatus).array;
}
string toString(AssignmentStatus status) {
    return status.to!string;
}
string[] toStrings(AssignmentStatus[] statuses) {
    return statuses.map!(toString).array;
}
/// 
unittest {
    mixin(ShowTest!("AssignmentStatus enumeration"));

    assert("proposed".toAssignmentStatus == AssignmentStatus.proposed);
    assert("assigned".toAssignmentStatus == AssignmentStatus.assigned);
    assert("accepted".toAssignmentStatus == AssignmentStatus.accepted);
    assert("rejected".toAssignmentStatus == AssignmentStatus.rejected);
    assert("inProgress".toAssignmentStatus == AssignmentStatus.inProgress);
    assert("completed".toAssignmentStatus == AssignmentStatus.completed);
    assert("cancelled".toAssignmentStatus == AssignmentStatus.cancelled);

    assert("".toAssignmentStatus == AssignmentStatus.proposed); // Default case
    assert("unknown".toAssignmentStatus == AssignmentStatus.proposed); // Default case

    assert(AssignmentStatus.proposed.toString == "proposed");
    assert(AssignmentStatus.assigned.toString == "assigned");
    assert(AssignmentStatus.accepted.toString == "accepted");
    assert(AssignmentStatus.rejected.toString == "rejected");
    assert(AssignmentStatus.inProgress.toString == "inProgress");
    assert(AssignmentStatus.completed.toString == "completed");
    assert(AssignmentStatus.cancelled.toString == "cancelled");

    assert(toAssignmentStatus(["proposed", "assigned", "accepted"]) == [AssignmentStatus.proposed, AssignmentStatus.assigned, AssignmentStatus.accepted]);
    assert(toString([AssignmentStatus.proposed, AssignmentStatus.assigned, AssignmentStatus.accepted]) == ["proposed", "assigned", "accepted"]);   
}

enum EquipmentStatus {
    active,
    inactive,
    inRepair,
    decommissioned,
    scrapped
}
EquipmentStatus toEquipmentStatus(string value) {
    mixin(EnumSwitch("EquipmentStatus", "active"));
}
EquipmentStatus[] toEquipmentStatus(string[] values) {
    return values.map!(toEquipmentStatus).array;
}
string toString(EquipmentStatus status) {
    return status.to!string;
}
string[] toStrings(EquipmentStatus[] statuses) {
    return statuses.map!(toString).array;
}
/// 
unittest {
    mixin(ShowTest!("EquipmentStatus enumeration"));

    assert("active".toEquipmentStatus == EquipmentStatus.active);
    assert("inactive".toEquipmentStatus == EquipmentStatus.inactive);
    assert("inRepair".toEquipmentStatus == EquipmentStatus.inRepair);
    assert("decommissioned".toEquipmentStatus == EquipmentStatus.decommissioned);
    assert("scrapped".toEquipmentStatus == EquipmentStatus.scrapped);

    assert("".toEquipmentStatus == EquipmentStatus.active); // Default case
    assert("unknown".toEquipmentStatus == EquipmentStatus.active); // Default case

    assert(EquipmentStatus.active.toString == "active");
    assert(EquipmentStatus.inactive.toString == "inactive");
    assert(EquipmentStatus.inRepair.toString == "inRepair");
    assert(EquipmentStatus.decommissioned.toString == "decommissioned");
    assert(EquipmentStatus.scrapped.toString == "scrapped");

    assert(toEquipmentStatus(["active", "inactive", "inRepair"]) == [EquipmentStatus.active, EquipmentStatus.inactive, EquipmentStatus.inRepair]);
    assert(toString([EquipmentStatus.active, EquipmentStatus.inactive, EquipmentStatus.inRepair]) == ["active", "inactive", "inRepair"]);   
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
EquipmentType toEquipmentType(string value) {
    mixin(EnumSwitch("EquipmentType", "machine"));
}
EquipmentType[] toEquipmentType(string[] values) {
    return values.map!(toEquipmentType).array;
}
string toString(EquipmentType type) {
    return type.to!string;
}
string[] toStrings(EquipmentType[] types) {
    return types.map!(toString).array;
}
///
unittest {
    mixin(ShowTest!("EquipmentType enumeration"));  

    assert("machine".toEquipmentType == EquipmentType.machine);
    assert("tool".toEquipmentType == EquipmentType.tool);
    assert("vehicle".toEquipmentType == EquipmentType.vehicle);
    assert("sensor".toEquipmentType == EquipmentType.sensor);
    assert("hvac".toEquipmentType == EquipmentType.hvac);
    assert("electrical".toEquipmentType == EquipmentType.electrical);
    assert("plumbing".toEquipmentType == EquipmentType.plumbing);
    assert("it".toEquipmentType == EquipmentType.it);
    assert("custom".toEquipmentType == EquipmentType.custom);

    assert("".toEquipmentType == EquipmentType.machine); // Default case
    assert("unknown".toEquipmentType == EquipmentType.machine); // Default case

    assert(EquipmentType.machine.toString == "machine");
    assert(EquipmentType.tool.toString == "tool");
    assert(EquipmentType.vehicle.toString == "vehicle");
    assert(EquipmentType.sensor.toString == "sensor");
    assert(EquipmentType.hvac.toString == "hvac");
    assert(EquipmentType.electrical.toString == "electrical");
    assert(EquipmentType.plumbing.toString == "plumbing");
    assert(EquipmentType.it.toString == "it");
    assert(EquipmentType.custom.toString == "custom");

    assert(toEquipmentType(["machine", "tool", "vehicle"]) == [EquipmentType.machine, EquipmentType.tool, EquipmentType.vehicle]);
    assert(toString([EquipmentType.machine, EquipmentType.tool, EquipmentType.vehicle]) == ["machine", "tool", "vehicle"]);
}

enum TechnicianStatus {
    available,
    busy,
    onLeave,
    offline,
    inactive
}
TechnicianStatus toTechnicianStatus(string value) {
    mixin(EnumSwitch("TechnicianStatus", "available"));
}
TechnicianStatus[] toTechnicianStatus(string[] values) {
    return values.map!(toTechnicianStatus).array;
}
string toString(TechnicianStatus status) {
    return status.to!string;
}
string[] toStrings(TechnicianStatus[] statuses) {
    return statuses.map!(toString).array;
}
///
unittest {
    mixin(ShowTest!("TechnicianStatus enumeration"));

    assert("available".toTechnicianStatus == TechnicianStatus.available);
    assert("busy".toTechnicianStatus == TechnicianStatus.busy);
    assert("onLeave".toTechnicianStatus == TechnicianStatus.onLeave);
    assert("offline".toTechnicianStatus == TechnicianStatus.offline);
    assert("inactive".toTechnicianStatus == TechnicianStatus.inactive); 

    assert("".toTechnicianStatus == TechnicianStatus.available); // Default case
    assert("unknown".toTechnicianStatus == TechnicianStatus.available); // Default case

    assert(TechnicianStatus.available.toString == "available");
    assert(TechnicianStatus.busy.toString == "busy");
    assert(TechnicianStatus.onLeave.toString == "onLeave");
    assert(TechnicianStatus.offline.toString == "offline");
    assert(TechnicianStatus.inactive.toString == "inactive");

    assert(toTechnicianStatus(["available", "busy", "onLeave"]) == [TechnicianStatus.available, TechnicianStatus.busy, TechnicianStatus.onLeave]);
    assert(toString([TechnicianStatus.available, TechnicianStatus.busy, TechnicianStatus.onLeave]) == ["available", "busy", "onLeave"]);
}

enum CustomerType {
    commercial,
    residential,
    industrial,
    government,
    internal
}
CustomerType toCustomerType(string value) {
    mixin(EnumSwitch("CustomerType", "commercial"));
}
CustomerType[] toCustomerType(string[] values) {
    return values.map!(toCustomerType).array;
}
string toString(CustomerType type) {
    return type.to!string;
}
string[] toStrings(CustomerType[] types) {
    return types.map!(toString).array;
}
/// 
unittest {
    mixin(ShowTest!("CustomerType enumeration"));

    assert("commercial".toCustomerType == CustomerType.commercial);
    assert("residential".toCustomerType == CustomerType.residential);
    assert("industrial".toCustomerType == CustomerType.industrial);
    assert("government".toCustomerType == CustomerType.government);
    assert("internal".toCustomerType == CustomerType.internal);

    assert("".toCustomerType == CustomerType.commercial); // Default case
    assert("unknown".toCustomerType == CustomerType.commercial); // Default case

    assert(CustomerType.commercial.toString == "commercial");
    assert(CustomerType.residential.toString == "residential");
    assert(CustomerType.industrial.toString == "industrial");
    assert(CustomerType.government.toString == "government");
    assert(CustomerType.internal.toString == "internal");

    assert(toCustomerType(["commercial", "residential", "industrial"]) == [CustomerType.commercial, CustomerType.residential, CustomerType.industrial]);
    assert(toString([CustomerType.commercial, CustomerType.residential, CustomerType.industrial]) == ["commercial", "residential", "industrial"]);
}

enum CustomerStatus {
    active,
    inactive,
    prospect,
    blocked
}
CustomerStatus toCustomerStatus(string value) {
    mixin(EnumSwitch("CustomerStatus", "active"));
}
CustomerStatus[] toCustomerStatus(string[] values) {
    return values.map!(toCustomerStatus).array;
}
string toString(CustomerStatus status) {
    return status.to!string;
}
string[] toStrings(CustomerStatus[] statuses) {
    return statuses.map!(toString).array;
}
///
unittest {
    mixin(ShowTest!("CustomerStatus enumeration"));

    assert("active".toCustomerStatus == CustomerStatus.active);
    assert("inactive".toCustomerStatus == CustomerStatus.inactive);
    assert("prospect".toCustomerStatus == CustomerStatus.prospect);
    assert("blocked".toCustomerStatus == CustomerStatus.blocked);   

    assert("".toCustomerStatus == CustomerStatus.active); // Default case
    assert("unknown".toCustomerStatus == CustomerStatus.active); // Default case

    assert(CustomerStatus.active.toString == "active");
    assert(CustomerStatus.inactive.toString == "inactive");
    assert(CustomerStatus.prospect.toString == "prospect");
    assert(CustomerStatus.blocked.toString == "blocked");

    assert(toCustomerStatus(["active", "inactive", "prospect"]) == [CustomerStatus.active, CustomerStatus.inactive, CustomerStatus.prospect]);
    assert(toString([CustomerStatus.active, CustomerStatus.inactive, CustomerStatus.prospect]) == ["active", "inactive", "prospect"]);
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
SkillCategory toSkillCategory(string value) {
    mixin(EnumSwitch("SkillCategory", "technical"));
}
SkillCategory[] toSkillCategory(string[] values) {
    return values.map!(toSkillCategory).array;
}
string toString(SkillCategory category) {
    return category.to!string;
}
string[] toStrings(SkillCategory[] categories) {
    return categories.map!(toString).array;
}
///
unittest {
    mixin(ShowTest!("SkillCategory enumeration"));

    assert("technical".toSkillCategory == SkillCategory.technical);
    assert("certification".toSkillCategory == SkillCategory.certification);
    assert("product".toSkillCategory == SkillCategory.product);
    assert("safety".toSkillCategory == SkillCategory.safety);
    assert("language".toSkillCategory == SkillCategory.language);
    assert("soft".toSkillCategory == SkillCategory.soft);
    assert("custom".toSkillCategory == SkillCategory.custom);

    assert("".toSkillCategory == SkillCategory.technical); // Default case
    assert("unknown".toSkillCategory == SkillCategory.technical); // Default case

    assert(SkillCategory.technical.toString == "technical");
    assert(SkillCategory.certification.toString == "certification");
    assert(SkillCategory.product.toString == "product");
    assert(SkillCategory.safety.toString == "safety");
    assert(SkillCategory.language.toString == "language");
    assert(SkillCategory.soft.toString == "soft");
    assert(SkillCategory.custom.toString == "custom");

    assert(toSkillCategory(["technical", "certification", "product"]) == [SkillCategory.technical, SkillCategory.certification, SkillCategory.product]);
    assert(toString([SkillCategory.technical, SkillCategory.certification, SkillCategory.product]) == ["technical", "certification", "product"]);
}

enum ProficiencyLevel {
    beginner,
    intermediate,
    advanced,
    expert,
    master
}
ProficiencyLevel toProficiencyLevel(string value) {
    mixin(EnumSwitch("ProficiencyLevel", "beginner"));
}
ProficiencyLevel[] toProficiencyLevel(string[] values) {
    return values.map!(toProficiencyLevel).array;
}
string toString(ProficiencyLevel level) {
    return level.to!string;
}
string[] toStrings(ProficiencyLevel[] levels) {
    return levels.map!(toString).array;
}
///
unittest {
    mixin(ShowTest!("ProficiencyLevel enumeration"));   

    assert("beginner".toProficiencyLevel == ProficiencyLevel.beginner);
    assert("intermediate".toProficiencyLevel == ProficiencyLevel.intermediate);
    assert("advanced".toProficiencyLevel == ProficiencyLevel.advanced);
    assert("expert".toProficiencyLevel == ProficiencyLevel.expert);
    assert("master".toProficiencyLevel == ProficiencyLevel.master); 

    assert("".toProficiencyLevel == ProficiencyLevel.beginner); // Default case
    assert("unknown".toProficiencyLevel == ProficiencyLevel.beginner); // Default case

    assert(ProficiencyLevel.beginner.toString == "beginner");
    assert(ProficiencyLevel.intermediate.toString == "intermediate");
    assert(ProficiencyLevel.advanced.toString == "advanced");
    assert(ProficiencyLevel.expert.toString == "expert");
    assert(ProficiencyLevel.master.toString == "master");   

    assert(toProficiencyLevel(["beginner", "intermediate", "advanced"]) == [ProficiencyLevel.beginner, ProficiencyLevel.intermediate, ProficiencyLevel.advanced]);
    assert(toString([ProficiencyLevel.beginner, ProficiencyLevel.intermediate, ProficiencyLevel.advanced]) == ["beginner", "intermediate", "advanced"]);
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
SmartformType toSmartformType(string value) {
    mixin(EnumSwitch("SmartformType", "checklist"));
}
SmartformType[] toSmartformType(string[] values) {
    return values.map!(toSmartformType).array;
}
string toString(SmartformType type) {
    return type.to!string;
}
string[] toStrings(SmartformType[] types) {
    return types.map!(toString).array;
}
/// 
unittest {
    mixin(ShowTest!("SmartformType enumeration"));   

    assert("checklist".toSmartformType == SmartformType.checklist);
    assert("serviceReport".toSmartformType == SmartformType.serviceReport);
    assert("inspection".toSmartformType == SmartformType.inspection);
    assert("safety".toSmartformType == SmartformType.safety);
    assert("feedback".toSmartformType == SmartformType.feedback);
    assert("survey".toSmartformType == SmartformType.survey);
    assert("workInstruction".toSmartformType == SmartformType.workInstruction);
    assert("handover".toSmartformType == SmartformType.handover);
    assert("custom".toSmartformType == SmartformType.custom); 

    assert("".toSmartformType == SmartformType.checklist); // Default case
    assert("unknown".toSmartformType == SmartformType.checklist); // Default case

    assert(SmartformType.checklist.toString == "checklist");
    assert(SmartformType.serviceReport.toString == "serviceReport");
    assert(SmartformType.inspection.toString == "inspection");
    assert(SmartformType.safety.toString == "safety");
    assert(SmartformType.feedback.toString == "feedback");
    assert(SmartformType.survey.toString == "survey");
    assert(SmartformType.workInstruction.toString == "workInstruction");
    assert(SmartformType.handover.toString == "handover");
    assert(SmartformType.custom.toString == "custom");   

    assert(toSmartformType(["checklist", "serviceReport", "inspection"]) == [SmartformType.checklist, SmartformType.serviceReport, SmartformType.inspection]);
    assert(toString([SmartformType.checklist, SmartformType.serviceReport, SmartformType.inspection]) == ["checklist", "serviceReport", "inspection"]);
}

enum SmartformStatus {
    draft,
    inProgress,
    submitted,
    approved,
    rejected,
    archived
}
SmartformStatus toSmartformStatus(string value) {
    mixin(EnumSwitch("SmartformStatus", "draft"));
}
SmartformStatus[] toSmartformStatus(string[] values) {
    return values.map!(toSmartformStatus).array;
}
string toString(SmartformStatus status) {
    return status.to!string;
}
string[] toStrings(SmartformStatus[] statuses) {
    return statuses.map!(toString).array;
}
///
unittest {
    mixin(ShowTest!("SmartformStatus enumeration"));

    assert("draft".toSmartformStatus == SmartformStatus.draft);
    assert("inProgress".toSmartformStatus == SmartformStatus.inProgress);
    assert("submitted".toSmartformStatus == SmartformStatus.submitted);
    assert("approved".toSmartformStatus == SmartformStatus.approved);
    assert("rejected".toSmartformStatus == SmartformStatus.rejected);
    assert("archived".toSmartformStatus == SmartformStatus.archived);   

    assert("".toSmartformStatus == SmartformStatus.draft); // Default case
    assert("unknown".toSmartformStatus == SmartformStatus.draft); // Default case   

    assert(SmartformStatus.draft.toString == "draft");
    assert(SmartformStatus.inProgress.toString == "inProgress");
    assert(SmartformStatus.submitted.toString == "submitted");
    assert(SmartformStatus.approved.toString == "approved");
    assert(SmartformStatus.rejected.toString == "rejected");        
    assert(SmartformStatus.archived.toString == "archived");

    assert(toSmartformStatus(["draft", "inProgress", "submitted"]) == [SmartformStatus.draft, SmartformStatus.inProgress, SmartformStatus.submitted]);
    assert(toString([SmartformStatus.draft, SmartformStatus.inProgress, SmartformStatus.submitted]) == ["draft", "inProgress", "submitted"]);
}
