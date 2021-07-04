# Docker swarm backup scripts.
These scripts backs up named volumes using Restic and a S3-compatible service.

# Example use:
Initialize S3 buckets for all stack services.
./Get-ServiceIds.ps1 | ./Get-VolumeDetails.ps1 | ./Add-Config.ps1 | ./Initialize-ResticS3.ps1

Show Restic snapshots for all stack services.
./Get-ServiceIds.ps1 | ./Get-VolumeDetails.ps1 | ./Add-Config.ps1 | ./Show-ResticS3.ps1

Backup all stack services.
./Get-ServiceIds.ps1 | ./Get-VolumeDetails.ps1 | ./Add-Config.ps1 | ./Backup-ToResticS3.ps1