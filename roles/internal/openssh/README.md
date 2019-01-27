openssh
=======

 This role will install OpenSSH package, and run it as a service.

Requirements
------------

 So far it was tested under CentOS 7.

Role Variables
--------------

 If you need to change OpenSSH options DO NOT change them in the defaults/main.yml.

Example Playbook
----------------

 Here is an example of how to use this role (for instance, with variables passed in as parameters):

    - hosts: servers
      roles:
         - openssh

License
-------

 GPLv2

Author Information
------------------

 Dmitrii Ageev <d.ageev@gmail.com>

