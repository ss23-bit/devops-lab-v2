**Step 1: IAM (Identity and Access Management)**
IAM is the strict security boundary of AWS. It controls exactly who can log in and what they are allowed to do.
IAM (Identity and Access Management) only understands JSON text
`resource` = The Action (Creates something in AWS)
`data` = The Calculation (Local to your computer) It simply "prepares" the JSON text so you can use it later in a real resource.

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

**Step 4: High Availability (The Load Balancer) & Auto Scaling**

The `ALB` acts as a traffic cop. It receives internet traffic and distributes it evenly to your web servers. If a web server dies, the `ALB`'s health check catches it and stops sending traffic there.

*target_group_arns*
`The Workflow`: When the ASG launches a new server, it calls the AWS API and says: "Hey Target Group (ARN), I just made a new server. Please add its ID to your list."
The ASG must "register" the new Instance ID because that is the only way the ALB finds out a new server exists.

*What happens if it Fails*
`AWS rule`: An Application Load Balancer cannot exist in a single Availability Zone

`ALB detects failure`: The ALB sends a ping, but the server doesn't answer (Timeout).

`ALB marks Unhealthy`: The ALB tells the Target Group, "This server is broken. Take it off the Guest List."

`ALB stops traffic`: Immediately, the ALB stops sending user requests to that broken server.

`ASG takes action`: (If you set health_check_type = "ELB"), the ASG sees the "Unhealthy" status in the Target Group. The ASG then terminates the broken server and builds a new one.

`EC2 Type` (Default): The ASG only checks if the Virtual Machine is powered on and the network is connected.
`ELB Type`: The ASG now listens to the Target Group's health check. If your application starts returning 500 Error or stops responding, the Target Group marks it as "Unhealthy." The ASG sees this and says: "The Load Balancer says this app is dead. I will terminate this server and build a fresh one."

**Step 5: Object Storage (Amazon S3)**

`EC2` servers should be "stateless." never store permanent files (like user profile pictures, PDF reports, or application backups)
we use `Amazon S3`.

*versioning_configuration* *status = "Enabled"*
`"Undo Button"` Normally, an S3 object is identified just by its Key (the filename). With versioning enabled, every object gets a unique Version ID.

`Server-Side Encryption (SSE)`: AWS. S3 encrypts the file the moment it is received. AWS handles the keys automatically.

`apply_server_side_encryption_by_default`, you are forcing S3 to encrypt every single file that enters the bucket, even if the person who uploaded it didn't ask for it.

*aws_s3_bucket_public_access_block*
`block_public_acls`	Stops anyone from adding a new "public" permission to a specific file (object) in the future.
`ignore_public_acls`	If a file already has a public permission on it, AWS will simply ignore it and keep the file private.
`block_public_policy`	Stops you (or anyone) from attaching a Bucket Policy that allows public access. AWS will throw an error if you try.
`restrict_public_buckets`	A final safety layer that ensures only AWS services and authorized users in your account can touch the bucket.

*S3 vs RDS* (The file cannot be edited in S3.)
`Data Format`	 Unstructured (Any file type).          `/`	Structured (Tables, Columns, Rows).
`Max Size`	Virtually infinite (5TB per single file).   `/`	Limited by the disk size you choose (e.g., 64TB).
`Access Method`	HTTP/HTTPS (via API or URL).            `/`	SQL Queries (via a Database Driver).
`Performance`	High "Throughput" (Good for big files). `/`	Low "Latency" (Good for quick lookups).

**Step 6: Databases (Amazon RDS).**

Amazon RDS requires a "DB Subnet Group" that spans across at least two Availability Zones

`allocated_storage = 20` (Gibibytes (GiB).)

*`multi_az = false` vs `multi_az = true`*(High Availability)

`Setup`	One database in one Availability Zone (AZ). `/`	One primary DB + One hidden "Standby" DB in a different AZ.
`Cost`	Standard price.	                            `/` Double the price
`Failure`	If the AZ goes down, your app crashes.  `/`	If the primary fails, AWS switches to the standby in 60 seconds.

*The ASG (Stateless):*
- An Auto Scaling Group is designed for things that are disposable.
*The RDS `multi_az` (Stateful):*
- A database is not disposable.

`skip_final_snapshot = false (The Default)`: When you run terraform destroy, the process will hang for 5–10 minutes while AWS creates a final backup. If you don't have a name for that backup, the command will actually fail.
`skip_final_snapshot = true`: Just delete it

**Step 7 & 8: Decoupling and Serverless (SQS & SNS).**

*SNS (Broadcast) vs SQS (Buffer)*
`Delivery Model`	Push: "I'm sending this to you NOW."            `/`	Pull: "Pick this up when you're ready."
`Persistence`	No. Message is gone if not delivered.	            `/` Yes. Stored safely for days.
`Rate Limiting`	None. It sends as fast as it can.(can cause flood)	`/` Perfect. Worker controls the speed.
`Logic`	        "Hey, everyone! Something happened!"	            `/` "Here is a specific task to be done."

*Scenario*
- `The Event`: A user makes a booking.
- `The SNS Topic`: Receives the "Booking Created" message.
- `The Fan-out`: SNS sends that message to three different SQS queues (one for Receipts, one for Analytics, and one for Hotel Notifications).
- `The Safety`: Each team has its own SQS Queue. If the Analytics team's database is slow, their queue just gets longer, but it doesn't affect the Receipt team or the Hotel team.

**Step 9: Global Edge (CloudFront & Route 53)**

*B. Security (The "Shield")*
- CloudFront acts as a Protective Layer.
- It integrates with `AWS WAF (Web Application Firewall)` to block hackers.
- It includes `AWS Shield (Standard)` for free to stop DDoS attacks.

Data Transfer Out from `S3` to the internet is expensive. However, Data Transfer from `S3` to `CloudFront` is $0 (Free)

*How They Work Together*
- `The Ask`: User types www.piyapoom.com in their browser.
- `Route 53 (The Map)`: The browser asks Route 53, "Where is this site?" Route 53 says, "Go to this CloudFront address: d123.cloudfront.net." It also has `Smart Routing`.
- `CloudFront (The Local Store)`: The browser goes to the CloudFront Edge Location in Bangkok.
- `The Delivery`: * If the photo is already in the Bangkok cache, CloudFront gives it to the user instantly.

**Step 10: Monitoring and Auditing (CloudWatch & CloudTrail)**

`Amazon CloudWatch` (Performance): It tracks CPU usage, network traffic, RAM, and application errors. You use it to trigger alarms.

`Amazon CloudTrail` (Security): Every time a user, an IAM Role, or a service touches your AWS account (e.g., someone deletes a database), CloudTrail records the IP address, the time, and the exact identity.

*The "Timing"* (CloudWatch Metric alarm)
`period = 120`: This is the "Time Window" in seconds. Here, CloudWatch looks at 120-second (2-minute) chunks of data.

`evaluation_periods = 2`: This is the "Patience" setting. It says: "The CPU must be high for 2 consecutive windows before you ring the bell."

`The Math: 120 seconds × 2 periods = 240 seconds (4 minutes).`
- Your server must be working too hard for at least 4 minutes straight before the alarm triggers. This prevents the alarm from ringing if the server is just busy for a quick 30-second task.

*Scenario*
0-2 min	85%	Above 80? Yes.	OK (Waiting for 2nd period)
2-4 min	90%	Above 80? Yes.	ALARM! (2 in a row)
4-6 min	40%	Above 80? No.	OK (Alarm resets)