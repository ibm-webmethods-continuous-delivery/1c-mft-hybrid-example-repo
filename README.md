# Hybrid Managed File Transfer With Integration Example Repository

This repository contains the code resulting from the execution of its associated [tutorial](https://github.com/ibm-webmethods-continuous-delivery/1c-mft-hybrid-example-tutorial).

It follows the same tag and branch convention as in the tutorial, for example when following tutorial `stepNN`, checkout the branch or tag `stepNN`. Example clone command for the initial `step04`:

```sh
git clone -b step04 https://github.com/ibm-webmethods-continuous-delivery/1c-mft-hybrid-example-repo.git
```

And further down the road, checking out `step05`:

```sh
git checkout step05
```

## Repository Subdirectories

This repository groups its contents in the following subdirectories, serving dedicated purposes:

Sub-folder Name|Description
-|-
`01-code`|The code we are developing and delivering, and where this git repository represents the source of truth
`01-code/is-packages`|Code of type Integration Server package
`05-run-configs`|Local run configurations or environment, useful for the code authoring, also known as development
`09-test-harnesses`|One or more test harnesses
`09-test-harnesses/send-entities`|A simple test harness that sends a business data file set in a zip file with accompanying checksums for integrity assurance. This is the first test harness that is executed from step04 onwards in a simil-TDD manner, to help us explore step-by-step the depth of our hybrid processing endeavor.