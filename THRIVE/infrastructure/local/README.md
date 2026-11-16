# THRIVE Test PostgreSQL

This copy uses **thrive_test**, role **thrive_test_local**, at **127.0.0.1:55432**. It never starts or migrates the original cluster on 5432.

Run from this copy's THRIVE directory:

~~~powershell
./scripts/initialize-local.ps1
./scripts/start-database.ps1
./scripts/start-backend.ps1 -ApplyMigrations -EnableDevelopmentIdentity
~~~

Initialization preserves existing verified test credentials. The copied original credentials were replaced during isolation; no original credential is reused. Never rotate credentials for an already initialized cluster.

The portable PostgreSQL binaries are shared read-only tools. Mutable cluster data, owner records, logs and random credentials belong to this copy:
- .local/thrive-test/postgresql/data
- .local/thrive-test/postgresql/cluster-owner.json
- .local/thrive-test/owner.json
- infrastructure/local/.env.local (ignored by Git)

Native Windows PostgreSQL cannot read this Arabic path. The helper maps an unused drive (currently T:) to this project's root. Unicode device-target verification prevents using another workspace's mapping. Physical data stays inside this project.

Before migrations, the script connects read-only and checks current_database, current_user, server port and actual data_directory against the owned cluster. Existing unowned/nonempty directories are refused. No original data is copied.

To stop only the verified test database, without deleting files:

~~~powershell
./scripts/stop-project.ps1
./scripts/stop-database.ps1
~~~

The separate Compose file uses a test-instance project name, distinct volume, test credentials and host port 55432. **Docker is an untested alternative here**; the verified lifecycle scripts intentionally require portable/local PostgreSQL and refuse unverified Docker data directories. Do not start Compose alongside the portable cluster or reuse an existing volume.

Full results and limitations: [TEST_ISOLATION.ar.md](../../docs/TEST_ISOLATION.ar.md).
