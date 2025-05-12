terraform {
  required_providers {
    grafana = {
      source = "grafana/grafana"
      version = "3.22.1"
    }
  }
}


// Step 1: Configure the provider
provider "grafana" {
  alias = "cloud"
  cloud_access_policy_token = var.grafana_cloud_api_key
}

// Step 2: Create a service account and key for the stack
resource "grafana_cloud_stack_service_account" "cloud_sa" {
  provider   = grafana.cloud
  stack_slug = var.grafana_cloud_stack_slug
  name       = var.grafana_cloud_service_account_name
  role       = var.grafana_cloud_service_account_role
  is_disabled = false
}

output "service_account_id" {
  value = grafana_cloud_stack_service_account.cloud_sa.id
}

resource "grafana_cloud_stack_service_account_token" "cloud_sa_token" {
  provider   = grafana.cloud
  stack_slug = var.grafana_cloud_stack_slug

  name               = var.grafana_cloud_service_account_token_name
  service_account_id = grafana_cloud_stack_service_account.cloud_sa.id
}

// Step 3: Create resources within the stack
provider "grafana" {
  alias = "my_stack"

  url  = var.grafana_cloud_url
  auth = grafana_cloud_stack_service_account_token.cloud_sa_token.key
}

resource "grafana_folder" "my_folder" {
  provider = grafana.my_stack

  title = var.grafana_folder_title
  uid   = var.grafana_folder_uid
}

resource "grafana_dashboard" "test" {
  provider    = grafana.my_stack
  folder      = grafana_folder.my_folder.uid
  config_json = file(var.grafana_dashboard_config_file)
}
output "dashboard_id" {
  value = grafana_dashboard.test.uid
}


resource "grafana_team" "test-team" {
  provider = grafana.my_stack
  name  = "_Terraform Team"
  email = "Terraform.Team@example.com"
  members = [
    "courtney.abbe@mail.com"
  ]
}

resource "grafana_role" "super_user" {
  provider = grafana.my_stack
  name        = "_Terraform Super User"
  description = "My Super User description"
  uid         = "superuseruid"
  version     = 1
  global      = true

  permissions {
    action = "org.users:add"
    scope  = "users:*"
  }
  permissions {
    action = "org.users:write"
    scope  = "users:*"
  }
  permissions {
    action = "org.users:read"
    scope  = "users:*"
  }
}

resource "grafana_library_panel" "test" {
    provider = grafana.my_stack
 name = "panel"
  model_json = jsonencode({
    gridPos = {
      x = 0
      y = 0
      h = 10
      w = 10
    }
    title   = "panel"
    type    = "text"
    version = 0
  })
}



// SECTION 81: Automation: Config as Code


resource "grafana_role" "test_role" {
    provider = grafana.my_stack
  name    = "_Locked Down Role"
  uid     = "restricted"
  version = 1
  global  = true

  permissions {
    action = "dashboards:read"
    scope  = "dashboards:*"
  }
} 



 resource "grafana_service_account" "test_sa" {
     provider = grafana.my_stack
   name = "terraform_test_sa"
   role = "Viewer"
 }

 resource "grafana_role_assignment" "test" {
     provider = grafana.my_stack
   role_uid         = grafana_role.test_role.uid
   #users            = [grafana_team.test_team.members]
   teams            = [grafana_team.test_team.id]
   service_accounts = [grafana_service_account.test_sa.id]
   
 }

 resource "grafana_dashboard_permission" "collectionPermission" {
       provider = grafana.my_stack
   dashboard_uid = grafana_dashboard.test.uid
   permissions {
     role       = "Editor"
     permission = "Edit"
   }
   permissions {
     team_id    = grafana_team.test_team.id
     permission = "View"
   }
 
 }

resource "grafana_dashboard" "home" {
  provider    = grafana.my_stack
  folder      = grafana_folder.my_folder.uid
  config_json = file(var.grafana_dashboard_config_file_home)
}


resource "grafana_dashboard_permission" "homePermission" {
  provider = grafana.my_stack
  dashboard_uid = grafana_dashboard.home.uid
  permissions {
    role       = "Editor"
    permission = "Edit"
  }
  permissions {
    team_id    = grafana_team.test_team.id
    permission = "View"
  }
}

resource "grafana_team" "test_team" {
    provider = grafana.my_stack
  name = "_ Terraform Member "
  members = [
    "alice.martinez@email.com"
  ]
  preferences {
    home_dashboard_uid = "bdxf89ntv0lj4g"
    theme = "light"
  }
    
  }


// I think these are corrected vars
// resource "grafana_service_account" "test_sa" {
//   provider = grafana.my_stack
//   name     = var.service_account_name
//   role     = var.service_account_role
// }
// 
// resource "grafana_role_assignment" "test" {
//   provider         = grafana.my_stack
//   role_uid         = var.role_uid
//   #users            = [grafana_team.test_team.members]
//   teams            = [var.team_id]
//   service_accounts = [grafana_service_account.test_sa.id]
// }
// 
// resource "grafana_dashboard_permission" "collectionPermission" {
//   provider      = grafana.my_stack
//   dashboard_uid = var.dashboard_uid
//   permissions {
//     role       = var.dashboard_permission_role
//     permission = var.dashboard_permission
//   }
//   permissions {
//     role       = var.dashboard_permission_role
//     permission = var.dashboard_permission
//   }
// }
resource "grafana_folder" "rule_folder" {
  title = "My Alert Rule Folder"
  provider = grafana.my_stack
  
}
resource "grafana_folder_permission" "rule_folder_permissions" {
  folder_uid = grafana_folder.rule_folder.uid
  provider = grafana.my_stack
  permissions {
    role       = "Editor"
    permission = "Edit"
  }

  permissions {
    team_id    = grafana_team.test_team.id
    permission = "View"
  }
}
resource "grafana_rule_group" "my_alert_rule" {
  name             = "My Rule Group"
  provider = grafana.my_stack
  folder_uid       = grafana_folder.rule_folder.uid
  interval_seconds = 240
  //org_id           = 1
  rule {
    name           = "My Alert Rule 1"
    for            = "2m"
    condition      = "B"
    no_data_state  = "NoData"
    exec_err_state = "Alerting"
    annotations = {
      "a" = "b"
      "c" = "d"
    }
    labels = {
      "e" = "f"
      "g" = "h"
    }
    is_paused = false
    data {
      ref_id     = "A"
      query_type = ""
      relative_time_range {
        from = 600
        to   = 0
      }
      datasource_uid = "PD8C576611E62080A"
      model = jsonencode({
        hide          = false
        intervalMs    = 1000
        maxDataPoints = 43200
        refId         = "A"
      })
    }
    data {
      ref_id     = "B"
      query_type = ""
      relative_time_range {
        from = 0
        to   = 0
      }
      datasource_uid = "-100"
      model          = <<EOT
{
    "conditions": [
        {
        "evaluator": {
            "params": [
            3
            ],
            "type": "gt"
        },
        "operator": {
            "type": "and"
        },
        "query": {
            "params": [
            "A"
            ]
        },
        "reducer": {
            "params": [],
            "type": "last"
        },
        "type": "query"
        }
    ],
    "datasource": {
        "type": "__expr__",
        "uid": "-100"
    },
    "hide": false,
    "intervalMs": 1000,
    "maxDataPoints": 43200,
    "refId": "B",
    "type": "classic_conditions"
}
EOT
    }
  }
}