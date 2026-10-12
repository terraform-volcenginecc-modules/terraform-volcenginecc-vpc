# IPv6 双栈示例

本示例创建一个带私有 IPv4 CIDR 的 VPC，并请求火山引擎自动分配一个 IPv6 CIDR。

在 Provider `0.0.60` 下，应将 `enable_ipv6` 视为创建时的一次性设置。切勿在生产 VPC 上原地切换该开关。
