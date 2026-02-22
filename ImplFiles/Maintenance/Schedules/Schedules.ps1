###########################################################################
# Copyright (C) 2018 Flexera Software
###########################################################################

$ScriptPath = Split-Path (Get-Variable MyInvocation -Scope 0).Value.MyCommand.Path

###########################################################################
# GENERAL
###########################################################################

###########################################################################
# List FlexNet Manager standard tasks

function ListFlexNetManagerTasks
{	
	Import-Module ScheduledTasks

  # get the tasks folder and list all contained tasks
  $tsfolder = GetConfigValue "FlexNetManagerTasksFolder"
  Log ""  
  Log "Listing scheduled tasks in folder: $tsfolder" -Level Info
  
  $format = "{0, -60} {1,-10}"  
  Log ""
  Log ($format -f "TaskName", "State") -Level Warning
  Log ($format -f "------------------------------------------------------------", "----------") -Level Warning
  
  $tasks = @()
  $tasks = Get-ScheduledTask -TaskPath $tsfolder | Select TaskName, State
  foreach ($task in $tasks) 
  {
    Log ($format -f $task.TaskName, $task.State) -Level Warning
  }

	return $true
}

###########################################################################
# List FlexAdmin custom tasks

function ListCustomTasks
{	
	Import-Module ScheduledTasks

  # get the tasks folder and list all contained tasks
  $tsfolder = GetConfigValue "FlexAdminTasksFolder"
  Log ""  
  Log "Listing scheduled tasks in folder: $tsfolder" -Level Info
  
  $format = "{0, -60} {1,-10}"  
  Log ""
  Log ($format -f "TaskName", "State") -Level Warning
  Log ($format -f "------------------------------------------------------------", "----------") -Level Warning
  
  $tasks = @()
  $tasks = Get-ScheduledTask -TaskPath $tsfolder | Select TaskName, State
  foreach ($task in $tasks) 
  {
    Log ($format -f $task.TaskName, $task.State) -Level Warning
  }

	return $true
}


###########################################################################
# Disable FlexNet Manager standard tasks

function DisableFlexNetManagerTasks
{	
	Import-Module ScheduledTasks

  # get the tasks folder and list all contained tasks
  $tsfolder = GetConfigValue "FlexNetManagerTasksFolder"
  Log ""  
  Log "Disabling scheduled tasks in folder: $tsfolder" -Level Info
  
  $format = "{0, -60} {1,-10}"  
  Log ""
  Log ($format -f "TaskName", "State") -Level Warning
  Log ($format -f "------------------------------------------------------------", "----------") -Level Warning
  
  $tasks = @()
  Get-ScheduledTask -TaskPath $tsfolder | Stop-ScheduledTask | Out-Null
  Get-ScheduledTask -TaskPath $tsfolder | Disable-ScheduledTask | Out-Null
  
  $tasks = Get-ScheduledTask -TaskPath $tsfolder |  Select TaskName, State
  foreach ($task in $tasks) 
  {
    Log ($format -f $task.TaskName, $task.State) -Level Warning
  }

	return $true
}

###########################################################################
# Disable FlexAdmin custom tasks

function DisableCustomTasks
{	
	Import-Module ScheduledTasks

  # get the tasks folder and list all contained tasks
  $tsfolder = GetConfigValue "FlexAdminTasksFolder"
  Log ""  
  Log "Disabling scheduled tasks in folder: $tsfolder" -Level Info
  
  $format = "{0, -60} {1,-10}"  
  Log ""
  Log ($format -f "TaskName", "State") -Level Warning
  Log ($format -f "------------------------------------------------------------", "----------") -Level Warning
  
  $tasks = @()
  Get-ScheduledTask -TaskPath $tsfolder | Stop-ScheduledTask | Out-Null
  Get-ScheduledTask -TaskPath $tsfolder | Disable-ScheduledTask | Out-Null
  
  $tasks = Get-ScheduledTask -TaskPath $tsfolder |  Select TaskName, State
  foreach ($task in $tasks) 
  {
    Log ($format -f $task.TaskName, $task.State) -Level Warning
  }

	return $true
}


###########################################################################
# Enable FlexNet Manager standard tasks

function EnableFlexNetManagerTasks
{	
	Import-Module ScheduledTasks

  # get the tasks folder and list all contained tasks
  $tsfolder = GetConfigValue "FlexNetManagerTasksFolder"
  Log ""  
  Log "Enabling scheduled tasks in folder: $tsfolder" -Level Info
  
  $format = "{0, -60} {1,-10}"  
  Log ""
  Log ($format -f "TaskName", "State") -Level Warning
  Log ($format -f "------------------------------------------------------------", "----------") -Level Warning

  $tasks = @()
  Get-ScheduledTask -TaskPath $tsfolder | Enable-ScheduledTask | Out-Null

  $tasks = Get-ScheduledTask -TaskPath $tsfolder |  Select TaskName, State
  foreach ($task in $tasks) 
  {
    Log ($format -f $task.TaskName, $task.State) -Level Warning
  }

	return $true
}

###########################################################################
# Enable FlexAdmin custom tasks

function EnableCustomTasks
{	
	Import-Module ScheduledTasks

  # get the tasks folder and list all contained tasks
  $tsfolder = GetConfigValue "FlexAdminTasksFolder"
  Log ""  
  Log "Enabling scheduled tasks in folder: $tsfolder" -Level Info
  
  $format = "{0, -60} {1,-10}"  
  Log ""
  Log ($format -f "TaskName", "State") -Level Warning
  Log ($format -f "------------------------------------------------------------", "----------") -Level Warning  

  $tasks = @()
  Get-ScheduledTask -TaskPath $tsfolder | Enable-ScheduledTask | Out-Null

  $tasks = Get-ScheduledTask -TaskPath $tsfolder |  Select TaskName, State
  foreach ($task in $tasks) 
  {
    Log ($format -f $task.TaskName, $task.State) -Level Warning
  }

	return $true
}

