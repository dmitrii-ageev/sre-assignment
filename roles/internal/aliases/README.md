aliases
=======

This role will create an alias file and update aliases with the newalias command.

Requirements
------------

So far it was tested under Ubuntu 14, 16 and CentOS 7. 

Role Variables
--------------

 You can change options with "aliases__list" variable. DO NOT change it in the defaults/main.yml, use group_vars or host_vars instead. 

Example Playbook
----------------

Here is an example of how to use this role:

---
    - hosts: servers
      vars:
         aliases__list:
            user: 'the_user@domain.com, /the/path/to/a/file, "|/bin/command/to/execute arg1 arg2"'
            user2: some@email.address
      roles:
         - aliases
...

License
-------

GPLv2

Author Information
------------------

Dmitrii Ageev <d.ageev@gmail.com>

