/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.event_mesh.presentation.unix_connect.mvc;

import std.array : appender;
import std.format : format;

import uim.platform.event_mesh;

mixin(ShowModule!());

@safe:

final class UnixConnectBrokerServiceModel {
    private ManageBrokerServicesUseCase usecase;

    this(ManageBrokerServicesUseCase usecase) {
        this.usecase = usecase;
    }

    BrokerService[] listServices(string tenantId) {
        return usecase.listServices(TenantId(tenantId));
    }
}

final class UnixConnectBrokerServiceView {
    string renderList(BrokerService[] services) const {
        auto output = appender!string();

        foreach (service; services) {
            output.put(format("BROKER_SERVICE|%s|%s|%s\n", service.id.value, service.name, service.region));
        }

        return output.data;
    }
}

final class UnixConnectBrokerServiceController {
    private UnixConnectBrokerServiceModel model;
    private UnixConnectBrokerServiceView view;

    this(UnixConnectBrokerServiceModel model, UnixConnectBrokerServiceView view) {
        this.model = model;
        this.view = view;
    }

    string list(string tenantId) {
        auto services = model.listServices(tenantId);
        return view.renderList(services);
    }
}
