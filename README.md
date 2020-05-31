# ansible-samba

Installs samba-server as docker container.

## System requirements

* Docker
* Systemd

## Role requirements

* python-docker package

## What does this role

* Build docker image
* Create volume paths for docker container
* Template the samba config
* Setup systemd unit file
* Start/Restart service
* Add samba users

## Role parameters

### Main config

| Variable      | Type | Mandatory? | Default | Description           |
|---------------|------|------------|---------|-----------------------|
| samba_alpine_version        | text | no | latest | Your selected alpine version |
| samba_version         | text | no | latest | Your selected samba version  |
| samba_image_name            | text | no | local/samba-server | Docker image name                                 |
| samba_container_name        | text | no | samba.service                 | The name of the docker container       |
| samba_interface             | ip address | no | 0.0.0.0                 | Mapped network for web-interface ports |
| samba_port            | port       | no | <empty>                 | Default port (TCP): 445                |
| samba_enable_netbios        | boolean    | no | no                      | Enables NetBios option and publish ports 137, 138 and 138 |
| samba_netbios_name          | text       | no | <empty>                 | Configures the NetBios name                               |
| samba_volumes_path          | path       | yes | <empty>                 | Directory where the persistent data will be stored       |
| samba_config_volume         | path       | no  | <samba_volumes_path>/config   | Directory where the config data will be stored           |
| samba_data_volume           | path       | no  | <samba_volumes_path>/data     | Directory where the server data will be stored           |
| samba_storages_volume       | path       | no  | <samba_volumes_path>/storages | Directory where the storages are located                 |
| samba_homes_volume          | path       | no  | <samba_volumes_path>/homes    | Directory where the homes are located                    |
| samba_workgroup             | text       | no  | WORKGROUP               | The default Samba workgroup            |
| samba_server_string         | text       | no  | "%h server (Samba, Alpine)" | The default Samba server string    |
| samba_enable_homes          | boolean    | no  | no                          | Enables home directories for users |
| samba_unix_extensions             | boolean    | no  | <empty>                     | Enable or disable UNIX extensions  |
| samba_storages              | array of storage | no | <empty array>          | The samba storage configuration    |
| samba_users                 | array of user    | no | <empty array>          | The samba user configuration       |

### Definition storage

| Property      | Type | Mandatory? | Description           |
|---------------|------|------------|-----------------------|
| name          | text | no         | The name of the storage |
| path          | path | yes        | The internal path of the storage (within docker-container) |
| host_path     | path | no         | The external path of the storage (on the host system)      |
| comment       | text | no         | The comment of the storage                                 |
| browseable    | boolean | no      | Is the storage browseable?                                 |
| writable      | boolean | no      | Is the storage writable?                                   |
| guest_access  | boolean | no      | Do guests have access?                                     |
| write_list    | list of text | no | Names of accounts with write permission                    |

### Definition user

| Property      | Type | Mandatory? | Description           |
|---------------|------|------------|-----------------------|
| username      | text | yes        | Username of the specified user |
| password      | text | yes        | (Clear text) password of the specified user |
| uid           | number | yes      | Unix user id                                |
| update_password | boolean | yes   | Defines if the user password will be updated |

## Usage

### Requirements

```yaml
- name: install-samba
  src: https://github.com/borisskert/ansible-samba.git
  scm: git
```

### Playbook

```yaml
- hosts: test_machine
  become: yes

  roles:
    - role: ansible-samba
      samba_alpine_version: 3.11.5
      samba_version: 4.11
      samba_port: 445
      samba_interface: 0.0.0.0
      samba_volumes_path: /srv/samba
      samba_storages_volume: /srv/samba/storages
      samba_log_level: 2
      samba_enable_homes: no
      samba_enable_netbios: yes
      samba_netbios_name: mysamba
      samba_unix_extensions: no
      samba_users:
        - username: user1
          password: user1pwd
          uid: 2001
          update_password: true
        - username: user2
          password: user2pwd
          uid: 2002
      samba_storages:

        # this share has its own location
        - name: Share
          path: /share
          host_path: /srv/samba/storage/share
          comment: Share storage
          browseable: yes
          writable: yes
          guest_access: yes

        # this share is located within storage volume
        - name: Outgoing
          path: /out
          comment: Outgoing storage
          browseable: yes
          writable: no
          guest_access: true
          write_list:
            - user1
```

## Testing

Requirements:

* [Vagrant](https://www.vagrantup.com/)
* [VirtualBox](https://www.virtualbox.org/)
* [Ansible](https://docs.ansible.com/)
* [Molecule](https://molecule.readthedocs.io/en/latest/index.html)
* [yamllint](https://yamllint.readthedocs.io/en/stable/#)
* [ansible-lint](https://docs.ansible.com/ansible-lint/)
* [Docker](https://docs.docker.com/)

### Run within docker

```shell script
molecule test
```

### Run within Vagrant

```shell script
 molecule test --scenario-name vagrant --parallel
```

I recommend to use [pyenv](https://github.com/pyenv/pyenv) for local testing.
Within the Github Actions pipeline I use [my own molecule Docker image](https://github.com/borisskert/docker-molecule).
