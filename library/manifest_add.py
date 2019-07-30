from ansible.module_utils.basic import AnsibleModule

import json


def build():
    return AnsibleModule(
        argument_spec=dict(
            manifest=dict(required=True, type='dict'),
            items=dict(required=True, type='list')
        ),
        supports_check_mode=True,
    )


def has_item(components, name):
    return len([item for item in components if item['name'] == name]) == 1


def main():
    module = build()
    
    manifest = module.params['manifest']
    items = module.params['items']
    has_changed = False

    for item in items:
        if not has_item(manifest['components'], item['name']):
            manifest['components'].append(item)
            has_changed = True
    module.exit_json(changed=has_changed, manifest=manifest)


if __name__ == '__main__':
    main()