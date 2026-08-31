# Changelog

All notable changes to this module will be documented in this file.

## [Unreleased]

### Added

- Initial VPC-only module.
- Support for creating a VPC or reading an explicitly identified existing VPC.
- Support for primary and secondary IPv4 CIDRs, user CIDRs, DNS servers, project assignment, and tags.
- Basic, complete, secondary CIDR, and existing VPC examples.
- Creation-time IPv6 enablement with normalized IPv6 Outputs and a dual-stack example.
- Retained IPv6 lifecycle and IPv4 Gateway Provider-spike fixtures under `tests/`.

### Fixed

- Enabled IPv6 in the complete example and exposed its IPv6 status and allocated CIDR as example outputs.
- Corrected the complete and secondary-CIDR examples to use one non-overlapping secondary CIDR from the same private address range as the primary CIDR.
- Rejected empty collection inputs that Provider v0.0.60 reads back as `null` and would otherwise cause a permanent plan difference.
- Added validation for the documented one-secondary-CIDR quota, canonical private ranges, and primary/secondary range compatibility.
- Derived `enable_ipv6` from the returned IPv6 CIDR so create and Existing VPC modes expose consistent results despite the Provider's write-only enable field.

### Deferred

- IPv4 Gateway remains outside the writable Module interface because the Provider has no standalone Gateway resource and VPC creation does not orchestrate Gateway attachment, the required default route, or enablement. Read-only VPC outputs remain available.
- Explicit IPv6 CIDR assignment remains outside the interface until add/change/remove can be verified with a safe account-owned prefix.
