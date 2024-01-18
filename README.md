# Infernet Node Deployment

Deploy a cluster of heterogenous [Infernet](https://github.com/ritual-net/infernet-node) nodes on Amazon Web Services (AWS) and / or Google Cloud Platform (GCP), using [Terraform](https://www.terraform.io/) for infrastructure procurement and [Docker compose](https://docs.docker.com/compose/) for deployment.


### Setup
1. [Install Terraform](https://developer.hashicorp.com/terraform/install)
2. **Configure nodes**: A node configuration file **for each** node being deployed.
    - See [example configuration](configs/0.json.example).
    - They must be named `0.json`, `1.json`, etc...
        - Misnamed files are ignored.
    - They must be placed under the top-level `configs/` directory.
    - Each node *strictly* requires its own configuration `.json` file, even if those are identical.
    - Number of `.json` files must match the `node_count` variable in `terraform.tfvars`.
        - Extra files are ignored.
    - For instructions on configuring nodes, refer to the [Infernet Node](https://github.com/ritual-net/infernet-node).

#### Infernet Router:
The Infernet Router REST server is configured automatically by Terraform. However, if you plan to use it, you need to understand its implications:
> **IMPORTANT:** When configuring a heterogeneous node cluster (i.e. `0.json`, `1.json`, etc. are not identical), container IDs should be reserved for a **unique container setup at the cluster level, i.e. across nodes (and thus `.json` files)**. That is becuase the router uses container IDs to make routing decisions between services running across the cluster.
>
> _Example:_ Consider nodes A and B, each running a single LLM inference container; node A runs `image1`, and node B runs `image2`. If we set `id: "llm-inference"` in both containers (`containers[0].id` attribute in `0.json`, `1.json`), the router will be **unable to disambiguate** between the two services, and will consider them interchangeable, _which they are not._ Any requests for `"llm-inference"` will be routed to either container, which is an error.
>
> Therefore, **re-using a IDs across configuration files must imply an identical container configuration**, including image, environment variables, command, etc. This will explicitly tell the router which containers are interchangeable, and allow it to distribute requests for those containers across _all nodes running that container._

### Deploy on AWS

1. Create an AWS service account for deployment:
    ```bash
    cd procure/aws
    chmod 700 create_service_account.sh
    ./create_service_account.sh
    ```
    This will require local authentication with the AWS CLI. Add `access_key_id` and `secret_access_key` to your Terraform variables (see step 3).

2. Make a copy of the example configuration file [terraform.tfvars.example](procure/aws/terraform.tfvars.example):
    ```bash
    cd procure/aws
    cp terraform.tfvars.example terraform.tfvars
    ```

3. Configure your `terraform.tfvars` file. See [variables.tf](procure/aws/variables.tf) for config descriptions.

4. Run Terraform:
    ```bash
    # Initialize
    cd procure
    make init provider=aws

    # Print deployment plan
    make plan provider=aws

    # Deploy
    make apply provider=aws

    # WARNING: Destructive
    # Destroy deployment
    make destroy provider=aws
    ```

### Deploy on GCP


1. Create a GCP service account for deployment:
    ```bash
    cd procure/gcp
    chmod 700 create_service_account.sh
    ./create_service_account.sh
    ```
    This will require local authentication with the GCP CLI, and create a local credentials file. Add the path to the credentials file (`gcp_credentials_file_path`) to your Terraform variables (see step 3).

2. Make a copy of the example configuration file [terraform.tfvars.example](procure/gcp/terraform.tfvars.example):
    ```bash
    cd procure/gcp
    cp terraform.tfvars.example terraform.tfvars
    ```
3. Configure your `terraform.tfvars` file. See [variables.tf](procure/gcp/variables.tf) for config descriptions.

4. Run Terraform:
    ```bash
    # Initialize
    cd procure
    make init provider=gcp

    # Print deployment plan
    make plan provider=gcp

    # Deploy
    make apply provider=gcp

    # WARNING: Destructive
    # Destroy deployment
    make destroy provider=gcp
    ```

### Using TfLint

```bash
# Install tflint
brew install tflint

# Install plugins
tflint --init

# Run on all directories
tflint --recursive
```

## License

[BSD 3-clause Clear](./LICENSE)
