admin:
  group.present:
    - gid: 1234

control:
  user.present:
    - fullname: Boss
    - shell: /bin/bash
    - password: '$6$FMzzQ..34PLTgqMd$FqXe3tmhA6VbNmgNW7dziCraT5BjyBVMnK8wYPquh9H9zcETWMYSZYU89BFut4QQomBQ6UDtP5nNvqhGElFdd.' # change to a password hash of your choice, to generate hash of 'your password' locally you can use: sudo salt-call --local shadow.gen_password 'your password'
    - home: /home/control
    - uid: 1234
    - gid: 1234
    - groups:
      - sudo
      - admin
      
ssh:
  service.running

sshkey:
  ssh_auth:
    - present
    - require:
      - user: control
    - user: control
    - source: salt://admin/id_rsa.pub

ufw:
  pkg.installed

ufw_service:
  service.running:
    - name: ufw

ufw enable:
  cmd.run:
    - unless: "ufw status | grep 'Status: active'"

ufw allow 22/tcp:
  cmd.run:
  - unless: "ufw status | grep '22/tcp'"
