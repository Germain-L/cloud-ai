resource "azurerm_resource_group" "rg" {
  name     = "cloudai"
  location = "West Europe"
}

resource "azurerm_storage_account" "storageaccount" {
  name                     = "cloudaistorage"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
}

resource "azurerm_storage_share" "models" {
  name                 = "models"
  storage_account_name = azurerm_storage_account.storageaccount.name
  quota                = 50
}

resource "azurerm_container_group" "acg" {
  name                = "container"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  ip_address_type     = "Public"
  dns_name_label      = "cloudaiapi"
  os_type             = "Linux"
  restart_policy      = "Never"


  container {
    name   = "downloader"
    image  = "germain0l/model_downloader:latest"
    cpu    = "0.5"
    memory = "0.5"



    volume {
      name                 = "models-downloader"
      mount_path           = "/app/models"
      read_only            = false
      share_name           = azurerm_storage_share.models.name
      storage_account_name = azurerm_storage_account.storageaccount.name
      storage_account_key  = azurerm_storage_account.storageaccount.primary_access_key
    }

    environment_variables = {
      MODEL_URL_BLAIZE = "https://huggingface.co/couchpotato888/baize_lora_q4_ggml/resolve/main/baize_lora_13b_q4.bin"
      MODEL_URL_KOALA  = "https://huggingface.co/TheBloke/koala-7B-GPTQ-4bit-128g-GGML/resolve/main/koala-7B-4bit-128g.GGML.bin"
      // Add more MODEL_URL_ variables as needed
    }
  }

  // Second container (new one)
  container {
    name   = "local-ai"
    image  = "quay.io/go-skynet/local-ai:latest"
    cpu    = "3.5"
    memory = "15.5"

    volume {
      name                 = "models-api"
      mount_path           = "/build/models"
      read_only            = false
      share_name           = azurerm_storage_share.models.name
      storage_account_name = azurerm_storage_account.storageaccount.name
      storage_account_key  = azurerm_storage_account.storageaccount.primary_access_key
    }

    ports {
      port     = 8080
      protocol = "TCP"
    }
  }

  depends_on = [
    azurerm_storage_share.models
  ]
}
