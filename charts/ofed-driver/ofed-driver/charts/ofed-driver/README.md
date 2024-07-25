# ofed-driver

## Introduction

Install Mellanox OFED driver

## Image Tag 

the following helm options decide the image tag, which has a format `{driverVersion}-${OSName}${OSVer}-${Arch}`

`image.driverVersion="24.04-0.6.6.0-0"`

`image.OSName="ubuntu"`

`image.OSVer="22.04"`

`image.Arch="amd64"`

refer to [nvidia available image tag](https://catalog.ngc.nvidia.com/orgs/nvidia/teams/mellanox/containers/doca-driver/tags)

for example:
- 24.04-0.6.6.0-0-ubuntu20.04-amd64
- 24.04-0.6.6.0-0-ubuntu22.04-amd64
- 24.04-0.6.6.0-0-ubuntu24.04-amd64
