# Shopify Vale Rules

## Publish

You need to create a zip archive with all the rules in it.
To do, you must navigate to the styles directory first, in order to _only zip the Shopify directory_.

```bash
cd styles
zip -r Shopify.zip Shopify -x "*.DS_Store"
```

You can then distribute this zip archive or publish it as a release artifact.
