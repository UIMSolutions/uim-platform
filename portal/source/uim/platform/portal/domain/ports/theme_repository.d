module uim.platform.xyz.domain.ports.theme_repository;

import domain.entities.theme;
import domain.types;

/// Port: outgoing — theme persistence.
interface ThemeRepository
{
    Theme findById(ThemeId id);
    Theme findDefault(TenantId tenantId);
    Theme[] findByTenant(TenantId tenantId, uint offset = 0, uint limit = 100);
    void save(Theme theme);
    void update(Theme theme);
    void remove(ThemeId id);
}
