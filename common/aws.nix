{
  config,
  lib,
  pkgs,
  ...
}:
let
  brazilCompletionDir = "${config.home.homeDirectory}/.brazil_completion";

  amzn_mcp_config = builtins.toJSON {
    mcpServers = {
      "awslabs.core-mcp-server" = {
        disabled = false;
        command = "uvx";
        args = [
          "awslabs.core-mcp-server@latest"
        ];
        autoApprove = [
          "prompt_understanding"
        ];
        env = {
          "FASTMCP_LOG_LEVEL" = "ERROR";
          "MCP_SETTINGS_PATH" = "${config.xdg.configHome}/mcphub/servers.json";
        };
      };
      "awslabs.cdk-mcp-server" = {
        disabled = false;
        command = "uvx";
        args = [
          "awslabs.cdk-mcp-server@latest"
        ];
        autoApprove = [
          "CDKGeneralGuidance"
          "GetAwsSolutionsConstructPattern"
        ];
        env = {
          FASTMCP_LOG_LEVEL = "ERROR";
        };
      };
      "awslabs.aws-documentation-mcp-server" = {
        disabled = false;
        command = "uvx";
        args = [ "awslabs.aws-documentation-mcp-server@latest" ];
        autoApprove = [
          "read_documentation"
          "search_documentation"
          "recommend"
        ];
        env = {
          "FASTMCP_LOG_LEVEL" = "ERROR";
        };
      };
      amzn-mcp = {
        disabled = false;
        command = "amzn-mcp";
        args = [ ];
        autoApprove = [
          # "acs_change_cp_records"
          # "acs_change_records"
          # "acs_create_contextual_parameter"
          # "acs_create_feature"
          # "acs_get_contextual_parameter"
          # "acs_get_feature"
          # "acs_list_cp_records"
          # "acs_list_records"
          # "acs_search_resources"
          # "acs_update_contextual_parameter"
          # "acs_update_feature"
          # "add_comment_quip"
          # "add_tag_work_contribution"
          # "add_work_contribution_stakeholder"
          # "admiral_instance_timeline"
          # "cradle_export_sql_to_file"
          # "cradle_get_job_details"
          # "cradle_get_job_run_details"
          # "cradle_get_job_run_output"
          # "cradle_get_profile"
          # "cradle_list_job_runs"
          # "cradle_list_jobs"
          # "cradle_list_profiles"
          # "cradle_run_job"
          # "cradle_search_jobs"
          # "cradle_search_profiles"
          # "create_folder_quip"
          # "create_quip"
          # "create_work_contribution"
          # "datacentral_workbench"
          # "datanet_reader"
          # "datanet_search"
          # "datanet_writer"
          # "delete_work_contribution"
          # "edit_quip"
          # "eureka_web_search"
          # "g2s2_create_cr"
          # "g2s2_create_label"
          # "g2s2_create_stage_version"
          # "g2s2_freeze_stage_version"
          # "g2s2_get"
          # "g2s2_import_stage_version"
          # "g2s2_list_stage_version"
          # "g2s2_move_label"
          # "genai_poweruser_agent_script_get"
          # "genai_poweruser_agent_script_list"
          # "genai_poweruser_agent_script_search"
          # "genai_poweruser_get_knowledge_metadata"
          # "genai_poweruser_get_knowledge_structure"
          # "genai_poweruser_list_knowledge"
          # "genai_poweruser_read_knowledge"
          # "genai_poweruser_search_knowledge"
          "get_folder_quip"
          # "get_katal_component"
          "get_recent_messages_quip"
          "get_thread_folders_quip"
          # "get_work_contribution"
          # "imr_costs_get_fleet_summary"
          # "imr_costs_search_fleet"
          "isengard"
          # "jira_add_comment"
          # "jira_config_helper"
          # "jira_create_issue"
          # "jira_get_attachment"
          # "jira_get_issue"
          # "jira_search_issues"
          # "jira_transition_issue"
          # "list_katal_components"
          "list_leadership_principles"
          # "list_work_contributions"
          # "lock_unlock_quip_document"
          "lookup_team_code_resource"
          "lookup_user_coding_activity_summary"
          # "marshal_get_insight"
          # "marshal_get_report"
          # "marshal_search_insights"
          # "mermaid"
          # "mosaic_list_controls"
          # "mosaic_list_risks"
          # "mox_console"
          # "orca_get_execution_data"
          # "orca_get_latest_error_details"
          # "orca_list_runs"
          # "orca_list_runs_for_objectId"
          # "overleaf_clone_project"
          # "overleaf_read_file"
          # "overleaf_upload_file"
          # "overleaf_write_file"
          # "pippin_create_artifact"
          # "pippin_create_project"
          # "pippin_get_artifact"
          # "pippin_get_project"
          # "pippin_list_artifacts"
          # "pippin_list_projects"
          # "pippin_sync_project_to_local"
          # "pippin_sync_project_to_remote"
          # "pippin_update_artifact"
          # "pippin_update_project"
          # "plantuml"
          # "policy_engine_get_risk"
          # "policy_engine_get_user_dashboard"
          # "post_talos_correspondence"
          "prompt_farm_prompt_content"
          "prompt_farm_search_prompts"
          "read_coe"
          "read_internal_website"
          "read_kingpin_goal"
          "read_orr"
          "read_permissions"
          "read_quip"
          "read_quip_from_urls"
          # "reassign_ticket_by_cti"
          # "remove_tag_work_contribution"
          # "rtla_fetch_logs"
          # "rtla_fetch_single_request_logs"
          # "sage_accept_answer"
          # "sage_add_comment"
          # "sage_create_question"
          # "sage_get_tag_details"
          # "sage_post_answer"
          "sage_search_tags"
          "search_MCMs"
          # "search_ags_confluence_website"
          # "search_datapath"
          # "search_eventstream"
          # "search_internal_issues"
          # "search_katal_components"
          # "search_people"
          "search_products"
          "search_quip"
          "search_quip_commented_by_current_user"
          "search_quip_created_by_current_user"
          "search_quip_mentioned_current_user"
          # "search_resilience_score"
          # "search_sable"
          # "search_symphony"
          # "sfdc_account_lookup"
          # "sfdc_contact_lookup"
          # "sfdc_list_tasks_activity"
          # "sfdc_opportunity_lookup"
          # "sfdc_sa_activity"
          # "sfdc_territory_lookup"
          # "sfdc_user_lookup"
          # "sim_add_comment"
          # "sim_add_label"
          # "sim_add_rank"
          # "sim_add_tag"
          # "sim_create_issue"
          # "sim_create_schedule"
          "sim_get_folders"
          "sim_get_issue"
          # "sim_remove_label"
          # "sim_remove_rank"
          # "sim_remove_tag"
          "sim_search_issues"
          # "sim_update_issue"
          # "slack_send_message"
          # "taskei_create_sprint"
          # "taskei_create_task"
          "taskei_get_room_identities"
          "taskei_get_rooms"
          "taskei_get_sprints"
          "taskei_get_task"
          # "taskei_update_task"
          # "update_work_contribution"
          # "write_internal_website"
        ];
        env = { };
      };
      builder-mcp = {
        disabled = false;
        command = "builder-mcp";
        args = [ ];
        autoApprove = [
          # "ApolloReadActions"
          # "BarristerEvaluationWorkflow"
          "BrazilBuildAnalyzerTool"
          "BrazilPackageBuilderAnalyzerTool"
          "BrazilWorkspace"
          # "CRRevisionCreator"
          "CheckFilepathForCAZ"
          "CrCheckout"
          # "CreatePackage"
          "Delegate"
          "GKAnalyzeVersionSet"
          "GetDogmaClassification"
          "GetDogmaRecommendations"
          "GetPipelineDetails"
          "GetPipelineHealth"
          "GetPipelinesRelevantToUser"
          "GetSasCampaigns"
          "GetSasRisks"
          "GetSoftwareRecommendation"
          "InternalCodeSearch"
          "InternalSearch"
          "MechanicDescribeTool"
          "MechanicDiscoverTools"
          "MechanicRunTool"
          "MechanicSetUserInput"
          # "OncallReadActions"
          "ReadInternalWebsites"
          "ReadRemoteTestRun"
          "SearchAcronymCentral"
          "SearchSoftwareRecommendations"
          # "SimAddComment"
          # "TaskeiCreateTask"
          "TaskeiGetRooms"
          "TaskeiGetTask"
          "TaskeiListTasks"
          # "TaskeiUpdateTask"
          "TicketingReadActions"
          # "TicketingWriteActions"
          "WorkspaceGitDetails"
          "WorkspaceSearch"
        ];
        env = { };
      };
    };
    nativeMCPServers = {
      neovim = {
        disabled = false;
        autoApprove = [
          # "delete_items"
          # "edit_file"
          # "execute_command"
          # "execute_lua"
          "find_files"
          "list_directory"
          # "move_item"
          "read_file"
          "read_multiple_files"
          # "write_file"
        ];
      };
    };
  };
in
{
  home = {
    activation = {
      builderToolbox =
        lib.hm.dag.entryAfter
          [
            "writeBoundary"
            "envSetup"
          ] # bash
          ''
            run --quiet toolbox completion zsh >"$ZCOMPDIR/_toolbox"
            run --quiet toolbox update
            run --quiet toolbox clean

            if $(command -v axe 2>&1 >/dev/null); then
            	run --quiet axe completion zsh >"$ZCOMPDIR/_axe"
            fi

            if $(command -v ada 2>&1 >/dev/null); then
            	run --quiet ada completion zsh >"$ZCOMPDIR/_ada"
            fi

            if $(command -v eda 2>&1 >/dev/null); then
            	run --quiet eda completions zsh >"$ZCOMPDIR/_eda"
            fi
          '';
      brazil =
        lib.hm.dag.entryAfter
          [
            "writeBoundary"
            "builderToolbox"
          ] # bash
          ''
            # Brazil will write ~/.brazil_completion/zsh_completion then fail to modify .zshrc
            run --silence brazil setup completion --shell zsh || true
          '';
    };

    packages = with pkgs; [
      awscli2
    ];

    sessionPath =
      if !pkgs.stdenv.isDarwin then
        [
          # Ensure consumed envs end up on PATH
          "/apollo/env/bt-rust/bin"
          "${config.home.homeDirectory}/.toolbox/bin"
        ]
      else
        [
          "${config.home.homeDirectory}/.toolbox/bin"
        ];
  };

  programs = {
    git = {
      userEmail = "angaidan@amazon.com";
      userName = "Aidan De Angelis";
    };
    zsh = {
      initContent = lib.mkMerge [
        (lib.mkOrder 550
          # bash
          ''
            path+=("$ZCOMPDIR")
            fpath+=("$ZCOMPDIR")

            local BRAZIL_ZSH_COMPLETION="${brazilCompletionDir}/zsh_completion"
            if [[ -f "$BRAZIL_ZSH_COMPLETION" ]]; then
            	source "$BRAZIL_ZSH_COMPLETION"
            else
            	echo "WARNING: brazil zsh completions have not been set up"
            fi
          ''
        )
      ];
      sessionVariables = {
        # From default .zshrc written by `brazil setup completion`
        # if you wish to use IMDS set AWS_EC2_METADATA_DISABLED=false
        AWS_EC2_METADATA_DISABLED = true;
        BRAZIL_PLATFORM_OVERRIDE =
          if pkgs.stdenv.hostPlatform.isAarch64 then
            "AL2_aarch64"
          else if pkgs.stdenv.hostPlatform.isx86_64 then
            "AL2_x86_64"
          else
            null;

        CDD_HOSTNAME_AL2_X86 = "dev-dsk-angaidan-2a-4351fd5e.us-west-2.amazon.com";
        CDM_HOSTNAME_AL2_X86 = "i-0350c0ed5d6a69b55";
        CDM_HOSTNAME_AL2023_X86 = "i-0636016045fe041a8";
        CDM_HOSTNAME_AL2023_ARM = "i-087650b5a8686c1a4";
      };
      shellAliases = {
        bb = "brazil-build";
        bba = "brazil-build apollo-pkg";
        bre = "brazil-runtime-exec";
        brc = "brazil-recursive-cmd";
        bws = "brazil ws";
        bwsuse = "bws use -p";
        bwscreate = "bws create -n";
        bbr = "brc brazil-build";
        bball = "brc --allPackages";
        bbb = "brc --allPackages brazil-build";
        bbra = "bbr apollo-pkg";

        cb-dry-run = "/apollo/env/bt-rust/bin/rust-customer-dry-runs";

        al2-x86-cdd = "ssh -t $CDD_HOSTNAME_AL2_X86 zsh -l";
        al2-x86-cdm = "ssh -t $CDM_HOSTNAME_AL2_X86 zsh -l";
        al2023-x86-cdm = "ssh -t $CDM_HOSTNAME_AL2023_X86 zsh -l";
        al2023-arm-cdm = "ssh -t $CDM_HOSTNAME_AL2023_ARM zsh -l";
      };
    };
  };
  xdg = {
    enable = true;
    configFile = {
      "mcphub/servers.json" = {
        text = amzn_mcp_config;
      };
    };
  };
}
