apache2:
  pkg.installed

/home/control/public/html/default.com/index.html:
  file.managed:
    - makedirs: True
    - user: control
    - group: admin
    - source: salt://web/index.html

/etc/apache2/sites-available/default.com.conf:
  file.managed:
    - source: salt://web/default.com.conf

/etc/apache2/sites-enabled/default.com.conf:
  file.symlink:
    - target: ../sites-available/default.com.conf

apache2service:
  service.running:
    - name: apache2
    - watch:
      - file: /etc/apache2/sites-enabled/default.com.conf

a2dissite 000-default.conf && systemctl restart apache2:
  cmd.run:
    - onlyif: "ls /etc/apache2/sites-enabled | grep '000-default.conf'"

ufw allow 80/tcp:
  cmd.run:
    - unless: "ufw status | grep '80/tcp'"

ufw allow 443/tcp:
  cmd.run:
    - unless: "ufw status | grep '443/tcp'"