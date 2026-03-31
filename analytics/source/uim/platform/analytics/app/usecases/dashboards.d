module uim.platform.analytics.app.usecases.dashboards;

// import uim.platform.analytics.domain.entities.dashboard;
// import uim.platform.analytics.domain.repositories.dashboard;
// import uim.platform.analytics.domain.values.common;
// import uim.platform.analytics.app.dto.dashboard;
import uim.platform.analytics;

mixin(ShowModule!());
@safe:
/// Application service: dashboard use cases.
class DashboardUseCases {
    private DashboardRepository repo;

    this(DashboardRepository repo) {
        this.repo = repo;
    }

    DashboardResponse create(CreateDashboardRequest req) {
        auto dashboard = Dashboard.create(req.name, req.description, req.ownerId);
        repo.save(dashboard);
        return DashboardResponse.fromEntity(dashboard);
    }

    DashboardResponse getById(string id) {
        auto d = repo.findById(EntityId(id));
        return DashboardResponse.fromEntity(d);
    }

    DashboardResponse[] list() {
        DashboardResponse[] result;
        foreach (d; repo.findAll())
            result ~= DashboardResponse.fromEntity(d);
        return result;
    }

    DashboardResponse addPage(string dashboardId, string title) {
        auto d = repo.findById(EntityId(dashboardId));
        if (d is null)
            return DashboardResponse.init;
        d.addPage(title);
        repo.save(d);
        return DashboardResponse.fromEntity(d);
    }

    DashboardResponse publish(string dashboardId) {
        auto d = repo.findById(EntityId(dashboardId));
        if (d is null)
            return DashboardResponse.init;
        d.publish();
        repo.save(d);
        return DashboardResponse.fromEntity(d);
    }

    void remove(string id) {
        repo.remove(EntityId(id));
    }
}
