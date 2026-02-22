###########################################################################
# Copyright (C) 2019 Crayon Australia
###########################################################################

$ScriptPath = Split-Path (Get-Variable MyInvocation -Scope 0).Value.MyCommand.Path


###########################################################################
# GetStagingAdminsGroup

function GetStagingAdminsGroup
{
  Log "Configuring an Adnins Group for the Staging database"

  # Force the preferences to be loaded so that the caller will be prompted
  # if the config value is not already set
  $StagingAdminsGroup = GetConfigValue "StagingAdminsGroup"

  return $StagingAdminsGroup
}

