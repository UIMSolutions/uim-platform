#!/usr/bin/env python3
"""
Generate unittest blocks for all repository and usecase D source files
that don't already have them.
"""

import re
import os
import sys

BASE = "/home/oz/DEV/D/UIM2026/CLOUD/uim-platform"

# Subpackages from dub.sdl
SUBPACKAGES = [
    "service", "abap-compiler", "abap-environment", "advanced-events",
    "agentry", "ai-core", "authorization-trust", "build-apps",
    "application-vulnerability", "automation-pilot", "auditlog",
    "cloud-foundry", "credential-store", "custom-domain",
    "data-attribute-recommendation", "databricks", "destination",
    "dms-application", "dms-integration", "events", "feature-flags",
    "identity-authentication", "identity-directory", "identity-provisioning",
    "job-scheduling", "keystore", "logging", "management",
    "masterdata-integration", "monitoring", "oauth", "private-link",
    "service-manager",
]


def find_d_files(directory, path_pattern):
    """Find .d files matching path_pattern recursively."""
    results = []
    if not os.path.isdir(directory):
        return results
    for root, dirs, files in os.walk(directory):
        for f in files:
            if f.endswith(".d") and f != "package.d":
                full = os.path.join(root, f)
                if path_pattern in full:
                    results.append(full)
    return results


def extract_class_name(content, pattern=r'class\s+(\w+)'):
    """Extract the first class name from content."""
    m = re.search(pattern, content)
    return m.group(1) if m else None


def extract_memory_repo_class(content):
    """Extract Memory*Repository class name from infrastructure repo file."""
    m = re.search(r'class\s+(Memory\w+Repository)', content)
    return m.group(1) if m else None


def extract_usecase_class(content):
    """Extract the usecase class name."""
    m = re.search(r'^class\s+(\w+UseCase)', content, re.MULTILINE)
    return m.group(1) if m else None


def extract_constructor_repo_type(content):
    """Extract the repo type from the constructor 'this(IXxxRepository repo)'."""
    m = re.search(r'this\(\s*(\w+)\s+repo\s*\)', content)
    return m.group(1) if m else None


def extract_constructor_repo_type2(content):
    """Extract the repo type from 'this(XxxRepository repository)'."""
    m = re.search(r'this\(\s*(\w+)\s+repository\s*\)', content)
    return m.group(1) if m else None


def extract_list_method(content):
    """Extract list method info: return type, method name."""
    m = re.search(r'(\w+)\[\]\s+(list\w+)\s*\(TenantId\s+\w+\)', content)
    if m:
        return m.group(1), m.group(2)
    return None, None


def extract_get_method(content):
    """Extract get method: return type, method name, id type."""
    m = re.search(r'(\w+)\s+(get\w+)\s*\(TenantId\s+\w+,\s*(\w+)\s+\w+\)', content)
    if m:
        return m.group(1), m.group(2), m.group(3)
    return None, None, None


def extract_create_method(content):
    """Extract create method: method name, dto type."""
    m = re.search(r'CommandResult\s+(create\w+)\s*\((\w+)\s+dto\)', content)
    if m:
        return m.group(1), m.group(2)
    return None, None


def extract_update_method(content):
    """Extract update method: method name, dto type."""
    m = re.search(r'CommandResult\s+(update\w+)\s*\((\w+)\s+dto\)', content)
    if m:
        return m.group(1), m.group(2)
    return None, None


def extract_delete_method(content):
    """Extract delete method: method name, id type."""
    m = re.search(r'CommandResult\s+(delete\w+)\s*\(TenantId\s+\w+,\s*(\w+)\s+\w+\)', content)
    if m:
        return m.group(1), m.group(2)
    return None, None


def find_memory_class_for_interface(iface_type, pkg_dir):
    """Given 'IPlatformRepository', find 'MemoryPlatformRepository' in pkg infra dir."""
    infra_dir = os.path.join(pkg_dir, "infrastructure", "persistence", "repositories")
    if not os.path.isdir(infra_dir):
        return None
    
    for root, dirs, files in os.walk(infra_dir):
        for f in files:
            if f.endswith(".d") and f != "package.d":
                fpath = os.path.join(root, f)
                try:
                    c = open(fpath).read()
                except:
                    continue
                # Look for class Memory...Repository that implements the interface
                m = re.search(r'class\s+(Memory\w+Repository)[^{]*:\s*[^{]*' + re.escape(iface_type), c)
                if m:
                    return m.group(1)
                # Also look for any Memory class
                m2 = re.search(r'class\s+(Memory\w+Repository)', c)
                if m2:
                    # Check if IFace is mentioned in the file
                    if iface_type in c:
                        return m2.group(1)
    return None


def find_memory_class_for_repo_type(repo_type, pkg_dir):
    """Find Memory implementation - handles both I-prefixed and direct names."""
    # First try direct lookup
    result = find_memory_class_for_interface(repo_type, pkg_dir)
    if result:
        return result
    
    # If it's a plain class name like AlertRepository (not IAlertRepository)
    # Try to find Memory{Something}Repository in infra dir
    infra_dir = os.path.join(pkg_dir, "infrastructure", "persistence", "repositories")
    if not os.path.isdir(infra_dir):
        return None
    
    for root, dirs, files in os.walk(infra_dir):
        for f in files:
            if f.endswith(".d") and f != "package.d":
                fpath = os.path.join(root, f)
                try:
                    c = open(fpath).read()
                except:
                    continue
                if repo_type in c:
                    m = re.search(r'class\s+(Memory\w+Repository)', c)
                    if m:
                        return m.group(1)
    return None


def get_dto_id_field(dto_type, pkg_source_dir):
    """Find the ID field in a DTO struct."""
    # Look for the DTO in dto.d or application/**
    for root, dirs, files in os.walk(pkg_source_dir):
        for f in files:
            if f.endswith(".d"):
                fpath = os.path.join(root, f)
                try:
                    c = open(fpath).read()
                except:
                    continue
                # Find struct XxxDTO { ... }
                pattern = r'struct\s+' + re.escape(dto_type) + r'\s*\{([^}]+)\}'
                m = re.search(pattern, c, re.DOTALL)
                if m:
                    body = m.group(1)
                    # Look for *Id field
                    id_m = re.search(r'(\w+Id)\s+(\w+Id)\s*;', body)
                    if id_m:
                        return id_m.group(2), id_m.group(1)
    return None, None


def generate_infra_repo_test(class_name):
    """Generate simple unittest for a MemoryXxxRepository."""
    return f"""
///
unittest {{
    assert(tenantRepositoryTest(new {class_name}()));
}}"""


def camel_to_var(name):
    """Convert ClassName to variableName."""
    if not name:
        return "entity"
    return name[0].lower() + name[1:]


def generate_usecase_test(info):
    """Generate a comprehensive CRUD unittest for a usecase."""
    class_name = info['class_name']
    memory_repo = info['memory_repo']
    repo_type = info['repo_type']
    entity_type = info['entity_type']
    id_type = info['id_type']
    list_method = info['list_method']
    get_method = info['get_method']
    create_method = info['create_method']
    create_dto = info['create_dto']
    update_method = info['update_method']
    update_dto = info['update_dto']
    delete_method = info['delete_method']

    if not memory_repo and not repo_type:
        return None

    repo_class = memory_repo or repo_type
    entity_var = camel_to_var(entity_type) if entity_type else "entity"
    
    lines = ["", "///", "unittest {"]
    lines.append(f"    auto repo = new {repo_class}();")
    lines.append(f"    auto usecase = new {class_name}(repo);")
    lines.append(f'    auto tenantId = TenantId("test-tenant");')
    lines.append("")

    has_create = create_method and create_dto
    has_list = list_method and entity_type
    has_get = get_method and id_type and entity_type
    has_update = update_method and update_dto
    has_delete = delete_method and id_type

    if has_create:
        id_val = camel_to_var(entity_type) + "-1" if entity_type else "entity-1"
        lines.append(f"    // Test create")
        lines.append(f"    {create_dto} createDto;")
        lines.append(f"    createDto.tenantId = tenantId;")
        # Try to set an ID field
        if id_type:
            id_field = camel_to_var(id_type)
            lines.append(f'    createDto.{id_field} = {id_type}("{id_val}");')
        lines.append(f'    createDto.name = "Test {entity_type or "Entity"}";')
        lines.append(f"    auto createResult = usecase.{create_method}(createDto);")
        lines.append(f"    assert(createResult.success, createResult.message);")
        lines.append("")

    if has_list:
        lines.append(f"    // Test list")
        lines.append(f"    auto items = usecase.{list_method}(tenantId);")
        if has_create:
            lines.append(f"    assert(items.length == 1);")
        else:
            lines.append(f"    assert(items !is null);")
        lines.append("")

    if has_get and has_create and id_type:
        id_val = camel_to_var(entity_type) + "-1" if entity_type else "entity-1"
        lines.append(f"    // Test get")
        lines.append(f'    auto item = usecase.{get_method}(tenantId, {id_type}("{id_val}"));')
        lines.append(f"    assert(!item.isNull);")
        lines.append("")

    if has_update and has_create and id_type:
        id_val = camel_to_var(entity_type) + "-1" if entity_type else "entity-1"
        lines.append(f"    // Test update")
        lines.append(f"    {update_dto} updateDto;")
        lines.append(f"    updateDto.tenantId = tenantId;")
        # Try to find the ID field in update DTO
        id_field = camel_to_var(id_type)
        lines.append(f'    updateDto.{id_field} = {id_type}("{id_val}");')
        lines.append(f'    updateDto.name = "Updated {entity_type or "Entity"}";')
        lines.append(f"    auto updateResult = usecase.{update_method}(updateDto);")
        lines.append(f"    assert(updateResult.success, updateResult.message);")
        lines.append("")

    if has_delete and has_create and id_type:
        id_val = camel_to_var(entity_type) + "-1" if entity_type else "entity-1"
        lines.append(f"    // Test delete")
        lines.append(f'    auto deleteResult = usecase.{delete_method}(tenantId, {id_type}("{id_val}"));')
        lines.append(f"    assert(deleteResult.success, deleteResult.message);")
        if has_list:
            lines.append(f"    assert(usecase.{list_method}(tenantId).length == 0);")
        lines.append("")

    # If we have very few assertions, at least add a basic one
    has_any_test = has_create or has_list or has_get or has_update or has_delete
    if not has_any_test:
        lines.append(f"    assert(usecase !is null);")

    lines.append("}")
    return "\n".join(lines)


def find_source_dir(pkg):
    """Find the source directory for a package."""
    pkg_dir = os.path.join(BASE, pkg)
    src_dir = os.path.join(pkg_dir, "source")
    if os.path.isdir(src_dir):
        return src_dir
    return pkg_dir


def process_infra_repo(filepath):
    """Add unittest to infra repo file if missing."""
    try:
        content = open(filepath).read()
    except:
        return False

    if "unittest" in content:
        return False  # Already has test

    memory_class = extract_memory_repo_class(content)
    if not memory_class:
        return False

    test_code = generate_infra_repo_test(memory_class)
    
    # Append to end of file
    new_content = content.rstrip() + "\n" + test_code + "\n"
    with open(filepath, 'w') as f:
        f.write(new_content)
    print(f"  [REPO] Added test to {os.path.basename(filepath)}")
    return True


def process_usecase(filepath, pkg_dir, pkg_source_dir):
    """Add unittest to usecase file if missing."""
    try:
        content = open(filepath).read()
    except:
        return False

    if "unittest" in content:
        return False  # Already has test

    class_name = extract_usecase_class(content)
    if not class_name:
        return False

    # Get repo type
    repo_type = extract_constructor_repo_type(content)
    if not repo_type:
        repo_type = extract_constructor_repo_type2(content)

    # Find memory repo
    memory_repo = None
    if repo_type:
        memory_repo = find_memory_class_for_repo_type(repo_type, pkg_dir)

    # Extract method info
    entity_type, list_method = extract_list_method(content)
    _, get_method, id_type = extract_get_method(content)
    create_method, create_dto = extract_create_method(content)
    update_method, update_dto = extract_update_method(content)
    delete_method, del_id_type = extract_delete_method(content)
    
    if id_type is None and del_id_type:
        id_type = del_id_type

    info = {
        'class_name': class_name,
        'memory_repo': memory_repo,
        'repo_type': repo_type,
        'entity_type': entity_type,
        'id_type': id_type,
        'list_method': list_method,
        'get_method': get_method,
        'create_method': create_method,
        'create_dto': create_dto,
        'update_method': update_method,
        'update_dto': update_dto,
        'delete_method': delete_method,
    }

    test_code = generate_usecase_test(info)
    if not test_code:
        return False

    # Append to end of file
    new_content = content.rstrip() + "\n" + test_code + "\n"
    with open(filepath, 'w') as f:
        f.write(new_content)
    print(f"  [USECASE] Added test to {os.path.basename(filepath)}")
    return True


def main():
    total_added = 0
    
    for pkg in SUBPACKAGES:
        pkg_dir = os.path.join(BASE, pkg)
        src_dir = find_source_dir(pkg)
        
        if not os.path.isdir(src_dir):
            print(f"  Skipping {pkg}: source dir not found")
            continue
        
        print(f"\n=== Processing {pkg} ===")
        
        # Process infra repos
        infra_repo_files = find_d_files(src_dir, "/persistence/repositories/")
        for f in sorted(infra_repo_files):
            if process_infra_repo(f):
                total_added += 1
        
        # Process usecases
        usecase_files = find_d_files(src_dir, "/usecases/")
        for f in sorted(usecase_files):
            if process_usecase(f, pkg_dir, src_dir):
                total_added += 1
    
    print(f"\nTotal unittest blocks added: {total_added}")


if __name__ == "__main__":
    main()
