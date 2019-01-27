RSYSLOG role for Ansible
========================

This role for deploying and configuring [RSYSLOG log processing server](http://www.rsyslog.com/) on Linux hosts using [Ansible](http://www.ansibleworks.com/).

Requirements
------------

This role requires root access.

Role Variables
--------------

This roles comes preloaded with everything required by default. See the annotated defaults in `defaults/main.yml` for help in default configuration. You can override role variables in hosts/group vars, in your inventory, or in your play.

rsyslog__modules: A list of dictionaries. Defines a list of rsyslog modules.
Key-value pairs:
 * name    - The name of a module.
 * comment - Optional. Description of the module.
 * options - Configuration for the module.

rsyslog__config: A list of dictionaries. Defines rsyslog configuration files and their options.
Key-value pairs:
 * name    - The name of the file that goes into /etc/rsyslog.d/.
 * config  - Array of configuration sections (refer to the section structure below).

The configuration section structure:
 * comment  - Optional. Provide a description for a particular section.
 * options  - Directives for rsyslog, view the rsyslog man page for specifics.

Example Playbook
----------------

```
#
# example.yml
#
- name: Change rsyslog settings
  hosts: host.domain.net
  become: yes

  roles:
  - role: rsyslog
    rsyslog__modules:
    - comment: This sets up a TCP server on port 514 and permits 500 connections
      name: imtcp
      options: |
        $InputTCPServerRun 514
        $InputTCPMaxSessions 500

    rsyslog__config:
    - file: "99-iptables.conf"
      config:
      - comment: "This sends firewall messages to the iptables.log."
        options: |
          :msg, regex,  "^\[ *[0-9]*\.[0-9]*\] IPT"  -/var/log/iptables.log
      - comment: "Logging for the INND system."
        options: |
          news.crit                                   /var/log/news/news.crit
          news.err                                    /var/log/news/news.err
          news.notice                                -/var/log/news/news.notice
```

License
-------

GNU General Public License v2.0

Author Information
------------------

Dmitrii Ageev <dageev@gmail.com>
