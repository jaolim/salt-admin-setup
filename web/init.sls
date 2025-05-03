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
Disable default site:
  apache_site.disabled:
    - name: default