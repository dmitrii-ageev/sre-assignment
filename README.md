SRE ASSIGNMENT NOTES
====================

## *I completed all the tasks from the assignment, including bonus ones.*

### Here is the brief description of what I've done:

I prepared the Terraform configuration that configures AWS VPC with a subnet, route, Internet Gateway, security group, and EC2 instance with RHEL 7.6 OS onboard. When an EC2 instance is ready, Terraform lanches Ansible that takes care of the OS configuration. In particular, configures a firewall, deploys a nginx container,  SELinix settings, accounts, sudo access, and deploys a monitoring script (8 a..c) - you'll find it at `/usr/local/bin/healthcheck.sh`.  

To simplify the deployment process, I wrote the script (`provision.sh`) that validates Terraform and Ansible code, prints a report of what it's going to do, and deploys changes to the cloud. As requested, the script takes AWS credentials as arguments, although you may use environment variables as well.  Use the command `provision.sh --help` to get the script usage info.

Okay, I was going to explain how you should download and install all the required software...However, instead of this, I created a Docker image that has all the required software inside (saved me a lot of typing, and probably it'll save you some time as well). 

**Here is what you need to do:**
run this command (hope you have Docker installed):
`docker run -it --rm -h sre-assignment dmitriiageev/sre-assignment`

As soon as you get a shell prompt, run: 
`./provision.sh -k <AWS access key>  -s <AWS secret access key> -r <AWS region name>`. 

When a deployment process completed, the script prints out the server IP address, so you can check how it responds. The monitoring log will be available at: `http://ip.address.goes.here/resource.log` .

### Risks associated with the application deployment:

Firstly, because of the way how Terraform works, the deployment process would be stopped if there is a name conflict (in the case when already exists an element of infrastructure with the same name). Secondly, if a connection to the Internet dropped in the middle of the deployment process, the configuration process wouldn't be accomplished, and the service wouldn't work as expected (yeah, push-like configuration managers affected to that risk).
The last one, to organise proper testing you need a staging environment that fully copies the production one, and the continuous integration tool, of course, like Jenkins or GitLab CI. Just code syntax validation is not enough.

### Questions, comments, concerns

If you have any questions, or need more thorough explanations, just let me know.

Regards,
  Dmitrii Ageev <d.ageev@gmail.com>.