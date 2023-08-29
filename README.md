# Mailst App on Dokku

This guide outlines the steps to set up a Mailst app on a Dokku server.

## Table of Contents

- [Server Side Setup](#server-side-setup)
- [Domain Configuration](#domain-configuration)
- [Reverse Proxy Setup](#reverse-proxy-setup)
- [OpenDKIM Setup](#opendkim-setup)
- [DNS Configuration](#dns-configuration)
- [Push App and Test](#push-app-and-test)
- [User Management](#user-management)

## Server Side Setup

Run the following commands on your server:

```bash
# Create the app
dokku apps:create mailst
# Add Docker options
dokku docker-options:add mailst deploy "-p 25:25"
