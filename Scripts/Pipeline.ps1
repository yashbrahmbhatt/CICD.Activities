
function Get-Folders {
    $Response = Invoke-Webrequest "https://cloud.uipath.com/greenlightrpa/Development/orchestrator_/odata/Folders" -Headers @{"accept" = "application/json"; "Authorization" = "Bearer eyJhbGciOiJSUzI1NiIsImtpZCI6IkExRTAxNjE4MkYxMTI5QjMwNTIxOUY2OUQ2REY0N0UzMEQzRDJGQzJSUzI1NiIsInR5cCI6IkpXVCIsImN0eSI6IkpXVCIsIng1dCI6Im9lQVdHQzhSS2JNRklaOXAxdDlINHcwOUw4SSJ9.eyJuYmYiOjE2NzIyNTIxNDMsImV4cCI6MTY3MjI1NjA0MywiaXNzIjoiaHR0cHM6Ly9jbG91ZC51aXBhdGguY29tL2lkZW50aXR5XyIsImF1ZCI6IlVpUGF0aC5PcmNoZXN0cmF0b3IiLCJzdWJfdHlwZSI6InNlcnZpY2UuZXh0ZXJuYWwiLCJwcnRfaWQiOiI5MWVhNDY2Zi0xNjc5LTRmZjItYWYyOS0zNjZjMDAwMDliZWIiLCJjbGllbnRfaWQiOiIyMzg4MDI5Yi1mNGRlLTQzZGUtOTJlNi1iYWIxOTk5M2U5ZWMiLCJqdGkiOiJBRkQ4MzM5MjI2QjYxQjJBOUM1NDEyMDRDNUQ4OUQ4NSIsImlhdCI6MTY3MjI1MjQ0Mywic2NvcGUiOlsiT1IuQWRtaW5pc3RyYXRpb24iLCJPUi5Bc3NldHMiLCJPUi5BdWRpdCIsIk9SLkJhY2tncm91bmRUYXNrcyIsIk9SLkV4ZWN1dGlvbiIsIk9SLkZvbGRlcnMiLCJPUi5IeXBlcnZpc29yIiwiT1IuSm9icyIsIk9SLkxpY2Vuc2UiLCJPUi5NYWNoaW5lcyIsIk9SLk1MIiwiT1IuTW9uaXRvcmluZyIsIk9SLlF1ZXVlcyIsIk9SLlJvYm90cyIsIk9SLlNldHRpbmdzIiwiT1IuVGFza3MiLCJPUi5UZXN0RGF0YVF1ZXVlcyIsIk9SLlRlc3RTZXRFeGVjdXRpb25zIiwiT1IuVGVzdFNldHMiLCJPUi5UZXN0U2V0U2NoZWR1bGVzIiwiT1IuVXNlcnMiLCJPUi5XZWJob29rcyJdfQ.h9FkDuDOlYJL7Tl3j-wDz97UIBcZrjXm3X6mewM4NSL7Cqw96EDhyqTcdbds6nAuvBZnB7CbHxM2m3K9OTzwnh5LkEA_BAboBmVVsez0aoX6h-HBDkT5BpYiIqHoYUeP1jUkq0x8wogUMgVaEzXpIQs6iOgvBznvb4sgIRuZQQxOSTU7ZZk9_WCBizTdMyFONBxOthpqsUKvkvW29EbeKQunUzo5lme2reW5aiA2rE_qomSvQH-K_ltdL0AzZgyRnjsloSF-JOqsnPAkJBuwtAeI7QYw6MM73Pflaj-4bsSDdNwwgINmhcEKhYu8EWFkrJVr9Mt8H65GnpEmXMWbSA" }
    Write-Host $Response.Content
}

function Get-Repo {
    param(
        [Parameter(Mandatory = $true)][string]$RepositoryURL,
        [Parameter(Mandatory = $true)][string]$LocalPath,
        [Parameter(Mandatory = $true)][string]$BranchName
    )
    Write-Host "Starting pulling from repo..."

    Set-Location $RepositoryDirectory
    git init
    git remote add origin $RepositoryURL
    git pull origin $RepositoryBranch
    Set-Location "C:\"

    Write-Host "Source code obtained"
}

function Get-TestSets {
    param(
        [Parameter(Mandatory = $true)][string]$OrchestratorURL,
        [Parameter(Mandatory = $true)][string]$AccessToken,
        [Parameter(Mandatory = $true)][string]$FolderID
    )
    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("Authorization", "Bearer $AccessToken")
    $headers.Add("X-UIPATH-OrganizationUnitId", $FolderID)
    
    $response = Invoke-RestMethod "$OrchestratorURL/odata/TestSets" -Method 'GET' -Headers $headers
    $response | ConvertTo-Json
    Write-Host $response.value
    return $response.value
}

function Build-Package {
    param(
        [Parameter(Mandatory = $true)][string]$UiRobotExePath,
        [Parameter(Mandatory = $false)][string]$Version,
        [Parameter(Mandatory = $true)][string]$OutputDirectory,
        [Parameter(Mandatory = $true)][string]$ProjectJSONPath
    )
    Write-Host "Building package..."

    if ($Version.Length.Equals(0)) {
        $Version = Get-Date -Format "yyyy.MM.dd.HHmmss"
    }
    & $UIRobotExePath @("pack", "$ProjectJSONPath", "-o $OutputDirectory", "-v $Version")
    Write-Host "Package built"
}

function Get-Analysis {
    param(
        [Parameter(Mandatory = $true)][string]$StudioCLIPath,
        [Parameter(Mandatory = $true)][string]$ProjectJSONPath
    )

    Write-Host "Analyzing source code..."

    $results = & $StudioCLIPath @("analyze", "-p", "$ProjectJSONPath")
    Write-Host "Analysis complete"

    return $results
}

function Get-Folders {
    param(
        [Parameter(Mandatory = $true)][string]$OrchestratorURL,
        [Parameter(Mandatory = $true)][string]$AccessToken
    )
    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("Authorization", "Bearer $AccessToken")

    $response = Invoke-RestMethod "$OrchestratorURL/odata/Folders" -Method 'GET' -Headers $headers
    $response | ConvertTo-Json
    return $response.value
}

function Deploy-Package {
    param(
        [Parameter(Mandatory = $true)][string]$OrchestratorURL,
        [Parameter(Mandatory = $true)][string]$AccessToken,
        [Parameter(Mandatory = $true)][string]$PackagePath
    )
    Write-Host "Starting deployment to $OrchestratorURL"
    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("Authorization", "Bearer $AccessToken")

    $Form = @{
        file = Get-Item -Path $PackagePath
    }
    
    $response = Invoke-RestMethod "$OrchestratorURL/odata/Processes/UiPath.Server.Configuration.OData.UploadPackage" -Method 'POST' -Headers $headers -Form $Form
    $response | ConvertTo-Json
    Write-Host "Deployment complete."
}

function Invoke-TestSet {
    param(
        [Parameter(Mandatory = $true)][string]$OrchestratorURL,
        [Parameter(Mandatory = $true)][string]$AccessToken,
        [Parameter(Mandatory = $true)][string]$FolderID,
        [Parameter(Mandatory = $true)][string]$TestSetID
    )

    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("X-UIPATH-OrganizationUnitId", $FolderID)
    $headers.Add("Authorization", "Bearer $AccessToken")

    $response = Invoke-RestMethod "$OrchestratorURL/api/TestAutomation/StartTestSetExecution?testSetId=$TestSetID&triggerType=0" -Method 'POST' -Headers $headers
    $response | ConvertTo-Json
}

function Get-TestExecution {
    param(
        [Parameter(Mandatory = $true)][string]$OrchestratorURL,
        [Parameter(Mandatory = $true)][string]$AccessToken,
        [Parameter(Mandatory = $true)][string]$FolderID,
        [Parameter(Mandatory = $true)][string]$TestSetExecutionID
    )

    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $headers.Add("X-UIPATH-OrganizationUnitId", $FolderID)
    $headers.Add("Authorization", "Bearer $AccessToken")

    $response = Invoke-RestMethod "$OrchestratorURL/odata/TestSetExecutions($TestSetExecutionID)" -Method 'GET' -Headers $headers
    $response | ConvertTo-Json
    return $response
}

function Invoke-Pipeline {
    # Arguments
    # TODO: MAP THESE TO PARAMETERS SO THAT WE CAN USE IT IN UIPATH
    $TestSetExecutionCompleteCheckFrequency = 30
    $TestSetExecutionTimeout = 600
    $OrchestratorURL_QA = "https://cloud.uipath.com/greenlightrpa/Testing/orchestrator_"
    $OrchestratorURL_Prod = "https://cloud.uipath.com/greenlightrpa/Production/orchestrator_"
    $OrchestratorFolder_QA = "Demo_CICD"
    #$OrchestratorFolder_Prod = "Demo_CICD"
    $RepositoryURL = "https://greenlightrpa@dev.azure.com/greenlightrpa/Innovation/_git/CICD_Demo_Process"
    $UiRobotExePath = "C:\Program Files\UiPath\Studio\UiRobot.exe"
    #$StudioCLIPath = "C:\Program Files\UiPath\Studio\UiPath.Studio.CommandLine.exe"
    $RepositoryBranch = "main"
    $WorkingDirectory = "C:\Users\yash.brahmbhatt\Desktop\Test"
    $Token = "eyJhbGciOiJSUzI1NiIsImtpZCI6IkExRTAxNjE4MkYxMTI5QjMwNTIxOUY2OUQ2REY0N0UzMEQzRDJGQzJSUzI1NiIsInR5cCI6IkpXVCIsImN0eSI6IkpXVCIsIng1dCI6Im9lQVdHQzhSS2JNRklaOXAxdDlINHcwOUw4SSJ9.eyJuYmYiOjE2NzIzMjgwOTUsImV4cCI6MTY3MjMzMTk5NSwiaXNzIjoiaHR0cHM6Ly9jbG91ZC51aXBhdGguY29tL2lkZW50aXR5XyIsImF1ZCI6IlVpUGF0aC5PcmNoZXN0cmF0b3IiLCJzdWJfdHlwZSI6InNlcnZpY2UuZXh0ZXJuYWwiLCJwcnRfaWQiOiI5MWVhNDY2Zi0xNjc5LTRmZjItYWYyOS0zNjZjMDAwMDliZWIiLCJjbGllbnRfaWQiOiIyMzg4MDI5Yi1mNGRlLTQzZGUtOTJlNi1iYWIxOTk5M2U5ZWMiLCJqdGkiOiI5Mzk0RUI0RUM1REU0OTREODg4RUI3MkYzREEwMzk1RiIsImlhdCI6MTY3MjMyODM5NSwic2NvcGUiOlsiT1IuQWRtaW5pc3RyYXRpb24iLCJPUi5Bc3NldHMiLCJPUi5BdWRpdCIsIk9SLkJhY2tncm91bmRUYXNrcyIsIk9SLkV4ZWN1dGlvbiIsIk9SLkZvbGRlcnMiLCJPUi5IeXBlcnZpc29yIiwiT1IuSm9icyIsIk9SLkxpY2Vuc2UiLCJPUi5NYWNoaW5lcyIsIk9SLk1MIiwiT1IuTW9uaXRvcmluZyIsIk9SLlF1ZXVlcyIsIk9SLlJvYm90cyIsIk9SLlNldHRpbmdzIiwiT1IuVGFza3MiLCJPUi5UZXN0RGF0YVF1ZXVlcyIsIk9SLlRlc3RTZXRFeGVjdXRpb25zIiwiT1IuVGVzdFNldHMiLCJPUi5UZXN0U2V0U2NoZWR1bGVzIiwiT1IuVXNlcnMiLCJPUi5XZWJob29rcyJdfQ.cVMFz33YBD4B37QuCNq82BF5pQL9CyIEhzMUvNReAlzNdwGQ83yaQcOp-x0lYMj0KZJ7b1EiytpBzglhXATt5ziueTNwP-eFLVjw8yShIEmNRm4lcqdpr2RMwhPlxeEStsN79Vxajp2616yOFkvjcVfQqeyHxuNPnecK11rNe2T-U6hF-WYmkwl8w02aernPTTfTCNbdc4rx_lJJvXoqioreGnfvm0ir6wosJSx2siszLN1k3FP8C7mZrYp3mdrmYlWJreIJ6IzDFYoTl8tFRsyjdhZRDzxnX_50dOY6z3BmR7N028i2KDrHU7Q03GpDw_ItPFWOfEPy3o-9EXYOhA"
    $TestSetsToExecute = @("CICDDemo")


    # Local Vars
    $RepositoryDirectory = Join-Path $WorkingDirectory "repository"
    $BuildDirectory = Join-Path $WorkingDirectory "build"
    $ProjectJSONPath = Join-Path $RepositoryDirectory "project.json"

    
    # Clean working directory
    if (Test-Path -Path $WorkingDirectory) {
        Remove-Item -Path "$WorkingDirectory\*" -Recurse -Force
    }
    New-Item -Path $RepositoryDirectory -ItemType Directory
    New-Item -Path $BuildDirectory -ItemType Directory

    #~~~~~~~~~~~~BUILD~~~~~~~~~~~~
    # Step 1: Get source code from repository
    Get-Repo $RepositoryURL $RepositoryDirectory $RepositoryBranch

    # Step 2: Build package (current example uses autoversioning)
    Build-Package -UiRobotExePath $UiRobotExePath -OutputDirectory $BuildDirectory -ProjectJSONPath $ProjectJSONPath

    $PackagePath = Get-ChildItem -Path $BuildDirectory

    # (Optional) Analyze workflows
    #$AnalysisRaw = Get-Analysis -StudioCLIPath $StudioCLIPath -ProjectJSONPath $ProjectJSONPath
    # // TODO: Do something with Analysis

    #~~~~~~~~~~~~TEST~~~~~~~~~~~~
    # Step 4: Deploy to TEST Environment
    Deploy-Package -OrchestratorURL $OrchestratorURL_QA -AccessToken $Token -PackagePath $PackagePath

    # Step 5: Get the folder ID for the name provided
    $TestFolders = Get-Folders -OrchestratorURL $OrchestratorURL_QA -AccessToken $Token

    $TestFolderID = ""
    foreach ($folder in $TestFolders) {
        if ($OrchestratorFolder_QA.Equals($folder.FullyQualifiedName)) {
            $TestFolderID = $folder.Id
        }
    }
    if ($TestFolderId.Equals("")) {
        throw "Could not find the test folder with the fully qualified name $OrchestratorFolder_QA"
    }
    else {
        Write-Host "Found test folder id: $TestFolderId" 
    }

    # Step 6: Get Test Sets available for execution
    $TestSets = Get-TestSets -OrchestratorURL $OrchestratorURL_QA -AccessToken $Token -FolderID $TestFolderID
    
    # Step 7: Execute all test sets
    $TestSetsExecuted = @()
    foreach ($set in $TestSets) {
        if ($TestSetsToExecute.Contains($set.Name)) {
            $ExecutionID = Invoke-TestSet -OrchestratorURL $OrchestratorURL_QA -AccessToken $Token -TestSetID $set.Id -FolderID $TestFolderID
            $TestSetsExecuted += $ExecutionID
        }
    }
    
    # Step 8: Wait for Tests to complete and Validate Tests
    $TestsStartTime = Get-Date
    $TestSetExecutionComplete = $false
    $TestSetExecutions = @{}
    while (-not $TestSetExecutionComplete) {
        $TestSetExecutionComplete = $true
        foreach($execution in $TestSetsExecuted){
            $response = Get-TestExecution -OrchestratorURL $OrchestratorURL_QA -AccessToken $Token -FolderID $TestFolderID -TestSetExecutionID $execution
            if(-not $response.Status.Equals("Passed") -And -not $response.Status.Equals("Failed")) {
                $TestSetExecutionComplete = $false
                break
            } else {
                $TestSetExecutions.Add($execution, $response.Status)
            }
        }
        Write-Host $TestSetExecutionComplete
        if(-not $TestSetExecutionComplete) {
            $CurrentTime = Get-Date
            $TotalDuration = $CurrentTime - $TestsStartTime
            Write-Host $TotalDuration.TotalSeconds
            if($TotalDuration.TotalSeconds -ge $TestSetExecutionTimeout){
                throw "Test execution took longer than expected. Please increase the TestSetExecutionTimeout argument."
            } else {
                Write-Host "Not all test set execution have completed"
                Start-Sleep -Seconds $TestSetExecutionCompleteCheckFrequency
            }
        } else {
            Write-Host "All test set execution have been completed"
        }
    }

    # (Optional) Report any failed test cases on ticketing platform
    if($TestSetExecutions.ContainsValue("Failed")){
        throw "One or more test sets failed execution. Please check Orchestrator and resolve any bugs before committing again."
    }

    #~~~~~~~~~~~~PROD~~~~~~~~~~~~
    # Step 9: Deploy to Production Environment
    Deploy-Package -OrchestratorURL $OrchestratorURL_Prod -AccessToken $Token -PackagePath $PackagePath

    # (Optional) Run a smoke test

}

Invoke-Pipeline