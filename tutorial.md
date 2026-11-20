# Authorize KuiperDesk on your Google Cloud project

<walkthrough-tutorial-duration duration="6"></walkthrough-tutorial-duration>

## What this does

This tutorial creates the **authorization-only** resources KuiperDesk needs to
verify which Google Cloud project you selected. It creates:

* one Workload Identity Pool and one OIDC provider, bound to your KuiperDesk
  tenant and to this one-time installation, and
* one `roles/browser` grant to that pool's tenant-bound principal set.

It creates **no** service account, **no** service-account key, **no** compute,
**no** storage, **no** network, and **no** billable resource. Estimated
recurring cost: **0.00 USD per month**.

KuiperDesk never receives a service-account key. Verification uses Workload
Identity Federation: KuiperDesk exchanges its own short-lived assertion for a
short-lived Google token whose audience is the exact provider created below.

<walkthrough-info-message>
This is a **resource** authorization. It grants nothing in your Google Workspace
or Cloud Identity directory, and it is not a Google sign-in consent.
</walkthrough-info-message>

## Step 1: Choose the project

Pick the project the KuiperDesk satellite will live in. You need
`roles/resourcemanager.projectIamAdmin` and `roles/iam.workloadIdentityPoolAdmin`
on it, plus `roles/serviceusage.serviceUsageAdmin` to enable the three APIs.
The deployer service account (`KD_DEPLOYER_SA`) needs those three roles and
`roles/config.agent`, which lets Infrastructure Manager read its own blueprint.

<walkthrough-project-setup></walkthrough-project-setup>

```bash
gcloud config set project <walkthrough-project-id/>
```

Infrastructure Manager and the blueprint's own project lookup need two APIs on
before the preview can plan. The blueprint cannot enable Cloud Resource Manager
for itself, because it has to read the project first.

```bash
gcloud services enable config.googleapis.com cloudresourcemanager.googleapis.com
```

## Step 2: Read the plan before anything is created

`review.json` in this directory is the human-readable statement of exactly what
will be created, which APIs are enabled, what the network impact is, what the
recurring cost is, and what deletion removes. Open it:

<walkthrough-editor-open-file filePath="review.json">Open review.json</walkthrough-editor-open-file>

## Step 3: Preview with Infrastructure Manager

Infrastructure Manager runs the preview server-side, using the same blueprint
that will be applied. Nothing is created by a preview.

```bash
gcloud infra-manager previews create \
  projects/<walkthrough-project-id/>/locations/us-central1/previews/kuiperdesk-authorization \
  --local-source=. \
  --input-values=project_id=<walkthrough-project-id/>,tenant_id=${KD_TENANT_ID},installation_id=${KD_INSTALLATION_ID},issuer_uri=${KD_ISSUER_URI},return_url=${KD_RETURN_URL} \
  --service-account=projects/<walkthrough-project-id/>/serviceAccounts/${KD_DEPLOYER_SA}
```

Then read the preview result. Expected: **3 services enabled, 1 pool, 1
provider, 1 project IAM member. No deletions, no replacements.** Quota findings
are reported in the same output; a project already at its Workload Identity Pool
quota fails here rather than half-way through an apply.

If the preview lists anything else, **stop** and contact KuiperDesk support.

## Step 4: Apply

```bash
gcloud infra-manager deployments apply \
  projects/<walkthrough-project-id/>/locations/us-central1/deployments/kuiperdesk-authorization \
  --local-source=. \
  --input-values=project_id=<walkthrough-project-id/>,tenant_id=${KD_TENANT_ID},installation_id=${KD_INSTALLATION_ID},issuer_uri=${KD_ISSUER_URI},return_url=${KD_RETURN_URL} \
  --service-account=projects/<walkthrough-project-id/>/serviceAccounts/${KD_DEPLOYER_SA}
```

## Step 5: Return to KuiperDesk

```bash
gcloud infra-manager deployments describe \
  projects/<walkthrough-project-id/>/locations/us-central1/deployments/kuiperdesk-authorization \
  --format='value(terraformBlueprint.outputValues.return_to_arivaran.value)'
```

Open that URL. It carries the signed KuiperDesk state and the non-secret
provider resource name, and nothing else. You are not asked to copy a project
number, a pool ID or a provider name: KuiperDesk reads those back from Google
itself and refuses the session if they do not match.

<walkthrough-conclusion-trophy></walkthrough-conclusion-trophy>

## Removing this later

```bash
gcloud infra-manager deployments delete \
  projects/<walkthrough-project-id/>/locations/us-central1/deployments/kuiperdesk-authorization
```

That removes the pool, the provider and the `roles/browser` grant. The three
service APIs stay enabled on purpose, because other workloads in your project
may already depend on them; uninstalling KuiperDesk must not disable an API
somebody else is using.
