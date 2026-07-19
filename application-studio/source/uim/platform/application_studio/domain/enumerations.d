/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.application_studio.domain.enumerations;

import uim.platform.application_studio;
mixin(ShowModule!());

@safe:

enum DevSpaceStatus {
    // Dev space is in the process of being created and initialized. During this phase, necessary resources are being allocated, and the environment is being set up. Users may not be able to access the dev space until it transitions to the running status. 
    starting,
    // Dev space is fully operational and ready for use. In this status, users can access the dev space, run applications, and perform development activities without any issues.
    running,
    // Dev space has been stopped and is no longer running. In this status, the dev space is not operational, and users cannot access it or run applications until it is started again. This status may occur when a user manually stops the dev space or when it is automatically stopped due to inactivity or other conditions.
    stopped,
    // Dev space is in the process of being stopped. During this phase, ongoing processes are being terminated, and resources are being released. Users may not be able to access the dev space until it transitions to the stopped status.
    stopping,
    // Dev space has encountered an error that prevents it from running properly. In this status, the dev space may be inaccessible, and users may not be able to perform development activities until the underlying issue is resolved. This status indicates that there is a problem that needs attention and may require troubleshooting or support to fix.
    error,
    // Dev space has been archived and is no longer active. In this status, the dev space is preserved for historical or reference purposes but is not intended for active development. Users may not be able to access or modify the dev space, and it may be stored in a read-only state. This status indicates that the dev space is being retained for future reference but is not currently in use.
    archived,
    // Dev space is in a hibernated state. In this status, the dev space is temporarily inactive but can be quickly resumed when needed. Users may not be able to access the dev space until it is resumed.
    hibernated,
    // Dev space is in the process of being hibernated. During this phase, the dev space is being transitioned to a low-power state, and resources are being conserved. Users may not be able to access the dev space until it transitions to the hibernated status.
    hibernating,
    // Dev space is in the process of being resumed from a hibernated state. During this phase, the dev space is being reactivated and resources are being allocated to bring it back to an operational state. Users may not be able to access the dev space until it transitions back to the running status.
    resuming,
    // Dev space is in the process of being deleted. During this phase, the dev
    deleting,
    // Dev space has been deleted and is no longer available. In this status, the dev space has been permanently removed, and users cannot access it or recover any data associated with it. This status indicates that the dev space has been intentionally removed and is no longer part of the system.
    deleted
}
DevSpaceStatus toDevSpaceStatus(string value) {
    mixin(EnumSwitch("DevSpaceStatus", "starting"));
}
DevSpaceStatus[] toDevSpaceStatuses(string[] statuses) {
    return statuses.map!(toDevSpaceStatus).array;
}
string toString(DevSpaceStatus status) {
    return status.to!string;
}
string[] toStrings(DevSpaceStatus[] statuses) {
    return statuses.map!(toString).array;
}
///
unittest {
    mixin(ShowTest!("DevSpaceStatus"));

    assert(DevSpaceStatus.starting.toString == "starting");
    assert(DevSpaceStatus.running.toString == "running");
    assert(DevSpaceStatus.stopped.toString == "stopped");
    assert(DevSpaceStatus.stopping.toString == "stopping");
    assert(DevSpaceStatus.error.toString == "error");
    assert(DevSpaceStatus.archived.toString == "archived");
    assert(DevSpaceStatus.hibernated.toString == "hibernated");
    assert(DevSpaceStatus.hibernating.toString == "hibernating");
    assert(DevSpaceStatus.resuming.toString == "resuming");
    assert(DevSpaceStatus.deleting.toString == "deleting");
    assert(DevSpaceStatus.deleted.toString == "deleted");

    assert("".toDevSpaceStatus == DevSpaceStatus.starting); // Default case
    assert("noexists".toDevSpaceStatus == DevSpaceStatus.starting); // Default case

    assert("starting".toDevSpaceStatus == DevSpaceStatus.starting);
    assert("running".toDevSpaceStatus == DevSpaceStatus.running);
    assert("stopped".toDevSpaceStatus == DevSpaceStatus.stopped);
    assert("stopping".toDevSpaceStatus == DevSpaceStatus.stopping);
    assert("error".toDevSpaceStatus == DevSpaceStatus.error);
    assert("archived".toDevSpaceStatus == DevSpaceStatus.archived);
    assert("hibernated".toDevSpaceStatus == DevSpaceStatus.hibernated);
    assert("hibernating".toDevSpaceStatus == DevSpaceStatus.hibernating);
    assert("resuming".toDevSpaceStatus == DevSpaceStatus.resuming);
    assert("deleting".toDevSpaceStatus == DevSpaceStatus.deleting);
    assert("deleted".toDevSpaceStatus == DevSpaceStatus.deleted);

    assert(["starting", "running", "stopped", "stopping", "error", "archived", "hibernated", "hibernating", "resuming", "deleting", "deleted"].toDevSpaceStatuses ==
           [DevSpaceStatus.starting, DevSpaceStatus.running, DevSpaceStatus.stopped, DevSpaceStatus.stopping, DevSpaceStatus.error, DevSpaceStatus.archived, DevSpaceStatus.hibernated, DevSpaceStatus.hibernating, DevSpaceStatus.resuming, DevSpaceStatus.deleting, DevSpaceStatus.deleted]);
    assert(toString([DevSpaceStatus.starting, DevSpaceStatus.running, DevSpaceStatus.stopped, DevSpaceStatus.stopping, DevSpaceStatus.error, DevSpaceStatus.archived, DevSpaceStatus.hibernated, DevSpaceStatus.hibernating, DevSpaceStatus.resuming, DevSpaceStatus.deleting, DevSpaceStatus.deleted]) ==
           ["starting", "running", "stopped", "stopping", "error", "archived", "hibernated", "hibernating", "resuming", "deleting", "deleted"]);    
}

enum DevSpacePlan {
    // The free plan offers a basic set of features and resources suitable for individual developers or small projects. It typically includes limited compute resources, storage, and access to a predefined set of tools and services. The free plan is ideal for learning, experimentation, and small-scale development activities.
    free,
    // The standard plan provides a more comprehensive set of features and resources compared to the free plan. It is designed for professional developers and teams working on larger projects. The standard plan may include increased compute resources, additional storage, access to a wider range of tools and services, and enhanced support options. This plan is suitable for production-level development and collaboration.
    standard,
    // The professional plan offers the highest level of features and resources, catering to enterprise-level development and large-scale projects. It includes maximum compute resources, extensive storage, advanced tools and services, and premium support options. This plan is ideal for organizations with complex development needs and high-performance requirements.
    professional
}
DevSpacePlan toDevSpacePlan(string value) {
    mixin(EnumSwitch("DevSpacePlan", "free"));
}
DevSpacePlan[] toDevSpacePlans(string[] plans) {
    return plans.map!(toDevSpacePlan).array;
}
string toString(DevSpacePlan plan) {
    return plan.to!string;
}
string[] toStrings(DevSpacePlan[] plans) {
    return plans.map!(toString).array;
}
///
unittest {
    mixin(ShowTest!("DevSpacePlan"));

    assert(DevSpacePlan.free.toString == "free");
    assert(DevSpacePlan.standard.toString == "standard");
    assert(DevSpacePlan.professional.toString == "professional");

    assert("".toDevSpacePlan == DevSpacePlan.free); // Default case
    assert("noexists".toDevSpacePlan == DevSpacePlan.free); // Default case

    assert("free".toDevSpacePlan == DevSpacePlan.free);
    assert("standard".toDevSpacePlan == DevSpacePlan.standard);
    assert("professional".toDevSpacePlan == DevSpacePlan.professional);

    assert(["free", "standard", "professional"].toDevSpacePlans ==
           [DevSpacePlan.free, DevSpacePlan.standard, DevSpacePlan.professional]);
    assert(toString([DevSpacePlan.free, DevSpacePlan.standard, DevSpacePlan.professional]) ==
           ["free", "standard", "professional"]);    
}

enum DevSpaceTypeCategory {
    // The predefined category includes dev space types that are provided out-of-the-box by the platform. These dev space types are typically designed to cater to common development scenarios and may come with pre-configured settings, tools, and resources. Users can choose from these predefined dev space types based on their specific development needs without requiring extensive customization.
    predefined,
    // The custom category allows users to create their own dev space types with specific configurations, tools, and resources tailored to their unique development requirements. Custom dev space types provide flexibility and enable users to define their own environments that may not be covered by the predefined options. This category is ideal for advanced users or teams with specialized development needs that require a more personalized setup.
    custom,
    // The third-party category includes dev space types that are provided by external vendors or community contributors. These dev space types may offer specialized configurations, tools, or integrations that are not available in the predefined or custom categories. Users can explore and utilize third-party dev space types to enhance their development experience and access additional features or capabilities that may be relevant to their projects.
    thirdParty
}
DevSpaceTypeCategory toDevSpaceTypeCategory(string value) {
    mixin(EnumSwitch("DevSpaceTypeCategory", "predefined"));
}
DevSpaceTypeCategory[] toDevSpaceTypeCategories(string[] categories) {
    return categories.map!(toDevSpaceTypeCategory).array;
}
string toString(DevSpaceTypeCategory category) {
    return category.to!string;
}
string[] toStrings(DevSpaceTypeCategory[] categories) {
    return categories.map!(toString).array;
}
///
unittest {
    mixin(ShowTest!("DevSpaceTypeCategory"));

    assert(DevSpaceTypeCategory.predefined.toString == "predefined");
    assert(DevSpaceTypeCategory.custom.toString == "custom");
    assert(DevSpaceTypeCategory.thirdParty.toString == "thirdParty");

    assert("".toDevSpaceTypeCategory == DevSpaceTypeCategory.predefined); // Default case
    assert("noexists".toDevSpaceTypeCategory == DevSpaceTypeCategory.predefined); // Default case

    assert("predefined".toDevSpaceTypeCategory == DevSpaceTypeCategory.predefined);
    assert("custom".toDevSpaceTypeCategory == DevSpaceTypeCategory.custom);
    assert("thirdParty".toDevSpaceTypeCategory == DevSpaceTypeCategory.thirdParty);

    assert(["predefined", "custom", "thirdParty"].toDevSpaceTypeCategories ==
           [DevSpaceTypeCategory.predefined, DevSpaceTypeCategory.custom, DevSpaceTypeCategory.thirdParty]);
    assert(toString([DevSpaceTypeCategory.predefined, DevSpaceTypeCategory.custom, DevSpaceTypeCategory.thirdParty]) ==
           ["predefined", "custom", "thirdParty"]);
}

enum ExtensionScope {
    // The predefined scope includes extensions that are provided out-of-the-box by the platform
    predefined,
    // The additional scope includes extensions that are developed and maintained by the platform provider as part of their ongoing efforts to enhance the platform's capabilities. These extensions may be released periodically and can offer new features, integrations, or improvements to existing functionalities. Users can choose to enable or utilize these additional extensions based on their specific needs and preferences.
    additional,
    // The third-party scope includes extensions that are developed and maintained by external vendors, community contributors, or independent developers. These extensions may offer specialized features, integrations, or customizations that are not provided by the platform provider. Users can explore and utilize third-party extensions to enhance their development experience and access additional functionalities that may be relevant to their projects.
    thirdParty
}
ExtensionScope toExtensionScope(string value) {
    mixin(EnumSwitch("ExtensionScope", "predefined"));
}
ExtensionScope[] toExtensionScope(string[] scopes) {
    return scopes.map!(toExtensionScope).array;
}
string toString(ExtensionScope value) {
    return value.to!string;
}
string[] toStrings(ExtensionScope[] scopes) {
    return scopes.map!(toString).array;
}
/// 
unittest {
    mixin(ShowTest!("ExtensionScope"));

    assert(ExtensionScope.predefined.toString == "predefined");
    assert(ExtensionScope.additional.toString == "additional");
    assert(ExtensionScope.thirdParty.toString == "thirdParty");

    assert("".toExtensionScope == ExtensionScope.predefined); // Default case
    assert("noexists".toExtensionScope == ExtensionScope.predefined); // Default case

    assert("predefined".toExtensionScope == ExtensionScope.predefined);
    assert("additional".toExtensionScope == ExtensionScope.additional);
    assert("thirdParty".toExtensionScope == ExtensionScope.thirdParty);

    assert(["predefined", "additional", "thirdParty"].toExtensionScope ==
           [ExtensionScope.predefined, ExtensionScope.additional, ExtensionScope.thirdParty]);
    assert(toString([ExtensionScope.predefined, ExtensionScope.additional, ExtensionScope.thirdParty]) ==
           ["predefined", "additional", "thirdParty"]);
}

enum ExtensionStatus : string {
    // The active status indicates that the extension is currently enabled and functioning properly within the application studio environment. In this status, users can utilize the features and capabilities provided by the extension without any issues. The active status signifies that the extension is fully operational and ready for use.
    active = "active",
    // The inactive status indicates that the extension is currently disabled or not functioning properly within the application studio environment. In this status, users may not be able to access or utilize the features and capabilities provided by the extension. The inactive status signifies that there may be issues with the extension that need to be addressed before it can be used effectively.
    inactive = "inactive",
    // The deprecated status indicates that the extension is no longer recommended for use and may be removed in future releases of the application studio. In this status, users are discouraged from using the extension, and it may not receive updates or support from the platform provider. The deprecated status signifies that there are better alternatives available, and users should consider transitioning to those alternatives for improved functionality and support.
    deprecated_ = "deprecated"
}
ExtensionStatus toExtensionStatus(string s) {
    switch(s.toLower) {
        case "active": return ExtensionStatus.active;
        case "inactive": return ExtensionStatus.inactive;
        case "deprecated": return ExtensionStatus.deprecated_;
        default: return ExtensionStatus.inactive; // Default case
    }
}
ExtensionStatus[] toExtensionStatus(string[] statuses) {
    return statuses.map!(toExtensionStatus).array;
}
string toString(ExtensionStatus status) {
    return cast(string)status;
}
string[] toStrings(ExtensionStatus[] statuses) {
    return statuses.map!(toString).array;
}
///
unittest {
    mixin(ShowTest!("ExtensionStatus"));

    assert(ExtensionStatus.active.toString == "active");
    assert(ExtensionStatus.inactive.toString == "inactive");
    assert(ExtensionStatus.deprecated_.toString == "deprecated");

    assert("".toExtensionStatus == ExtensionStatus.inactive); // Default case
    assert("noexists".toExtensionStatus == ExtensionStatus.inactive); // Default case

    assert("active".toExtensionStatus == ExtensionStatus.active);
    assert("inactive".toExtensionStatus == ExtensionStatus.inactive);
    assert("deprecated".toExtensionStatus == ExtensionStatus.deprecated_);

    assert(["active", "inactive", "deprecated"].toExtensionStatus ==
           [ExtensionStatus.active, ExtensionStatus.inactive, ExtensionStatus.deprecated_]);
    assert(toString([ExtensionStatus.active, ExtensionStatus.inactive, ExtensionStatus.deprecated_]) ==
           ["active", "inactive", "deprecated"]);
}

enum ProjectType {
    // The SAP Fiori project type is designed for developing applications that follow the SAP Fiori design principles and guidelines. These applications typically provide a consistent and intuitive user experience across different devices and platforms, leveraging SAP's UI technologies and best practices for building modern enterprise applications.
    sapFiori,
    // The CAP Node.js project type is tailored for developing applications using the SAP Cloud Application Programming Model (CAP) with Node.js as the runtime environment. This project type provides a framework and tools for building scalable and efficient applications that can run on SAP's cloud platform, leveraging the capabilities of Node.js for server-side development.
    capNodeJs,
    // The CAP Java project type is tailored for developing applications using the SAP Cloud Application Programming Model (CAP) with Java as the runtime environment. This project type provides a framework and tools for building scalable and efficient applications that can run on SAP's cloud platform, leveraging the capabilities of Java for server-side development.
    capJava,
    // The HANA Native project type is designed for developing applications that run natively on the SAP HANA database. This project type allows developers to leverage the in-memory capabilities of SAP HANA for building high-performance applications that can process large volumes of data and provide real-time insights.
    hanaNative,
    // The SAP UI5 project type is designed for developing applications using the SAP UI5 framework. This project type provides a set of tools and libraries for building responsive and user-friendly web applications that follow SAP's design guidelines.
    sapUi5,
    // The MDK project type is tailored for developing applications using the SAP Mobile Development Kit (MDK). This project type provides a framework and tools for building mobile applications that can run on various platforms, leveraging the capabilities of MDK for mobile development.
    mdk,
    // The Workflow project type is designed for developing applications that involve workflow processes and automation. This project type provides tools and frameworks for building applications that can orchestrate and manage complex workflows, enabling users to automate business processes and improve efficiency.
    workflow,
    // The Multitarget project type is designed for developing applications that can target multiple platforms and runtimes. This project type provides a flexible framework and tools for building applications that can run on different environments, allowing developers to create versatile applications that can reach a wider audience.
    multitarget,
    // The Basic project type is a general-purpose project type that does not fall into any specific category. It provides a simple and flexible framework for developing applications that may not require the specialized features or configurations of the other project types. The Basic project type is suitable for a wide range of development scenarios and can be customized to meet specific requirements.
    basic,
    // The SAP Cloud Application Programming Model (CAP) project type is designed for developing applications using the SAP Cloud Application Programming Model (CAP). This project type provides a comprehensive framework and tools for building scalable and efficient applications that can run on SAP's cloud platform, leveraging the capabilities of CAP for server-side development.
    cap,
    // The SAP Fiori Elements project type is designed for developing applications that follow the SAP Fiori Elements design principles and guidelines. These applications typically provide a consistent and intuitive user experience across different devices and platforms, leveraging SAP's UI technologies and best practices for building modern enterprise applications with a focus on data-driven interfaces.
    sapFioriElements,    
    // The SAP Business Application Studio project type is a general-purpose project type that is specifically tailored for development within the SAP Business Application Studio environment. This project type provides a flexible framework and tools for building applications that can leverage the capabilities of the SAP Business Application Studio, allowing developers to create applications that are optimized for this specific development environment.
    businessApplicationStudio,
    // The SAP S/4HANA project type is designed for developing applications that integrate with or extend the capabilities of SAP S/4HANA, which is SAP's next-generation enterprise resource planning (ERP) suite. This project type provides tools and frameworks for building applications that can interact with SAP S/4HANA's data and services, enabling developers to create solutions that enhance the functionality of SAP S/4HANA and meet specific business requirements.
    s4hana,
    // The SAP SuccessFactors project type is designed for developing applications that integrate with or extend the capabilities of SAP SuccessFactors, which is SAP's cloud-based human capital management (HCM) suite. This project type provides tools and frameworks for building applications that can interact with SAP SuccessFactors' data and services, enabling developers to create solutions that enhance the functionality of SAP SuccessFactors and meet specific HR-related business requirements.
    successFactors,
    // The SAP Ariba project type is designed for developing applications that integrate with or extend the capabilities of SAP Ariba, which is SAP's cloud-based procurement and supply chain management suite. This project type provides tools and frameworks for building applications that can interact with SAP Ariba's data and services, enabling developers to create solutions that enhance the functionality of SAP Ariba and meet specific procurement-related business requirements.
    ariba,
    // The SAP Concur project type is designed for developing applications that integrate with or extend the capabilities of SAP Concur, which is SAP's cloud-based travel and expense management suite. This project type provides tools and frameworks for building applications that can interact with SAP Concur's data and services, enabling developers to create solutions that enhance the functionality of SAP Concur and meet specific travel and expense-related business requirements.
    concur,
    // The SAP Customer Experience (CX) project type is designed for developing applications that integrate with or extend the capabilities of SAP Customer Experience (CX), which is SAP's suite of customer relationship management (CRM) and customer experience management solutions. This project type provides tools and frameworks for building applications that can interact with SAP CX's data and services, enabling developers to create solutions that enhance the functionality of SAP CX and meet specific customer experience-related business requirements.
    customerExperience,
    // The SAP Internet of Things (IoT) project type is designed for developing applications that integrate with or extend the capabilities of SAP's Internet of Things (IoT) solutions. This project type provides tools and frameworks for building applications that can interact with IoT devices, sensors, and data, enabling developers to create solutions that leverage IoT technologies to enhance business processes and outcomes.
    iot,
    // The SAP Analytics Cloud (SAC) project type is designed for developing applications that integrate with or extend the capabilities of SAP Analytics Cloud (SAC), which is SAP's cloud-based analytics and business intelligence platform. This project type provides tools and frameworks for building applications that can interact with SAC's data and services, enabling developers to create solutions that enhance the functionality of SAC and meet specific analytics-related business requirements.
    analyticsCloud,
    // The SAP Cloud Platform Integration (CPI) project type is designed for developing applications that integrate with or extend the capabilities of SAP Cloud Platform Integration (CPI), which is SAP's cloud-based integration platform. This project type provides tools and frameworks for building applications that can interact with CPI's data and services, enabling developers to create solutions that enhance the functionality of CPI and meet specific integration-related business requirements.
    cpi,
    // The SAP Cloud Platform Extension Factory (CFX) project type is designed for developing applications that integrate with or extend the capabilities of SAP Cloud Platform Extension Factory (CFX), which is SAP's platform for building and deploying extensions to SAP applications. This project type provides tools and frameworks for building applications that can interact with CFX's data and services, enabling developers to create solutions that enhance the functionality of CFX and meet specific extension-related business requirements.
    cfx,
    // The SAP Cloud Platform Workflow (CPWF) project type is designed for developing applications that integrate with or extend the capabilities of SAP Cloud Platform Workflow (CPWF), which is SAP's cloud-based workflow management solution. This project type provides tools and frameworks for building applications that can interact with CPWF's data and services, enabling developers to create solutions that enhance the functionality of CPWF and meet specific workflow-related business requirements.
    cpwf,
    // The SAP Cloud Platform Business Process Management (CPBM) project type is designed for developing applications that integrate with or extend the capabilities of SAP Cloud Platform Business Process Management (CPBM), which is SAP's cloud-based business process management solution. This project type provides tools and frameworks for building applications that can interact with CPBM's data and services, enabling developers to create solutions that enhance the functionality of CPBM and meet specific business process management-related business requirements.
    cpbm,
    // The SAP Cloud Platform Robotic Process Automation (RPA) project type is designed for developing applications that integrate with or extend the capabilities of SAP Cloud Platform Robotic Process Automation (RPA), which is SAP's cloud-based robotic process automation solution. This project type provides tools and frameworks for building applications that can interact with RPA's data and services, enabling developers to create solutions that enhance the functionality of RPA and meet specific robotic process automation-related business requirements.
    rpa,
    // The SAP Cloud Platform Artificial Intelligence (AI) project type is designed for developing applications that integrate with or extend the capabilities of SAP Cloud Platform Artificial Intelligence (AI), which is SAP's cloud-based artificial intelligence solution. This project type provides tools and frameworks for building applications that can interact with AI's data and services, enabling developers to create solutions that enhance the functionality of AI and meet specific artificial intelligence-related business requirements.
    ai    
}
ProjectType toProjectType(string value) {
    mixin(EnumSwitch("ProjectType", "sapFiori"));
}
ProjectType[] toProjectTypes(string[] values) {
    return values.map!(toProjectType).array;
}
string toString(ProjectType value) {
    return value.to!string;
}
string[] toStrings(ProjectType[] values) {
    return values.map!(toString).array;
}
/// 
unittest {
    mixin(ShowTest!("ProjectType"));

    assert(ProjectType.sapFiori.toString == "sapFiori");
    assert(ProjectType.capNodeJs.toString == "capNodeJs");
    assert(ProjectType.capJava.toString == "capJava");
    assert(ProjectType.hanaNative.toString == "hanaNative");
    assert(ProjectType.sapUi5.toString == "sapUi5");
    assert(ProjectType.mdk.toString == "mdk");
    assert(ProjectType.workflow.toString == "workflow");
    assert(ProjectType.multitarget.toString == "multitarget");
    assert(ProjectType.basic.toString == "basic");
    assert(ProjectType.cap.toString == "cap");
    assert(ProjectType.sapFioriElements.toString == "sapFioriElements");
    assert(ProjectType.businessApplicationStudio.toString == "businessApplicationStudio");
    assert(ProjectType.s4hana.toString == "s4hana");
    assert(ProjectType.successFactors.toString == "successFactors");
    assert(ProjectType.ariba.toString == "ariba");
    assert(ProjectType.concur.toString == "concur");
    assert(ProjectType.customerExperience.toString == "customerExperience");
    assert(ProjectType.iot.toString == "iot");
    assert(ProjectType.analyticsCloud.toString == "analyticsCloud");
    assert(ProjectType.cpi.toString == "cpi");
    assert(ProjectType.cfx.toString == "cfx");
    assert(ProjectType.cpwf.toString == "cpwf");
    assert(ProjectType.cpbm.toString == "cpbm");
    assert(ProjectType.rpa.toString == "rpa");
    assert(ProjectType.ai.toString == "ai");

    assert("".toProjectType == ProjectType.sapFiori); // Default case
    assert("noexists".toProjectType == ProjectType.sapFiori); // Default case

    assert("sapFiori".toProjectType == ProjectType.sapFiori);
    assert("capNodeJs".toProjectType == ProjectType.capNodeJs);
    assert("capJava".toProjectType == ProjectType.capJava);
    assert("hanaNative".toProjectType == ProjectType.hanaNative);
    assert("sapUi5".toProjectType == ProjectType.sapUi5);
    assert("mdk".toProjectType == ProjectType.mdk);
    assert("workflow".toProjectType == ProjectType.workflow);
    assert("multitarget".toProjectType == ProjectType.multitarget);
    assert("basic".toProjectType == ProjectType.basic);
    assert("cap".toProjectType == ProjectType.cap);
    assert("sapFioriElements".toProjectType == ProjectType.sapFioriElements);
    assert("businessApplicationStudio".toProjectType == ProjectType.businessApplicationStudio);
    assert("s4hana".toProjectType == ProjectType.s4hana);
    assert("successFactors".toProjectType == ProjectType.successFactors);
    assert("ariba".toProjectType == ProjectType.ariba);
    assert("concur".toProjectType == ProjectType.concur);
    assert("customerExperience".toProjectType == ProjectType.customerExperience);
    assert("iot".toProjectType == ProjectType.iot);
    assert("analyticsCloud".toProjectType == ProjectType.analyticsCloud);
    assert("cpi".toProjectType == ProjectType.cpi);
    assert("cfx".toProjectType == ProjectType.cfx);
    assert("cpwf".toProjectType == ProjectType.cpwf);
    assert("cpbm".toProjectType == ProjectType.cpbm);
    assert("rpa".toProjectType == ProjectType.rpa);
    assert("ai".toProjectType == ProjectType.ai);

    assert(["sapFiori", "capNodeJs", "capJava", "hanaNative", "sapUi5", "mdk", "workflow", "multitarget", "basic", "cap", "sapFioriElements", "businessApplicationStudio", "s4hana", "successFactors", "ariba", "concur", "customerExperience", "iot", "analyticsCloud", "cpi", "cfx", "cpwf", "cpbm", "rpa", "ai"].toProjectTypes ==
           [ProjectType.sapFiori, ProjectType.capNodeJs, ProjectType.capJava, ProjectType.hanaNative, ProjectType.sapUi5, ProjectType.mdk, ProjectType.workflow, ProjectType.multitarget, ProjectType.basic, ProjectType.cap, ProjectType.sapFioriElements, ProjectType.businessApplicationStudio, ProjectType.s4hana, ProjectType.successFactors, ProjectType.ariba, ProjectType.concur, ProjectType.customerExperience, ProjectType.iot, ProjectType.analyticsCloud, ProjectType.cpi, ProjectType.cfx, ProjectType.cpwf, ProjectType.cpbm, ProjectType.rpa, ProjectType.ai]);
    assert(toString([ProjectType.sapFiori, ProjectType.capNodeJs, ProjectType.capJava, ProjectType.hanaNative, ProjectType.sapUi5, ProjectType.mdk, ProjectType.workflow, ProjectType.multitarget, ProjectType.basic, ProjectType.cap, ProjectType.sapFioriElements, ProjectType.businessApplicationStudio, ProjectType.s4hana, ProjectType.successFactors, ProjectType.ariba, ProjectType.concur, ProjectType.customerExperience, ProjectType.iot, ProjectType.analyticsCloud, ProjectType.cpi, ProjectType.cfx, ProjectType.cpwf, ProjectType.cpbm, ProjectType.rpa, ProjectType.ai]) ==
           ["sapFiori", "capNodeJs", "capJava", "hanaNative", "sapUi5", "mdk", "workflow", "multitarget", "basic", "cap", "sapFioriElements", "businessApplicationStudio", "s4hana", "successFactors", "ariba", "concur", "customerExperience", "iot", "analyticsCloud", "cpi", "cfx", "cpwf", "cpbm", "rpa", "ai"]);
}

enum ProjectStatus {
    // The active status indicates that the project is currently active and ongoing. In this status, the project is being actively developed, maintained, or utilized for its intended purpose. Users can access and work on the project without any restrictions, and it is considered to be in a healthy and functional state.
    active,
    // The archived status indicates that the project is no longer active and has been archived for historical or reference purposes. In this status, the project is preserved but is not intended for active development or use. Users may have limited access to the project, and it may be stored in a read-only state. The archived status signifies that the project is being retained for future reference but is not currently in use.
    archived,
    // The building status indicates that the project is currently being built
    building,
    // The deploying status indicates that the project is currently being deployed
    deploying,
    // The error status indicates that the project has encountered an error that prevents it from functioning properly. In this status, users may not be able to access or utilize the project until the underlying issue is resolved. The error status signifies that there is a problem that needs attention and may require troubleshooting or support to fix.
    error
}
ProjectStatus toProjectStatus(string value) {
    mixin(EnumSwitch("ProjectStatus", "active"));
}
ProjectStatus[] toProjectStatuses(string[] values) {
    return values.map!(toProjectStatus).array;
}
string toString(ProjectStatus value) {
    return value.to!string;
}
string[] toStrings(ProjectStatus[] values) {
    return values.map!(toString).array;
}
///
unittest {
    mixin(ShowTest!("ProjectStatus"));

    assert(ProjectStatus.active.toString == "active");
    assert(ProjectStatus.archived.toString == "archived");
    assert(ProjectStatus.building.toString == "building");
    assert(ProjectStatus.deploying.toString == "deploying");
    assert(ProjectStatus.error.toString == "error");

    assert("".toProjectStatus == ProjectStatus.active); // Default case
    assert("noexists".toProjectStatus == ProjectStatus.active); // Default case 

    assert("active".toProjectStatus == ProjectStatus.active);
    assert("archived".toProjectStatus == ProjectStatus.archived);
    assert("building".toProjectStatus == ProjectStatus.building);
    assert("deploying".toProjectStatus == ProjectStatus.deploying);
    assert("error".toProjectStatus == ProjectStatus.error);

    assert(["active", "archived", "building", "deploying", "error"].toProjectStatuses ==
           [ProjectStatus.active, ProjectStatus.archived, ProjectStatus.building, ProjectStatus.deploying, ProjectStatus.error]);
    assert(toString([ProjectStatus.active, ProjectStatus.archived, ProjectStatus.building, ProjectStatus.deploying, ProjectStatus.error]) ==
           ["active", "archived", "building", "deploying", "error"]);
}

enum TemplateCategory {
    // The SAP Fiori template category includes templates that are designed for developing applications that follow the SAP Fiori design principles and guidelines. These templates typically provide a consistent and intuitive user experience across different devices and platforms, leveraging SAP's UI technologies and best practices for building modern enterprise applications.
    sapFiori,
    // The SAP Cloud Application Programming Model (CAP) template category includes templates that are designed for developing applications using the SAP Cloud Application Programming Model (CAP). These templates provide a comprehensive framework and tools for building scalable and efficient applications that can run on SAP's cloud platform, leveraging the capabilities of CAP for server-side development.
    sapCap,
    // The SAP HANA template category includes templates that are designed for developing applications that run natively on the SAP HANA database. These templates allow developers to leverage the in-memory capabilities of SAP HANA for building high-performance applications that can process large volumes of data and provide real-time insights.
    sapHana,
    // The SAP Mobile Development Kit (MDK) template category includes templates that are designed for developing mobile applications using the SAP Mobile Development Kit (MDK). These templates provide a framework and tools for building mobile applications that can run on various platforms, leveraging the capabilities of MDK for mobile development.
    sapMdk,
    // The SAP Workflow template category includes templates that are designed for developing applications that involve workflow processes and automation. These templates provide tools and frameworks for building applications that can orchestrate and manage complex workflows, enabling users to automate business processes and improve efficiency.
    sapWorkflow,
    // The general template category includes templates that do not fall into any specific category.
    general
}
TemplateCategory toTemplateCategory(string value) {
    mixin(EnumSwitch("TemplateCategory", "general"));
}
TemplateCategory[] toTemplateCategories(string[] categories) {
    return categories.map!(toTemplateCategory).array;
}
string toString(TemplateCategory category) {
    return category.to!string;
}
string[] toStrings(TemplateCategory[] categories) {
    return categories.map!(toString).array;
}
///
unittest {
    mixin(ShowTest!("TemplateCategory"));

    assert(TemplateCategory.sapFiori.toString == "sapFiori");
    assert(TemplateCategory.sapCap.toString == "sapCap");
    assert(TemplateCategory.sapHana.toString == "sapHana");
    assert(TemplateCategory.sapMdk.toString == "sapMdk");
    assert(TemplateCategory.sapWorkflow.toString == "sapWorkflow");
    assert(TemplateCategory.general.toString == "general");

    assert("".toTemplateCategory == TemplateCategory.general); // Default case
    assert("noexists".toTemplateCategory == TemplateCategory.general); // Default case

    assert("sapFiori".toTemplateCategory == TemplateCategory.sapFiori);
    assert("sapCap".toTemplateCategory == TemplateCategory.sapCap);
    assert("sapHana".toTemplateCategory == TemplateCategory.sapHana);
    assert("sapMdk".toTemplateCategory == TemplateCategory.sapMdk);
    assert("sapWorkflow".toTemplateCategory == TemplateCategory.sapWorkflow);
    assert("general".toTemplateCategory == TemplateCategory.general);   

    assert(["sapFiori", "sapCap", "sapHana", "sapMdk", "sapWorkflow", "general"].toTemplateCategories ==
           [TemplateCategory.sapFiori, TemplateCategory.sapCap, TemplateCategory.sapHana, TemplateCategory.sapMdk, TemplateCategory.sapWorkflow, TemplateCategory.general]);
    assert(toString([TemplateCategory.sapFiori, TemplateCategory.sapCap, TemplateCategory.sapHana, TemplateCategory.sapMdk, TemplateCategory.sapWorkflow, TemplateCategory.general]) ==
           ["sapFiori", "sapCap", "sapHana", "sapMdk", "sapWorkflow", "general"]);
}

enum ServiceProviderType {
    // The SAP BTP service provider type includes services that are offered as part of the SAP Business Technology Platform (BTP). These services may include various cloud-based offerings such as databases, analytics, integration, and more, that are designed to help developers build and deploy applications on the SAP BTP.
    sapBtp,
    // The SAP S/4HANA service provider type includes services that are specifically designed for integration with or extension of SAP S/4HANA, which is SAP's next-generation enterprise resource planning (ERP) suite. These services may provide capabilities for accessing and manipulating data within SAP S/4HANA, enabling developers to create applications that enhance the functionality of SAP S/4HANA and meet specific business requirements.
    sapS4Hana,
    // The SAP SuccessFactors service provider type includes services that are specifically designed for integration with or extension of SAP SuccessFactors, which is SAP's cloud-based human capital management (HCM) suite. These services may provide capabilities for accessing and manipulating data within SAP SuccessFactors, enabling developers to create applications that enhance the functionality of SAP SuccessFactors and meet specific HR-related business requirements.
    sapSuccessFactors,
    // The external OData service provider type includes services that are based on the OData protocol and are provided by external vendors or third-party providers. These services may offer specialized capabilities, integrations, or data sources that can be accessed and utilized by applications developed within the application studio environment. The external OData service provider type allows developers to leverage a wide range of OData-based services to enhance their applications and meet specific business needs.
    externalOData,
    // The external REST service provider type includes services that are based
    externalRest
}
ServiceProviderType toServiceProviderType(string value) {
    mixin(EnumSwitch("ServiceProviderType", "sapBtp"));
}
ServiceProviderType[] toServiceProviderTypes(string[] types) {
    return types.map!(toServiceProviderType).array;
}
string toString(ServiceProviderType type) {
    return type.to!string;
}
string[] toStrings(ServiceProviderType[] types) {
    return types.map!(toString).array;
}
///
unittest {
    mixin(ShowTest!("ServiceProviderType"));    

    assert(ServiceProviderType.sapBtp.toString == "sapBtp");
    assert(ServiceProviderType.sapS4Hana.toString == "sapS4Hana");
    assert(ServiceProviderType.sapSuccessFactors.toString == "sapSuccessFactors");
    assert(ServiceProviderType.externalOData.toString == "externalOData");
    assert(ServiceProviderType.externalRest.toString == "externalRest");

    assert("".toServiceProviderType == ServiceProviderType.sapBtp); // Default case
    assert("noexists".toServiceProviderType == ServiceProviderType.sapBtp); // Default case

    assert("sapBtp".toServiceProviderType == ServiceProviderType.sapBtp);
    assert("sapS4Hana".toServiceProviderType == ServiceProviderType.sapS4Hana);
    assert("sapSuccessFactors".toServiceProviderType == ServiceProviderType.sapSuccessFactors);
    assert("externalOData".toServiceProviderType == ServiceProviderType.externalOData);
    assert("externalRest".toServiceProviderType == ServiceProviderType.externalRest);

    assert(["sapBtp", "sapS4Hana", "sapSuccessFactors", "externalOData", "externalRest"].toServiceProviderTypes ==
           [ServiceProviderType.sapBtp, ServiceProviderType.sapS4Hana, ServiceProviderType.sapSuccessFactors, ServiceProviderType.externalOData, ServiceProviderType.externalRest]);
    assert(toString([ServiceProviderType.sapBtp, ServiceProviderType.sapS4Hana, ServiceProviderType.sapSuccessFactors, ServiceProviderType.externalOData, ServiceProviderType.externalRest]) ==
           ["sapBtp", "sapS4Hana", "sapSuccessFactors", "externalOData", "externalRest"]);
}

enum BindingStatus {
    // The connected binding status indicates that the binding is currently active and functioning correctly.
    connected,
    // The disconnected binding status indicates that the binding is currently inactive or not functioning correctly.
    disconnected,
    // The error binding status indicates that there is an issue with the binding, preventing it from functioning correctly.
    error
}
BindingStatus toBindingStatus(string value) {
    mixin(EnumSwitch("BindingStatus", "disconnected"));
}
BindingStatus[] toBindingStatuses(string[] statuses) {
    return statuses.map!(toBindingStatus).array;
}
string toString(BindingStatus status) {
    return status.to!string;
}
string[] toStrings(BindingStatus[] statuses) {
    return statuses.map!(toString).array;
}
///
unittest {
    mixin(ShowTest!("BindingStatus"));

    assert(BindingStatus.connected.toString == "connected");
    assert(BindingStatus.disconnected.toString == "disconnected");
    assert(BindingStatus.error.toString == "error");

    assert("".toBindingStatus == BindingStatus.disconnected); // Default case
    assert("noexists".toBindingStatus == BindingStatus.disconnected); // Default case

    assert("connected".toBindingStatus == BindingStatus.connected);
    assert("disconnected".toBindingStatus == BindingStatus.disconnected);
    assert("error".toBindingStatus == BindingStatus.error);

    assert(["connected", "disconnected", "error"].toBindingStatuses ==
           [BindingStatus.connected, BindingStatus.disconnected, BindingStatus.error]);
    assert(toString([BindingStatus.connected, BindingStatus.disconnected, BindingStatus.error]) ==
           ["connected", "disconnected", "error"]);
}

enum RunMode : string {
    // The run mode indicates that the application is running in normal mode.
    run = "run",
    // The debug mode indicates that the application is running in debug mode, allowing for debugging and troubleshooting.
    debug_ = "debug",
    // The test mode indicates that the application is running in test mode, typically used for testing purposes.
    test = "test",
    // The preview mode indicates that the application is running in preview mode, allowing for a preview of the application's behavior.
    preview = "preview"
}
RunMode toRunMode(string s) {
    switch(s.toLower) {
        case "run": return RunMode.run;
        case "debug": return RunMode.debug_;
        case "test": return RunMode.test;
        case "preview": return RunMode.preview;
        default: return RunMode.run; // Default case
    }
}
RunMode[] toRunModes(string[] modes) {
    return modes.map!(toRunMode).array;
}
string toString(RunMode mode) {
    return cast(string)mode;
}
string[] toStrings(RunMode[] modes) {
    return modes.map!(toString).array;
}
/// 
unittest {
    mixin(ShowTest!("RunMode"));

    assert(RunMode.run.toString == "run");
    assert(RunMode.debug_.toString == "debug");
    assert(RunMode.test.toString == "test");
    assert(RunMode.preview.toString == "preview");

    assert("".toRunMode == RunMode.run); // Default case
    assert("noexists".toRunMode == RunMode.run); // Default case

    assert("run".toRunMode == RunMode.run);
    assert("debug".toRunMode == RunMode.debug_);
    assert("test".toRunMode == RunMode.test);
    assert("preview".toRunMode == RunMode.preview);

    assert(["run", "debug", "test", "preview"].toRunModes ==
           [RunMode.run, RunMode.debug_, RunMode.test, RunMode.preview]);
    assert(toString([RunMode.run, RunMode.debug_, RunMode.test, RunMode.preview]) ==
           ["run", "debug", "test", "preview"]);
    
}

enum RunStatus {
    // The idle status indicates that the application is currently idle and not running.
    idle,
    // The running status indicates that the application is currently running and operational.
    running,
    // The stopped status indicates that the application has been stopped and is no longer running.
    stopped,
    // The error status indicates that the application has encountered an error that prevents it from running properly.
    error
}
RunStatus toRunStatus(string value) {
    mixin(EnumSwitch("RunStatus", "idle"));
}
RunStatus[] toRunStatuses(string[] statuses) {
    return statuses.map!(toRunStatus).array;
}
string toString(RunStatus status) {
    return status.to!string;
}
string[] toStrings(RunStatus[] statuses) {
    return statuses.map!(toString).array;
}
///
unittest {
    mixin(ShowTest!("RunStatus"));

    assert(RunStatus.idle.toString == "idle");
    assert(RunStatus.running.toString == "running");
    assert(RunStatus.stopped.toString == "stopped");
    assert(RunStatus.error.toString == "error");

    assert("".toRunStatus == RunStatus.idle); // Default case
    assert("noexists".toRunStatus == RunStatus.idle); // Default case

    assert("idle".toRunStatus == RunStatus.idle);
    assert("running".toRunStatus == RunStatus.running);
    assert("stopped".toRunStatus == RunStatus.stopped);
    assert("error".toRunStatus == RunStatus.error);

    assert(["idle", "running", "stopped", "error"].toRunStatuses ==
           [RunStatus.idle, RunStatus.running, RunStatus.stopped, RunStatus.error]);
    assert(toString([RunStatus.idle, RunStatus.running, RunStatus.stopped, RunStatus.error]) ==
           ["idle", "running", "stopped", "error"]);
}

enum BuildStatus {
    // The pending build status indicates that the build process is waiting to start or is in the initial stages of being queued. In this status, the build has not yet begun, and it may be waiting for resources to become available or for other builds to complete before it can start.
    pending,
    // The building build status indicates that the build process is currently in progress
    building,
    // The succeeded build status indicates that the build process has completed successfully without any errors. In this status, the build has been completed and is considered to be in a healthy and functional state, ready for deployment or further testing.
    succeeded,
    // The failed build status indicates that the build process has encountered an error that prevents it from completing successfully. In this status, the
    failed,
    // The cancelled build status indicates that the build process has been explicitly cancelled by the user
    cancelled
}
BuildStatus toBuildStatus(string value) {
    mixin(EnumSwitch("BuildStatus", "pending"));
}
BuildStatus[] toBuildStatuses(string[] statuses) {
    return statuses.map!(toBuildStatus).array;
}
string toString(BuildStatus status) {
    return status.to!string;
}
string[] toStrings(BuildStatus[] statuses) {
    return statuses.map!(toString).array;
}
///
unittest {
    mixin(ShowTest!("BuildStatus"));

    assert(BuildStatus.pending.toString == "pending");
    assert(BuildStatus.building.toString == "building");
    assert(BuildStatus.succeeded.toString == "succeeded");
    assert(BuildStatus.failed.toString == "failed");
    assert(BuildStatus.cancelled.toString == "cancelled");

    assert("".toBuildStatus == BuildStatus.pending); // Default case
    assert("noexists".toBuildStatus == BuildStatus.pending); // Default case

    assert("pending".toBuildStatus == BuildStatus.pending);
    assert("building".toBuildStatus == BuildStatus.building);
    assert("succeeded".toBuildStatus == BuildStatus.succeeded);
    assert("failed".toBuildStatus == BuildStatus.failed);
    assert("cancelled".toBuildStatus == BuildStatus.cancelled); 

    assert(["pending", "building", "succeeded", "failed", "cancelled"].toBuildStatuses ==
           [BuildStatus.pending, BuildStatus.building, BuildStatus.succeeded, BuildStatus.failed, BuildStatus.cancelled]);
    assert(toString([BuildStatus.pending, BuildStatus.building, BuildStatus.succeeded, BuildStatus.failed, BuildStatus.cancelled]) ==
           ["pending", "building", "succeeded", "failed", "cancelled"]);
}

enum DeployTarget {
    // The Cloud Foundry deploy target indicates that the application is intended to be deployed on the Cloud Foundry platform, which is a popular open-source cloud application platform that provides a range of services and tools for building, deploying, and managing applications in the cloud.
    cloudFoundry,
    // The Kyma deploy target indicates that the application is intended to be deployed on the Kyma platform, which is an open-source project that provides a runtime environment for building and running cloud-native applications on Kubernetes. Kyma offers a set of tools and services for developing, deploying, and managing applications in a Kubernetes-based environment.
    kyma,
    // The ABAP deploy target indicates that the application is intended to be deployed on an ABAP system, which is a programming language and runtime environment used for developing applications in the SAP ecosystem. Deploying to an ABAP system typically involves creating and managing ABAP packages, classes, and other artifacts to run the application within the ABAP environment.
    abap,
    // The HTML5 Repository deploy target indicates that the application is intended to be deployed to an HTML5 repository, which is a storage location for HTML5 applications. This deploy target is commonly used for applications that are designed to run in web browsers and may involve deploying the application files to a web server or cloud storage service that serves HTML5 content.
    html5Repository,
    // The Docker deploy target indicates that the application is intended to be deployed as a Docker container. This deploy target involves packaging the application and its dependencies into a Docker image, which can then be run on any platform that supports Docker. Deploying to Docker allows for greater flexibility and portability, as the application can be easily moved and run in different environments without worrying about compatibility issues.
    docker
}
DeployTarget toDeployTarget(string value) {
    mixin(EnumSwitch("DeployTarget", "cloudFoundry"));
}
DeployTarget[] toDeployTargets(string[] targets) {
    return targets.map!(toDeployTarget).array;
}
string toString(DeployTarget target) {
    return target.to!string;
}
string[] toStrings(DeployTarget[] targets) {
    return targets.map!(toString).array;
}
///
unittest {
    mixin(ShowTest!("DeployTarget"));

    assert(DeployTarget.cloudFoundry.toString == "cloudFoundry");
    assert(DeployTarget.kyma.toString == "kyma");
    assert(DeployTarget.abap.toString == "abap");
    assert(DeployTarget.html5Repository.toString == "html5Repository");
    assert(DeployTarget.docker.toString == "docker");   

    assert("".toDeployTarget == DeployTarget.cloudFoundry); // Default case
    assert("noexists".toDeployTarget == DeployTarget.cloudFoundry); // Default case

    assert("cloudFoundry".toDeployTarget == DeployTarget.cloudFoundry);
    assert("kyma".toDeployTarget == DeployTarget.kyma);
    assert("abap".toDeployTarget == DeployTarget.abap);
    assert("html5Repository".toDeployTarget == DeployTarget.html5Repository);
    assert("docker".toDeployTarget == DeployTarget.docker);

    assert(["cloudFoundry", "kyma", "abap", "html5Repository", "docker"].toDeployTargets ==
           [DeployTarget.cloudFoundry, DeployTarget.kyma, DeployTarget.abap, DeployTarget.html5Repository, DeployTarget.docker]);
    assert(toString([DeployTarget.cloudFoundry, DeployTarget.kyma, DeployTarget.abap, DeployTarget.html5Repository, DeployTarget.docker]) ==
           ["cloudFoundry", "kyma", "abap", "html5Repository", "docker"]);
}
