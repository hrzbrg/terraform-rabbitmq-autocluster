Terraform RabbitMQ Autocluster
==============================

RabbitMQ Autocluster Container
------------------------------

The `docker` folder contains all necessary assets for the RabbitMQ Autocluster container. The Autocluster and AWS plugin are directly placed in the `docker/plugins` folder.

The config enables the following plugins:

* AWS
* Autocluster
* Management
* MQTT

### Instance Userdata
The userdata script is a piece of bash that AWS runs during initial instance startup. It runs as root, so we have the opportunity to install Docker and launch the container. If you work in another AWS region than `eu-west-1`, be sure to change the region specific settings in the userdata file.


Terraform
---------

Open the `main.tf` to see the building blocks that Terraform will set up:

1. The Autoscaling Group initially consists of 3 servers. The instance type can be configured in the `variables.tf` as `instance_type`.
2. The Launch Configuration feeds the `userdata.sh` and SSH Key to the instances.
3. An Elastic LoadBalancer sits in front of the cluster to handle SSL termination for the MQTT port 8883.
4. Two Security Groups are created. One for the ELB that only allows port 8883. Another one for the cluster instances that allows traffic from the ELB and SSH/RabbitMQ Management access from a manually defined IP range.

Once you filled in all necessary variables in the `variables.tf` you are ready to run Terraform to launch the Autoscaling Group.



