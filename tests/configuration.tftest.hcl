mock_provider "google" {}

variables {
  project_id             = "training-example"
  lb_domain              = "gemini.example.com"
  google_oauth_client_id = "example.apps.googleusercontent.com"
}

run "valid_configuration" {
  command = plan
}

run "reject_domain_with_scheme" {
  command = plan
  variables { lb_domain = "https://gemini.example.com" }
  expect_failures = [var.lb_domain]
}

run "reject_domain_with_path" {
  command = plan
  variables { lb_domain = "gemini.example.com/login" }
  expect_failures = [var.lb_domain]
}

run "reject_zero_rotation" {
  command = plan
  variables { session_secret_rotation = 0 }
  expect_failures = [var.session_secret_rotation]
}

run "reject_negative_rotation" {
  command = plan
  variables { session_secret_rotation = -1 }
  expect_failures = [var.session_secret_rotation]
}

run "reject_fractional_rotation" {
  command = plan
  variables { session_secret_rotation = 1.5 }
  expect_failures = [var.session_secret_rotation]
}

run "valid_secret_reference" {
  command = plan
  module { source = "./modules/cloud-run" }
  variables {
    project_id            = "training-example"
    region                = "europe-west1"
    service_name          = "gemini-demo"
    service_account_email = "gemini-demo-run@training-example.iam.gserviceaccount.com"
    container_image       = "ghcr.io/it-erben/cloud-run-gemini-demo:sha-62bbde19c148f53d438540655171d73bcaf9c9d5"
    env_vars              = { GOOGLE_CLOUD_PROJECT = "training-example" }
    secret_env_vars       = { SESSION_SECRET = { secret = "session", version = "1" } }
  }
}

run "reject_duplicate_environment_variable" {
  command = plan
  module { source = "./modules/cloud-run" }
  variables {
    project_id            = "training-example"
    region                = "europe-west1"
    service_name          = "gemini-demo"
    service_account_email = "gemini-demo-run@training-example.iam.gserviceaccount.com"
    container_image       = "ghcr.io/it-erben/cloud-run-gemini-demo:sha-62bbde19c148f53d438540655171d73bcaf9c9d5"
    env_vars              = { SESSION_SECRET = "accidental-plaintext" }
    secret_env_vars       = { SESSION_SECRET = { secret = "session", version = "1" } }
  }
  expect_failures = [var.secret_env_vars]
}

run "reject_floating_secret_version" {
  command = plan
  module { source = "./modules/cloud-run" }
  variables {
    project_id            = "training-example"
    region                = "europe-west1"
    service_name          = "gemini-demo"
    service_account_email = "gemini-demo-run@training-example.iam.gserviceaccount.com"
    container_image       = "ghcr.io/it-erben/cloud-run-gemini-demo:sha-62bbde19c148f53d438540655171d73bcaf9c9d5"
    secret_env_vars       = { SESSION_SECRET = { secret = "session", version = "latest" } }
  }
  expect_failures = [var.secret_env_vars]
}
