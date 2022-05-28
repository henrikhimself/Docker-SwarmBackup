# Powershell scripts for backing up Docker Swarm named volumes to Restic S3.
This repository contains Powershell scripts for backing up named volumes belonging to services in a Docker Swarm. The scripts will scale each service to 0 prior to backing up its named volumes. Once done, the service is scaled back to its original replication count. The backups are created using [Restic](https://restic.readthedocs.io/).

The Powershell scripts relies on pipelining multiple scripts together to complete an operation e.g. creating or restoring a backup. Below, there are examples for backing up all named volumes in a Docker Swarm by using the ./Get-ServiceIds.ps1 script to supply the pipeline with service ids. The final script in the pipeline uses Restic and S3 to e.g. initialize buckets, backup/restore backup snapshots and finally display created snapshots. 

Backup configuration is provided using a JSON file (see the 'restic-example' folder). The path of a config file can be given when invoking the Add-Config.ps1 script to set the S3 server url and credentials, a restic repository password, root CA for trusting self-signed certificates and a bucket prefix (bucket names are generated using the names of named volumes).

I use these scripts in my homelab only. They have been tested with a Docker Swarm running 10-15 services with NFS named volumes. I use [Minio](https://min.io/) for my S3 compatible storage.

# Example use:
Initialize S3 buckets for all stack services.
- ./Get-ServiceIds.ps1 | ./Get-VolumeDetails.ps1 | ./Add-Config.ps1 | ./Initialize-ResticS3.ps1

Show Restic snapshots for all stack services.
- ./Get-ServiceIds.ps1 | ./Get-VolumeDetails.ps1 | ./Add-Config.ps1 | ./Show-ResticS3.ps1

Backup all stack services.
- ./Get-ServiceIds.ps1 | ./Get-VolumeDetails.ps1 | ./Add-Config.ps1 | ./Backup-ToResticS3.ps1

Restore all stack services.
- ./Get-ServiceIds.ps1 | ./Get-VolumeDetails.ps1 | ./Add-Config.ps1 | ./Restore-FromResticS3.ps1

Restore volume snapshot for a single stack service.
- docker inspect bnyu4z5itjn3 --format "{{.ID}}" | ./Get-VolumeDetails.ps1 | ./Add-Config.ps1 | ./Restore-FromResticS3.ps1
