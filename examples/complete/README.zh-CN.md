# 完整 VPC

创建一个完整的 VPC 模块，包括：名称、描述、主 IPv4 CIDR 与辅助 IPv4 CIDR、自动分配的 IPv6 CIDR、用户 CIDR、可选 DNS 服务器、可选项目归属，以及标签。

本示例设置 `enable_ipv6 = true`。应将 IPv6 启用视为创建时的一次性设置；切勿在生产 VPC 上原地切换该开关。

`dns_servers = null` 表示有意使用服务默认值。当需要自定义 DNS 时，传入最多五个可达的 DNS IP 地址。

先运行 apply，然后再次运行 plan，并在销毁本示例之前要求第二次 plan 报告无变更。
