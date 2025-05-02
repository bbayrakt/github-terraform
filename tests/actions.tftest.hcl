variables {
  repo_name        = "actions-test-repo"
  repo_description = "Test repository for GitHub Actions"
  repo_visibility  = "public"
  repo_auto_init   = true
}

# Create a GitHub repository
run "create_repository_with_defaults" {
  command = apply

  assert {
    condition     = github_repository.repo.name == var.repo_name
    error_message = "Repository name did not match expected value."
  }
}

# Create a single Actions variable
run "create_single_action_variable" {
  command = apply

  variables {
    actions_variables = {
      first_variable = {
        variable_name = "MY_ACTION_VAR"
        value = "my_value"
      }
    }
  }

  assert {
    condition     = length(github_actions_variable.vars) == 1
    error_message = "Expected one action variable to be created"
  }

  assert {
    condition     = github_actions_variable.vars["first_variable"].value == "my_value"
    error_message = "Action variable value does not match expected value"
  }
}

# Create multiple Actions variables
run "create_multiple_action_variables" {
  command = apply

  variables {
    actions_variables = {
      first_variable = {
        variable_name = "MY_ACTION_VAR_1"
        value = "my_value_1"
      }
      second_variable = {
        variable_name = "MY_ACTION_VAR_2"
        value = "my_value_2"
      }
      third_variable = {
        variable_name = "MY_ACTION_VAR_3"
        value = "my_value_3"
      }
    }
  }

  assert {
    condition     = length(github_actions_variable.vars) == 3
    error_message = "Expected two action variables to be created"
  }

  assert {
    condition     = github_actions_variable.vars["first_variable"].value == "my_value_1"
    error_message = "Action variable MY_ACTION_VAR_1 value does not match expected value"
  }

  assert {
    condition     = github_actions_variable.vars["second_variable"].value == "my_value_2"
    error_message = "Action variable MY_ACTION_VAR_2 value does not match expected value"
  }

  assert {
    condition     = github_actions_variable.vars["third_variable"].value == "my_value_3"
    error_message = "Action variable MY_ACTION_VAR_3 value does not match expected value"
  }
}

# Create a single Actions environment variable
run "create_single_action_environment_variable" {
  command = apply

  variables {
    # Create an environment for the action variable
    repo_environments = {
      production = {
        environment = "production"
      }
    }
    actions_environment_variables = {
      first_env_variable = {
        environment   = "production"
        variable_name = "MY_ENV_VAR"
        value         = "my_env_value"
      }
    }
  }

  assert {
    condition     = length(github_actions_environment_variable.envvars) == 1
    error_message = "Expected one action environment variable to be created"
  }

  assert {
    condition     = github_actions_environment_variable.envvars["first_env_variable"].value == "my_env_value"
    error_message = "Action environment variable value does not match expected value"
  }
}

# Create multiple Actions environment variables
run "create_multiple_action_environment_variables" {
  command = apply

  variables {
    # Create an environment for the action variable
    repo_environments = {
      production = {
        environment = "production"
      }
      test = {
        environment = "test"
      }
    }
    actions_environment_variables = {
      first_env_variable = {
        environment   = "production"
        variable_name = "MY_ENV_VAR_1"
        value         = "my_env_value_1"
      }
      second_env_variable = {
        environment   = "production"
        variable_name = "MY_ENV_VAR_2"
        value         = "my_env_value_2"
      }
      third_env_variable = {
        environment   = "test"
        variable_name = "MY_ENV_VAR_3"
        value         = "my_env_value_3"
      }
    }
  }

  assert {
    condition     = length(github_actions_environment_variable.envvars) == 3
    error_message = "Expected three action environment variables to be created"
  }

  assert {
    condition     = github_actions_environment_variable.envvars["first_env_variable"].value == "my_env_value_1"
    error_message = "Action environment variable MY_ENV_VAR_1 value does not match expected value"
  }

  assert {
    condition     = github_actions_environment_variable.envvars["second_env_variable"].value == "my_env_value_2"
    error_message = "Action environment variable MY_ENV_VAR_2 value does not match expected value"
  }

  assert {
    condition     = github_actions_environment_variable.envvars["third_env_variable"].value == "my_env_value_3"
    error_message = "Action environment variable MY_ENV_VAR_3 value does not match expected value"
  }

  assert {
    condition     = github_actions_environment_variable.envvars["first_env_variable"].environment == "production"
    error_message = "Action environment variable MY_ENV_VAR_1 environment does not match expected value"
  }

  assert {
    condition     = github_actions_environment_variable.envvars["second_env_variable"].environment == "production"
    error_message = "Action environment variable MY_ENV_VAR_2 environment does not match expected value"
  }

  assert {
    condition     = github_actions_environment_variable.envvars["third_env_variable"].environment == "test"
    error_message = "Action environment variable MY_ENV_VAR_3 environment does not match expected value"
  }
}
