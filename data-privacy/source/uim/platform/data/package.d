/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy;

public {
    import uim.platform.service;

    import uim.platform.data.privacy.application;
    import uim.platform.data.privacy.domain;
    import uim.platform.data.privacy.helpers;
    import uim.platform.data.privacy.infrastructure;
    import uim.platform.data.privacy.presentation;
}

public {
    import uim.platform.data.privacy.presentation.http.controllers.anonymization_config;
    import uim.platform.data.privacy.presentation.http.controllers.archive_request;
    import uim.platform.data.privacy.presentation.http.controllers.blocking_request;
    import uim.platform.data.privacy.presentation.http.controllers.business_context;
    import uim.platform.data.privacy.presentation.http.controllers.business_process;
    import uim.platform.data.privacy.presentation.http.controllers.business_subprocess;
    import uim.platform.data.privacy.presentation.http.controllers.consent_purpose;
    import uim.platform.data.privacy.presentation.http.controllers.consent_record;
    import uim.platform.data.privacy.presentation.http.controllers.correction_request;
    import uim.platform.data.privacy.presentation.http.controllers.data_controller;
    import uim.platform.data.privacy.presentation.http.controllers.data_controller_group;
    import uim.platform.data.privacy.presentation.http.controllers.data_retrieval_request;
    import uim.platform.data.privacy.presentation.http.controllers.data_subject;
    import uim.platform.data.privacy.presentation.http.controllers.deletion;
    import uim.platform.data.privacy.presentation.http.controllers.destruction_request;
    import uim.platform.data.privacy.presentation.http.controllers.information_report;
    import uim.platform.data.privacy.presentation.http.controllers.legal_ground;
    import uim.platform.data.privacy.presentation.http.controllers.personal_data_model;
    import uim.platform.data.privacy.presentation.http.controllers.purpose_record;
    import uim.platform.data.privacy.presentation.http.controllers.retention_rule;
    import uim.platform.data.privacy.presentation.http.controllers.rule_set;
    }