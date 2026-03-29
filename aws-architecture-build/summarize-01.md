**Step 1: IAM (Identity and Access Management)**
IAM is the strict security boundary of AWS. It controls exactly who can log in and what they are allowed to do.

*Here are the four primary components:*

`Users`: Individual entities with permanent credentials (passwords or access keys).

`Groups`: Collections of Users. You attach permissions to the Group, not the individual User.

`Roles`: Identities with temporary, auto-rotating credentials. These are primarily assigned to AWS resources (like EC2 instances) so they can communicate securely without hardcoded passwords.

`Policies`: The actual JSON documents that define the permissions (Allow/Deny, Actions, and Resources).

**Step 2: VPC (Network Routing).**

This is where we build the physical network boundaries for your servers. We need to create the main `Virtual Private Cloud`, a `Public Subnet` (for things that face the internet), a `Private Subnet` (for secure backend databases), and an `Internet Gateway`.

`The Public Subnet` gets a route table that points directly to the Internet Gateway (IGW).

`The Private Subnet` gets a route table that points to a NAT Gateway.

`The NAT Gateway` gets a static Elastic IP and sits inside the Public Subnet, acting as a one-way secure proxy for your backend servers.

**Step 3: EC2 & Security Groups (Compute & Firewalls).**

A `Web Server` in the Public Subnet. It needs a Security Group that allows internet traffic (Port 80/443).

A `Backend Server` in the Private Subnet. It needs a highly restricted Security Group that only allows traffic coming from the Web Server, blocking the rest of the world completely.