# update-aws-security-grp
The script scans for defined port number in security groups and updates the IP address. Subnet mask for the address will always be /32, meaning limited to 1 host address.

Ideally, have your own personal security group in each VPC. And that security group can be attached to the required resources.

## Before running:  

### Configure AWS CLI  
https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-quickstart.html

### Update variables: 
- aws profile
- group-ids
- fixed-ips (static IP that will always be applied into security group)
- port number  
![image](https://user-images.githubusercontent.com/10956184/169195334-99998c49-856f-4234-8c21-a94caeb48c64.png)

Leaving group_ids or fixed_ips is blank, script to simply ignore that block of code.  
