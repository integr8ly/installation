from ansible.module_utils.basic import AnsibleModule

import json


def build():
    return AnsibleModule(
        argument_spec=dict(
            data=dict(required=True, type='list'),
            skip_images=dict(default=['docker-registry.default.svc', '/openshift3/'], type='list')
        ),
        supports_check_mode=True,
    )


def get_items(module):
    items = module.params['data']
    if isinstance(items, str):
        items = json.loads(items)
    return items


def should_skip(module, name):
    return len([i for i in module.params['skip_images'] if i in name]) > 0


def get_image_data(data):
    image_params = data['imageChangeParams']
    image_from = image_params['from']
    image_name = image_from['name']
    try:
        image_name = image_name.split(':')[0]
    except IndexError:
        return {}

    return {
        'image': image_name,
        'namespace': image_from['namespace']
    }


def main():
    module = build()
    
    items = get_items(module)
    images = []
    has_changed = False

    for item in items:
        spec = item['spec']
        if not 'triggers' in spec:
            continue
        triggers = spec['triggers']
        for trigger in triggers:
            if trigger['type'] == 'ImageChange': 
                if not 'imageChangeParams' in trigger:
                    continue
                if not 'lastTriggeredImage' in trigger['imageChangeParams']:
                    continue
                if should_skip(module, trigger['imageChangeParams']['lastTriggeredImage']):
                    continue
                image_data = get_image_data(trigger)
                if len(image_data) == 0:
                    continue
                has_changed = True
                images.append(image_data)
    module.exit_json(changed=has_changed, images=images)


if __name__ == '__main__':
    main()