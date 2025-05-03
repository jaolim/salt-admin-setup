admin:
  group.present:
    - gid: 1234

control:
  user.present:
    - fullname: Boss
    - shell: /bin/bash
    - password: '$6$FMzzQ..34PLTgqMd$FqXe3tmhA6VbNmgNW7dziCraT5BjyBVMnK8wYPquh9H9zcETWMYSZYU89BFut4QQomBQ6UDtP5nNvqhGElFdd.'
    - home: /home/control
    - uid: 1234
    - gid: 1234
    - groups:
      - sudo
      - admin

sshkey:
  ssh_auth:
    - present
    - require:
      - user: control
    - user: control
    - source: salt://admin/id_rsa.pub
      