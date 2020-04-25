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
| alpine_version        | text | no | latest | Your selected alpine version |
| samba_version         | text | no | latest | Your selected samba version  |
| image_name            | text | no | local/samba-server | Docker image name                                 |
| container_name        | text | no | samba.service                 | The name of the docker container       |
| interface             | ip address | no | 0.0.0.0                 | Mapped network for web-interface ports |
| samba_port            | port       | no | <empty>                 | Default port (TCP): 445                |
| enable_netbios        | boolean    | no | no                      | Enables NetBios option and publish ports 137, 138 and 138 |
| netbios_name          | text       | no | <empty>                 | Configures the NetBios name                               |
| volumes_path          | path       | yes | <empty>                 | Directory where the persistent data will be stored       |
| config_volume         | path       | no  | <volumes_path>/config   | Directory where the config data will be stored           |
| data_volume           | path       | no  | <volumes_path>/data     | Directory where the server data will be stored           |
| storages_volume       | path       | no  | <volumes_path>/storages | Directory where the storages are located                 |
| homes_volume          | path       | no  | <volumes_path>/homes    | Directory where the homes are located                    |
| workgroup             | text       | no  | WORKGROUP               | The default Samba workgroup            |
| server_string         | text       | no  | "%h server (Samba, Alpine)" | The default Samba server string    |
| enable_homes          | boolean    | no  | no                          | Enables home directories for users |
| unix_extensions       | boolean    | no  | <empty>                     | Enable or disable UNIX extensions  |
| storages              | array of storage | no | <empty array>          | The samba storage configuration    |
| users                 | array of user    | no | <empty array>          | The samba user configuration       |

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
      alpine_version: 3.11.5
      samba_version: 4.11.5-r0
      samba_port: 445
      interface: 0.0.0.0
      volumes_path: /srv/samba
      storages_volume: /srv/samba/storages
      log_level: 2
      enable_homes: no
      enable_netbios: yes
      netbios_name: mysamba
      unix_extensions: no
      users:
        - username: user1
          password: user1pwd
          uid: 2001
        - username: user2
          password: user2pwd
          uid: 2002
      storages:

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
