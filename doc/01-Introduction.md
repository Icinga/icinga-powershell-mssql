# Introduction

This repository provides a number of check plugins for monitoring MSSQL databases on Windows with PowerShell and the [Icinga for Windows](https://icinga.com/docs/windows/latest) solution.

To see the full list of available plugins for MSSQL and the documentation you can have a look on the [MSSQL Plugin page](10-Icinga-Plugins.md).

## Authentication

For monitoring you will either require to authenticate by using a username and password against the database or by using the integrated security and adding the Icinga Agent user to the group of users being able to connect to the database.

## Requirements

This repository will require

* [Icinga PowerShell Framework v1.2.0](https://github.com/Icinga/icinga-powershell-framework/releases) or later
* [Icinga PowerShell Plugins v1.2.0](https://github.com/Icinga/icinga-powershell-plugins/releases) or later

## Installation

As all other Icinga for Windows components and extensions, the installation is straight forward. Further details and possibilities are explained within the [installation docs](02-Installation.md).
