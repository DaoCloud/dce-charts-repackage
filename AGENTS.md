# Repository Instructions

## Chart Upgrade Workflow

- For every chart upgrade or new chart, update the chart source `config` first, then run `make build_chart PROJECT=<chart-name>` to regenerate the packaged chart content.
- After regeneration, check that the generated `charts/<chart-name>/<chart-name>/values.yaml` is consistent with `charts/<chart-name>/<chart-name>/values.schema.json`. If generated values changed and the schema does not match, update the schema accordingly.
- Review `test/<chart-name>/install.sh` for version-specific settings, renamed values, required install flags, or runtime assumptions introduced by the upgraded chart, and update the test script when needed.
