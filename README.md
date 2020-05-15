# LUIS DevOps Sample

![Preview](https://img.shields.io/github/v/release/:andycw/:AndyLUISDevOpsSample?include_prereleases&sort=semver)

Template repository demonstrating DevOps practices for LUIS app development

## Getting Started with LUIS DevOps

This guide shows how to get GitHub Actions working with a sample LUIS project ***vacation_requests***, defined in this repo in the [model.lu file](luis-app/model.lu). The project creates a language understanding model to handle requests for vacation from employees. You can adapt this example to use with your own project.

We recommend working through this guide completely to ensure everything is working in your environment. After the sample is working, follow the [bootstrap instructions](../bootstrap/README.md) to convert the ***vacation_requests*** sample into a starting point for your project.

- [Get the code](#get-the-code)
- [Clone your repository](#clone-your-repository)
- [Provisioning Azure resources](#provisioning-azure-resources)
- [Setup the CI/CD pipeline](#set-up-the-ci/cd-pipeline)
  - [Set Environment Variables for Resource names in the pipeline YAML](#set-environment-variables-for-resource-names-in-the-pipeline-yaml)
  - [Create the Azure Service Principal](#create-the-azure-service-principal)
- [Protecting the master branch](#protecting-the-master-branch)
- [Next Steps](#next-steps)
- [Further Reading](#further-reading)

## Get the code

You'll use a GitHub repository and GitHub Actions for running the multi-stage pipeline with build, LUIS quality testing, and release stages. If you don't already have a GitHub account, create one by following the instructions at [Join GitHub: Create your account](https://github.com/join).

Next you must create a new repository to hold the code and the GitHub Actions pipelines. To create your repository:

- Click the green **Use this template** button near the top of the [LUISDevOpsSample](https://github.com/andycw/LUISDevOpsSample) home page for this GitHub repo, or click [this link](https://github.com/andycw/LUISDevOpsSample/generate), which copies this repository to your own GitHub location and squashes the history.
- Enter your own repository name where prompted
- Leave **Include all branches** unchecked as you only need the master branch of the source repo copied.
- Click **Create repository from template** to create your copy of this repository.
- You can use the resulting repository for this guide and for your own experimentation.

## Clone your repository

After your repository is created, clone it to your own machine. See [here](https://help.github.com/en/github/creating-cloning-and-archiving-repositories/cloning-a-repository) for instructions on how to clone a repository.

## Provisioning Azure resources

The CI/CD pipeline and the LUIS apps require some resources in Azure to be configured: a Lanuguage Understanding Authoring resource, a Langugae Understanding Prediction resource and an Azure Storage account.

To set up these reources, click the following button:

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAndyCW%2FLUISDevOpsSample%2Fmaster%2Fazuredeploy.json)

When you click the button, it takes you to a web page in the Azure Portal where you can enter the names of the resources. As you go through this page and enter your own values, take a note of the following names you enter, as you will need them in the next step when we configure the CI/CD pipeline:

- **Resource Group**
- **LUIS Authoring resource name**
- **LUIS Prediction resource name**
- **Storage account name**

## Setup the CI/CD pipeline

The CI/CD pipeline requires a few setup steps to prepare it for use. You will:

- Set environment variables in the pipeline YAML file to match the resource names you created in Azure
- Get a token for a Service Principal that you will configure and which you will store in GitHub secrets

### Set Environment Variables for Resource names in the pipeline YAML

The CI/CD piepline is defined in the **luis_ci.yaml** file in the **/.github/workflows** folder in your cloned repository. At the top of this file, a number of environment variables are defined to tell the pipeline the names of the Azure resources, and another environment variable **LUIS_MASTER_APP_NAME** is used to define the name of the LUIS app that is used to contain the versions of your LUIS app associated with the source checked into the master branch, and which the pipeline will create when it first runs.

Edit the **luis_ci.yaml** file and change the environment variables to match the names of the Azure resources you defined earlier, and to set the name of the master LUIS app. For example:

```yml
env:
  # Set the Azure Resource Group name
  AzureResourceGroup: luisDevOpsRG
  # Set the Azure LUIS Authoring Resource name
  AzureLuisAuthoringResourceName: LUISDevOpsResource-Authoring
  # Set the Azure LUIS Prediction Resource name
  AzureLuisPredictionResourceName: LUISDevOpsResource-Prediction
  # Set the Azure Storage Account name
  AzureStorageAccountName: luisdevopsresultsstorage
  # Set the name of the master LUIS app
  LUIS_MASTER_APP_NAME: LUISDevOps-master
```

When you have made your edits, save them, commit the changes and push the changes up to update the repository:

   ```bash
   git add .
   git commit -m "Updated parameters"
   git push
   ```

### Create the Azure Service Principal

You need to configure an Azure Service Principal to allow the pipeline to login using your identity and to work with Azure resources on your behalf. You will save the access token for the service principal in the GitHub Secrets for your repository.

1. Install the Azure CLI on your machine, if not already installed. See [here](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest) for instructions on installing the Azure CLI on your system.

1. Open a command terminal window and log into Azure:

    ```bash
    az login
    ```

   If the CLI can open your default browser, it will do so and load an Azure sign-in page. Sign in with your account credentials in the browser.

   Otherwise, open a browser page at https://aka.ms/devicelogin and enter the authorization code displayed in your terminal.

1. Execute the following command to confirm the selected azure subscription:

   ```bash
   az account show
   ```

1. If you have more than one subscription and do not have the correct subscription selected, select the right subscription with:

   ```bash
   az account set -s {Name or ID of subscription}
   ```

1. Execute the following command to create an Azure Service Principal:   
**IMPORTANT:** The Service Principal name you use must be unique within your Active Directory, so enter your own unique name for this service principal and substitute *myLUISDevOps* with your own name where indicated. Also enter the **Resource Group** name you created when you configured the Azure resources:

```bash
  ./setup/create_sp.sh
```

![Azure create-for-rbac](images/rbac.PNG?raw=true "Saving output from az ad sp create-for-rbac")

1. As prompted, save the JSON that is returned, then in your repository, create a **GitHub secret** named **AZURE_CREDENTIALS** and paste the JSON in as the value.

   You access GitHub Secrets by going to https://github.com/*your-GitHub-Id*/*your-repository*/settings and then click on **Secrets** in the **Options** menu, which brings up the UI for entering Secrets, like this:

![GitHub Secrets](images/gitHubSecretsAzure.PNG?raw=true "Saving in GitHub Secrets")

## Protecting the master branch

It is software engineering best practices to protect the master branch from direct check-ins. By protecting the master branch, you require all developers to check-in changes by raising a Pull Request and you may enforce certain workflows such as requiring more than one pull request review or requiring certain status checks to pass before allowing a pull request to merge. You can learn more about Configuring protected branches in GitHub [here](https://help.github.com/en/github/administering-a-repository/configuring-protected-branches).

You configure the specific workflows you require in your own software engineering organization. For the purposes of this sample, you will configure branch protections as follows:

- **master** branch is protected from direct check-ins
- Pull request requires **1** review approval (for simplicity - consider at least 2 reviewers on a real project)
- Status check configured so that the automation pipeline when triggered by a Pull Request must complete successfully before the PR can be merged.

To configure these protections:

1. In the home page for your repository on **GitHub.com**, click on **Settings**
1. On the Settings page, click on **Branches*** in the Options menu

   ![Branch protection settings](images/branch_protection_settings.png?raw=true "Accessing branch protection settings")
1. Under **Branch protection rules**, click the **Add rule** button
1. Configure the rule:
   1. In the **Branch name pattern** box, enter **master**
   1. Check **Require pull request reviews before merging**
   1. Check **Require status checks to pass before merging**

   ![Branch protection add rule](images/branch_protection_rule.png?raw=true "Configuring branch protection rule")
   1. Click the **Create** button at the bottom of the page

## Next Steps

You're all set. For the next steps, find out how to create a feature branch, make updates to your LUIS app, and to execute the CI/CD pipelines:

- **Next:** [Creating a Feature branch, updating your LUIS app, and executing the CI/CD pipelines](./Documentation/feature_branch.md).

## Further Reading

- [Creating a Feature branch, updating your LUIS app, and executing the CI/CD pipelines](./Documentation/feature_branch.md)
- [Setting up CI/CD pipelines with your own project](./Documentation/setting_up_own_project.md)
