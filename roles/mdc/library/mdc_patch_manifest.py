from ansible.module_utils.basic import AnsibleModule

import json


def build():
    return AnsibleModule(
        argument_spec=dict(
            env_var=dict(required=True, type='str'),
            path=dict(required=True, type='str'),
            secret_name=dict(required=True, type='str'),
            secret_key=dict(default='generated_manifest', type='str'),
            dc=dict(required=True, type='dict'),
        ),
        supports_check_mode=True,
    )


def parse(data):
    if isinstance(data, str):
        return json.loads(data)
    return data


def coll_has_key(coll, key, value):
    for item in coll:
        if item.get(key) == value:
            return True
    return False


def main():
    has_changed = False
    module = build()
    path_parts = module.params['path'].split('/')
    folder = '/'.join(path_parts[:-1])
    fname = path_parts[-1]

    dc = parse(module.params['dc'])
    for container in dc['spec']['template']['spec']['containers']:
        if container['name'] == 'mdc':
            if not 'env' in container:
                container['env'] = []
            if not coll_has_key(container['env'], 'name', module.params['env_var']):
                container['env'].append({
                    'name': module.params['env_var'],
                    'value': module.params['path']
                })
                has_changed = True
            if not 'volumeMounts' in container:
                container['volumeMounts'] = []
            if not coll_has_key(container['volumeMounts'], 'name', module.params['secret_name']):
                container['volumeMounts'].append({
                    'name': module.params['secret_name'],
                    'mountPath':folder,
                    'readOnly': True,
                })
                has_changed = True
    if not 'volumes' in dc['spec']['template']['spec']:
        dc['spec']['template']['spec']['volumes'] = []
    if not coll_has_key(dc['spec']['template']['spec']['volumes'], 'name', module.params['secret_name']):
        dc['spec']['template']['spec']['volumes'].append({
            'name': module.params['secret_name'],
            'secret': {
                'secretName': module.params['secret_name'],
                'items': [
                    {
                        'key': module.params['secret_key'],
                        'path': fname,
                    }
                ]
            }
        })
        has_changed = True

    module.exit_json(changed=has_changed, data=dc)


if __name__ == '__main__':
    main()