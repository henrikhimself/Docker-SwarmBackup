# Backup scripts for Docker Swarm.
These scripts backs up named volumes using Restic and a S3-compatible service.

# Example use:
Initialize S3 buckets for all stack services.
./Get-ServiceIds.ps1 | ./Get-VolumeDetails.ps1 | ./Add-Config.ps1 | ./Initialize-ResticS3.ps1

Show Restic snapshots for all stack services.
./Get-ServiceIds.ps1 | ./Get-VolumeDetails.ps1 | ./Add-Config.ps1 | ./Show-ResticS3.ps1

Backup all stack services.
./Get-ServiceIds.ps1 | ./Get-VolumeDetails.ps1 | ./Add-Config.ps1 | ./Backup-ToResticS3.ps1

Restore all stack services.
./Get-ServiceIds.ps1 | ./Get-VolumeDetails.ps1 | ./Add-Config.ps1 | ./Restore-FromResticS3.ps1

Restore volume snapshot for a single stack service.
docker inspect bnyu4z5itjn3 --format "{{.ID}}" | ./Get-VolumeDetails.ps1 | ./Add-Config.ps1 | ./Restore-FromResticS3.ps1
