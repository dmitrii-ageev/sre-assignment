sudo
====

The role installs and configures sudo (Debian and RedHat). Also it manages sudoers.d directory.

Role Variables
--------------

* sudo__defaults - list of defaults in sudoers file
* sudo__sudoers - list of users/groups in sudoers file
* sudo__sudoers_d - list of users/groups in sudoers.d directory

Example Playbook
----------------

        - hosts: all
          sudo: yes
          roles:
            - sudo
          vars:
            sudo__sudoers:
              - name: %sudo
                nopasswd: true
            sudo__sudoers_d:
              - name: user1
                hosts:
                  - ALL
                asusers:
                 - root
                nopasswd: true
                commands:
                  - /usr/bin/id

License
-------

GPLv2

