# Java DevSecOps delivery lab: reviewer guide

A Java application with a Maven build, Dockerfile, Jenkinsfile, Helm environments, and AWS Terraform definitions.

## Start the review

Explain artifact versioning, environment values, security checks, infrastructure boundaries, and the evidence needed before claiming live delivery.

| Source | Review focus |\n| --- | --- |\n| [Dockerfile](Dockerfile) | Build context, runtime configuration, ports, and persistence |\n| [Jenkinsfile](Jenkinsfile) | Triggers, credentials, failure handling, and deploy conditions |\n| [pom.xml](pom.xml) | Implementation, assumptions, and operational boundaries |\n| [helm/devsecops-demo/Chart.yaml](helm/devsecops-demo/Chart.yaml) | Implementation, assumptions, and operational boundaries |\n| [helm/devsecops-demo/templates/deployment.yaml](helm/devsecops-demo/templates/deployment.yaml) | Implementation, assumptions, and operational boundaries |\n| [helm/devsecops-demo/templates/service.yaml](helm/devsecops-demo/templates/service.yaml) | Implementation, assumptions, and operational boundaries |

## A useful interview walkthrough

1. State the problem and the specific part you implemented or changed.
2. Open the source above and follow one request, release, or failure from start to finish.
3. Show a reproducible result, including an actual failure and the observation that confirms recovery.
4. Explain one tradeoff and one limitation. Distinguish a local test from a live deployment.

## Evidence and limits

This guide is based on the default-branch source inspected on 16 October 2026. It is a source review, not a fresh deployment or a certification of every feature. Existing CI runs and tests should be checked at the commit being demonstrated. Do not present screenshots, inherited code, planned features, or old README statements as proof of a current deployment.
