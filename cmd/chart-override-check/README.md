# chart-override-check

## Usage

```bash
chart-override-check -path $CHART_ROOT_PATH
```

```bash
chart-override-check -path $CHART_ROOT_PATH -skipCPath $SKIP_CONFIG_PATH
```

```bash
cat $SKIP_CONFIG_PATH
contour:
  - root-node
  - root-node/node-l1
  - root-node/node-l1/node-l2
```
