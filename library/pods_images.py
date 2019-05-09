from ansible.module_utils.basic import AnsibleModule

import json


def main():
    module = AnsibleModule(
        argument_spec=dict(
            data=dict(required=True, type='list'),
            skip_os3=dict(type='bool', default=True),
            skip_internal=dict(type='bool', default=True)
        ),
        supports_check_mode=True,
    )

    skip_os3 = module.params['skip_os3']
    skip_internal = module.params['skip_internal']
    pods = module.params['data']
    if isinstance(pods, str):
        pods = json.loads(pods)
    images = []

    for pod in pods:
        containers = pod['spec']['containers']
        for container in containers:
            if 'docker-registry.default.svc' in container['image'] or '/openshift3/' in container['image']:
                continue
            parts = container['image'].split(':')
            images.append({
                'image': parts[0].replace('@sha256', ''),
                'tag': parts[1]
            })

    module.exit_json(changed=True, images=images)


if __name__ == '__main__':
    main()