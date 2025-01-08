using module .\Remote.psm1
using module .\Dotenv.psm1

function Main($remoteFile) {
    $localDir = ConstructLocalDir
    GenerateDir $localDir

    $fileServer = [S3]::new()
    $fileServer.Download($remoteFile, $localDir)
}

function ConstructLocalDir() {    
    if ([System.IO.Path]::IsPathRooted($env:LOCAL_DIR)) {
        $tmpDir = $env:LOCAL_DIR
    } else {
        $rootDir = Join-Path $PSScriptRoot '..'
        $tmpDir = Join-Path $rootDir $env:LOCAL_DIR
    }

    return Join-Path $tmpDir (Get-Date).ToString('yyyyMMddHHmmss')
}

function GenerateDir($directory) {
    if (-not (Test-Path $directory)) {
        New-Item -Path $directory -ItemType Directory -Force | Out-Null
    }    
}    

if ($MyInvocation.InvocationName -ne '.') {
    Set-DotEnv -envFile (Join-Path $PSScriptRoot '../.env')
    Main -remoteFile $args[0]
}
