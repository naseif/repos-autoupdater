Param(
    [string]$repoPath,
    [int32]$timeOut,
    [string]$commitMessage
)

$repoDirectory = ""

if ([string]::IsNullOrEmpty($repoPath)) {
  $repoDirectory = $PSScriptRoot
} else {
  $repoDirectory = $repoPath
}


function checkStatusAndCommit {
  Param(
    [Parameter(Mandatory=$true)]
    [string]$gitPath
  )

  $status = git -C $gitPath status
  $stdout = $status  | Where-Object { $_ -isnot [System.Management.Automation.ErrorRecord] }

  if ([string]$stdout -like "*nothing to commit, working tree clean*") {
    Write-Host "Nothing to commit" -ForegroundColor Green
    return "False"
  } else {
  if ([string]::IsNullOrEmpty($commitMessage)) {
    Write-Host "Committing and pushing existing changes!" -ForegroundColor Green
    git -C $gitPath add .
    git -C $gitPath commit -m "Update"
    git -C $gitPath push
  } else {
    Write-Host "Committing and pushing existing changes!" -ForegroundColor Green
    git -C $gitPath add .
    git -C $gitPath commit -m $commitMessage
    git -C $gitPath push
    }
  }
}


function checkIfProjectHasGit {

  Param(
    [Parameter(Mandatory=$true)]
    [string]$gitPath
  )

  $check = git -C $gitPath rev-parse --is-inside-work-tree
  $stdout = $check  | Where-Object { $_ -isnot [System.Management.Automation.ErrorRecord] }

  if ([string]$stdout -eq "true") {
    return "True"
  } else {
    return "False"
  }
}

function checkForUpdatesAndApply {
  Param(
    [Parameter(Mandatory=$true)]
    [string]$gitPath
  )

  $checkForUpdate = git -C $gitPath pull
  $stdout = $checkForUpdate  | Where-Object { $_ -isnot [System.Management.Automation.ErrorRecord] }

  if ([string]$stdout.Contains("Already up to date")) {
    Write-Host "Project is already up to date!" -ForegroundColor Green
    return
  } else {
    Write-Host "Pulling Project updates!" -ForegroundColor Green
  }
}


while($true) {
  $projectRepoExists = checkIfProjectHasGit -gitPath $repoDirectory
  if ($projectRepoExists -eq "True") {
    $checkForCommits = checkStatusAndCommit -gitPath $repoDirectory
    $updateRepo = checkForUpdatesAndApply -gitPath $repoDirectory
  } else {
    Write-Host "There is no git Project in this Folder!" -ForegroundColor Green
  }

  if ($timeout) {
    Start-Sleep -Seconds (60 * $timeout)
  } else {
    Start-Sleep -Seconds 5
  }
}
