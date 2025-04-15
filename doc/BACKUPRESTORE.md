# Backup AI Vault DataBase

Backing up an Amazon Relational Database Service (RDS) database is the only part of AI  that should be backed up for data protection and disaster recovery. AWS provides several methods for backing up your RDS instances. 

1. Automated Backups: RDS automatically takes daily full snapshots of your database and continuously backs up transaction logs. This allows you to restore your database to any point in time within your configured retention period.  This is normally setup by default but always check your own configurtsion to be sure.
   
3. Manual Snapshots: You can manually trigger a snapshot of your database instance at any time. These snapshots are stored until you explicitly delete them and are useful for backups before major changes or for long-term archival.   
4. Exporting Data: While not a full instance backup, you can export the data from your RDS database to Amazon S3 using engine-specific tools ( pg_dump for PostgreSQL).

   https://aws.amazon.com/blogs/storage/point-in-time-recovery-and-continuous-backup-for-amazon-rds-with-aws-backup/#:~:text=Then%2C%20click%20Restore%20to%20point,access%20the%20created%20database%20instance.

   ```_Note_ We recommend backing up with a default nightly snapshot as a minimum```

# Restoring an AI Vault DataBase
These are the options available to you to restore  an RDS database from a Snapshot

1. Restore to Point in Time: Using automated backups, you can restore your database to a specific date and time within your defined backup retention period. This creates a new RDS instance with the data as it was at that point.   
2. Restore from Snapshot: You can restore your database from a manual snapshot. This creates a new RDS instance containing the data captured in that snapshot.   


https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_Tutorials.RestoringFromSnapshot.html

```_Note_  Restoring from a snapshot will create a new independant RDS database instance.  This will have its own new connection path / url.  Please note that this will need to be updated via your helm chart.
