# GitHub Repository Radar

This project collects public GitHub repository metadata and builds simple analytics tables in ClickHouse. It helps us see which repositories are active, popular, and growing over time.

The stack is simple: Python for ingestion, ClickHouse for storage, dbt for transformations, Lightdash for BI, and Prefect for one local end-to-end flow.

## Reproducibility

The easiest way to run everything is through the `Makefile`.

1. Create `.env` from the example and add `GITHUB_TOKEN` if you have one. Set `LIGHTDASH_SECRET` to any long random string for local runs:

```bash
make env
```

2. Build the local images:

```bash
make build
```

3. Start the services:

```bash
make up
```

4. Run the full pipeline with Prefect:

```bash
make prefect-run
```

`RUN_DATE` uses the current month by default.

5. If you want one command for the main validation flow, run:

```bash
make check
```

6. Open Lightdash at `http://localhost:8080`.

7. In Lightdash, create the project from the mounted dbt folder:

```text
Project path: /usr/app/dbt
Profile: github_stat
Target: prod
```

If you only want transformations again, run:

```bash
make dbt-run
make dbt-test
```

Use `make help` if you want to see the main commands again.
