from ansible.module_utils.basic import AnsibleModule


def build():
    return AnsibleModule(
        argument_spec=dict(
            data=dict(required=True, type='list')
        ),
        supports_check_mode=True)


def main():
    module = build()

    streams = module.params['data']
    if isinstance(streams, str):
        streams = json.loads(streams)

    output = []
    has_changed = False

    for stream in streams:
        idx = 0
        tags = stream['spec'].get('tags', [])
        for tag in tags:
            if tag['name'] == 'latest':
                output.append({
                    'idx': idx,
                    'name': stream['metadata']['name']
                })
            idx += 1

    if len(output) > 0:
        has_changed = True

    module.exit_json(changed=has_changed, images=output)


if __name__ == '__main__':
    main()
