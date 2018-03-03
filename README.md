# ansible-samba

Installs samba-server as docker container.

## System requirements

* Docker
* Systemd

## Role requirements

* python-docker package

## What does this role

* Build docker image locally
* Create volume paths for docker container
* Template the samba config
* Setup systemd unit file
* Start/Restart service

## Role parameters

### Main config

| Variable      | Type | Mandatory? | Default | Description           |
|---------------|------|------------|---------|-----------------------|
| samba_package_version | text | no | 4.7.4-r0 | The current samba package version, look at: [alpine samba package](https://pkgs.alpinelinux.org/packages?name=samba&branch=v3.7) |
| image_name            | text | no | local/samba-server | Docker image name                                                                                                      |
| image_version         | text | no | same of samba_package_version | Docker image version                                                                                        |
| container_name        | text | no | samba.service                 | The name of the docker container                                                                            |
| interface             | ip address | no | 0.0.0.0                 | Mapped network for web-interface ports                                                                      |
| port                  | port       | no | <empty>                 | Default port (TCP): 445                                                                                     |
| config_volume         | path       | no | <empty>                 | Path to config volume                                                                                       |
| log_volume            | path       | no | <empty>                 | Path to log volume                                                                                          |
| workgroup             | text       | no | WORKGROUP               | The default Samba workgroup                                                                                 |
| server_string         | text       | no | "%h server (Samba, Alpine)" | The default Samba server string                                                                         |
| storages              | array of objects | no | <empty array>         | The samba storage configuration                                                                         |

### mainconfig.storage

The site storages is a list of storage objects:

| Property      | Type | Mandatory? | Description           |
|---------------|------|------------|-----------------------|
| name          | text | no         | The name of the storage |
| path          | path | no         | The internal path of the storage (within docker-container) |
| host_path     | path | no         | The external path of the storage (on the host system)      |
| comment       | text | no         | The comment of the storage                                 |
| browseable    | boolean | no      | Is the storage browseable?                                 |
| writable      | boolean | no      | Is the storage writable?                                   |
| guest_access  | boolean | no      | Do guests have access?                                     |
| write_list    | list of text | no | Names of accounts with write permission                    |

## Example Playbook

Usage (without parameters):

    - hosts: servers
      roles:
         - { role: install-samba }

Usage (with parameters):

    - hosts: servers
      roles:
      - role: install-samba
        port: 445
        config_volume: /srv/docker/samba
        log_volume: /var/log/samba
        storages:
        - name: Share
          path: /share
          host_path: /srv/docker/samba/share
          comment: Share storage
          browseable: true
          writable: true
          guest_access: true
          write_list:
          - flandi
