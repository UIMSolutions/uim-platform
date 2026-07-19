/****************************************************************************************************************
* Copyright: (c) 2018-2026 Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Suel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
module uim.platform.event_mesh.presentation.grpc.mvc;

import uim.platform.event_mesh;

mixin(ShowModule!());

@safe:

final class RpcBrokerServiceModel {
    private ManageBrokerServicesUseCase usecase;

    this(ManageBrokerServicesUseCase usecase) {
        this.usecase = usecase;
    }

    BrokerService[] listServices(string tenantId) {
        return usecase.listServices(TenantId(tenantId));
    }
}

final class RpcBrokerServiceView {
    Json renderListResponse(BrokerService[] services, string requestId) const {
        Json[] resources;
        resources.reserve(services.length);

        foreach (service; services) {
            resources ~= service.toJson;
        }

        return Json.emptyObject
            .set("jsonrpc", "2.0")
            .set("id", requestId)
            .set("result", Json.emptyObject
                .set("count", services.length)
                .set("resources", resources.toJson));
    }
}

final class RpcBrokerServiceController {
    private RpcBrokerServiceModel model;
    private RpcBrokerServiceView view;

    this(RpcBrokerServiceModel model, RpcBrokerServiceView view) {
        this.model = model;
        this.view = view;
    }

    Json list(string tenantId, string requestId = "1") {
        auto services = model.listServices(tenantId);
        return view.renderListResponse(services, requestId);
    }
}
