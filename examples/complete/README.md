# Complete VPC

Exercises all stable inputs of the VPC-only module: name, description, primary and secondary CIDRs, user CIDRs, optional DNS servers, optional project assignment, and tags.

`dns_servers = null` intentionally uses the service default. Pass up to five reachable DNS IP addresses when custom DNS is required.

Run apply, then run plan again and require a no-change result before destroying the example.
