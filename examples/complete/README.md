# Complete VPC

Exercises all stable inputs of the VPC-only module: name, description, primary and secondary IPv4 CIDRs, an automatically allocated IPv6 CIDR, user CIDRs, optional DNS servers, optional project assignment, and tags.

The example sets `enable_ipv6 = true`. Treat IPv6 enablement as a creation-time setting; do not toggle it in place on a production VPC.

`dns_servers = null` intentionally uses the service default. Pass up to five reachable DNS IP addresses when custom DNS is required.

Run apply, then run plan again and require a no-change result before destroying the example.
