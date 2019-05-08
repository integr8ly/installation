from ansible.module_utils.basic import AnsibleModule

import json

try:
    import jsonpointer
except ImportError:
    jsonpointer = None


def main():
    module = AnsibleModule(
        argument_spec=dict(
            pods=dict(required=True, type='list'),
        ),
        supports_check_mode=True,
    )

    pods = module.params['data']
    if isinstance(pods, str):
        pods = json.loads(str)
    images = []

    for pod in pods:
        containers = pod['spec']['containers']
        for container in containers:
            images.append(container['image'])

    module.exit_json(changed=True, result=images)


if __name__ == '__main__':
    main()