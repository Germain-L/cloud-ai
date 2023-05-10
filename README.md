# CloudAI Project

This project is an Artificial Intelligence application deployed on Azure Cloud.
It includes a downloader container that downloads AI models and a local AI container that runs these models.

## Project Structure

This project is structured as follows:

- `downloader`: A Go program that downloads AI models from the specified URLs.
- `terraform`: Contains Terraform scripts to deploy the Azure infrastructure.

## Prerequisites

- Docker
- Go 1.20
- Terraform

## Getting Started

To run this project:

1. Clone the repository
2. Build the Docker image
3. Deploy the infrastructure using Terraform

### Build Docker Image

```bash
docker build -t downloader .
```

## Run the Docker Image

```bash
docker run -v ./models:/app/models --env-file .env downloader
```

## Deploy with Terraform
First, initialize Terraform:
```bash
terraform init
```
Then, apply the Terraform plan:
```bash
terraform apply
```
