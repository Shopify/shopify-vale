# Shopify Vale Rules

## Publish Vale rules

You might need to publish Vale rules. For example, you want to make updates available to PRs against `Shopify/shopify-dev`.

The `styles/Shopify` directory contains the Vale linting rules. To publish Vale rules, you need to create a `.zip` of the `Shopify` directory and either distribute or publish the `.zip`.x

Run the following command. It changes to the `styles` directory and zips the `Shopify` directory:

```bash
cd styles
zip -r Shopify.zip Shopify -x "*.DS_Store"

```

**Options**

- `-x`: Restricted? e..g. no E11?
- `-r`: Recursive. Executes the script on all subdirectories.

You can then distribute this zip archive or publish it as a release artifact.

<!-- Let's add some detail on how to distribute and how to publish. Goal is to enable tech writers to contribute to these rules as our styles evolve. -->
