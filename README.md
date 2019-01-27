SRE ASSIGNMENT NOTES
====================

## *I completed all the tasks from the assignment, including bonus ones.*

### Here is the brief description of what I've done:

I prepared the Terraform configuration that configures AWS with a VPC, subnet, route, Internet Gateway, security group, and EC2 instance with RHEL 7.6 OS onboard. When an EC2 instance is ready, Terraform lanches Ansible that takes care of the OS configuration. In particular, it configures OS parameters, firewall rules, deploys a nginx container, update SELinix settings, accounts, sudo access rights, and deploys a monitoring script (8 a..c) - you'll find it at `/usr/local/bin/healthcheck.sh`.

To simplify the deployment process, I wrote the script (`provision.sh`) that validates Terraform and Ansible code, prints a report of what it's going to do, and deploys changes to the cloud. As requested, the script takes AWS credentials as arguments, although you may use environment variables as well.  Use the command `provision.sh --help` to get the script usage info.

Okay, I was going to explain how you should download and install all the required software...However, instead of this, I created a Docker image that has all the required software inside (saved me a lot of typing, and probably it'll save you some time as well).

**Here is what you need to do:**

Run this command (hope you have Docker installed):

`docker run -it --rm -h sre-assignment dmitriiageev/sre-assignment`

As soon as you get a shell prompt, run (the leading dot is not a typo):

`. ./provision.sh -k <AWS access key>  -s <AWS secret access key> -r <AWS region name>`.

When a deployment process completed, the script prints out the server IP address, so you can check how it responds. The monitoring log will be available at: `http://ip.address.goes.here/resource.log` .

### Risks associated with the application deployment:

Firstly, because of the way how Terraform works, the deployment process would be stopped if there is a name conflict (in the case when already exists an element of infrastructure with the same name).
Secondly, if a connection to the Internet dropped in the middle of the deployment process, the configuration process wouldn't be accomplished, and the service wouldn't work as expected (yeah, push-like configuration managers affected to that risk).
Lastly, to organise proper testing you need a staging environment that's the exact copy of the production environment. Ideally, you also need a continuous integration tool like Jenkins or GitLab CI, it's useful to make a trial deployment onto staging environment,  that will check your . Just code syntax validation is not enough.

One more thing: if you use a container for a deployment process, you'll lose terraform state info as soon as the container is destroyed, so it's a good idea to run the command `terraform destroy terraform` when you've done with testing.

### Questions, comments, concerns

If you have any questions, or need more thorough explanations, just let me know.

*__Regards,__*

_Dmitrii Ageev <<d.ageev@gmail.com>>_
