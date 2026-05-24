module uim.platform.situation_automation.domain.types;
import uim.platform.situation_automation;

mixin(ShowModule!());

@safe:
// ID aliases
struct SituationTemplateId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}
struct SituationInstanceId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}
struct SituationActionId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}
struct AutomationRuleId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}
struct EntityTypeId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}
struct DataContextId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}
struct NotificationId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}
struct DashboardId  {
    string value;

    this(string value) {
        this.value = value;
    }

    mixin DomainId;
}
