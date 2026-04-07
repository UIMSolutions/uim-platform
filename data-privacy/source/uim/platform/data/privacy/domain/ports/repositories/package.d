/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*) 
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file. 
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.data.privacy.presentation.repositories;

public {
    import uim.platform.data.privacy.domain.ports.repositories.anonymization_configs;
    import uim.platform.data.privacy.domain.ports.repositories.archive_requests;
    import uim.platform.data.privacy.domain.ports.repositories.blocking_requests;
    import uim.platform.data.privacy.domain.ports.repositories.business_contexts;
    import uim.platform.data.privacy.domain.ports.repositories.business_processes;
    import uim.platform.data.privacy.domain.ports.repositories.business_subprocesses;
    import uim.platform.data.privacy.domain.ports.repositories.consent_purposes;
    import uim.platform.data.privacy.domain.ports.repositories.consent_records;
    import uim.platform.data.privacy.domain.ports.repositories.correction_requests;
    import uim.platform.data.privacy.domain.ports.repositories.data_controller_groups;
    import uim.platform.data.privacy.domain.ports.repositories.data_controllers;
    import uim.platform.data.privacy.domain.ports.repositories.data_retrieval_requests;
    import uim.platform.data.privacy.domain.ports.repositories.data_subjects;
    import uim.platform.data.privacy.domain.ports.repositories.deletion_requests;
    import uim.platform.data.privacy.domain.ports.repositories.destruction_requests;
    import uim.platform.data.privacy.domain.ports.repositories.information_reports;
    import uim.platform.data.privacy.domain.ports.repositories.legal_grounds;
    import uim.platform.data.privacy.domain.ports.repositories.personal_data_models;
    import uim.platform.data.privacy.domain.ports.repositories.purpose_records;
    import uim.platform.data.privacy.domain.ports.repositories.retention_rules;
    import uim.platform.data.privacy.domain.ports.repositories.rule_sets;
}