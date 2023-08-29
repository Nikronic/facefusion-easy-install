# functions used thoroughout the script

# refresh Path so no need to close and reopen the shell
# stolen from https://stackoverflow.com/a/71415530/7606121
function RefreshShell {
    $env:PATH = [Environment]::GetEnvironmentVariable('Path', 'Machine'),
                [Environment]::GetEnvironmentVariable('Path', 'User') -join ';'  
}

# install WinGet
# code is stolen from https://learn.microsoft.com/en-us/windows/package-manager/winget/#install-winget-on-windows-sandbox
$progressPreference = 'silentlyContinue'
Write-Host "Downloading WinGet and its dependencies..."
Invoke-WebRequest -Uri https://aka.ms/getwinget -OutFile Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle
Invoke-WebRequest -Uri https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx -OutFile Microsoft.VCLibs.x64.14.00.Desktop.appx
Invoke-WebRequest -Uri https://github.com/microsoft/microsoft-ui-xaml/releases/download/v2.7.3/Microsoft.UI.Xaml.2.7.x64.appx -OutFile Microsoft.UI.Xaml.2.7.x64.appx
Add-AppxPackage Microsoft.VCLibs.x64.14.00.Desktop.appx
Add-AppxPackage Microsoft.UI.Xaml.2.7.x64.appx
Add-AppxPackage Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle
Write-Host "WinGet installation succeeded!"
# ---

# install Visual C++ 2015 Redistributable
Write-Host "Install Visual C++ 2015 Redistributable..."
winget install --silent --wait -e --id Microsoft.VCRedist.2015+.x64
# refresh Path
RefreshShell
Write-Host "Visual C++ 2015 Redistributable installation succeeded!"
# ---

# install Visual Studio 2022 build tools
Write-Host "Install Visual Studio 2022 build tools..."
# we install these workloads silently by overriding VS command line interface
# https://learn.microsoft.com/en-us/visualstudio/install/use-command-line-parameters-to-install-visual-studio?view=vs-2022#use-winget-to-install-or-modify-visual-studio
# for the BuildTools, we use components from here https://learn.microsoft.com/en-us/visualstudio/install/workload-component-id-vs-build-tools?view=vs-2022&preserve-view=true
winget install --silent --wait -e --id Microsoft.VisualStudio.2022.BuildTools --override "--wait --quiet --installWhileDownloading --config .vsconfig"
# refresh Path
RefreshShell
Write-Host "Visual Studio 2022 build tools installation succeeded!"
# ---

# install Python 3.10
Write-Host "Installing Python 3.10..."
winget install --silent --wait -e --id Python.Python.3.10
# refresh Path
RefreshShell
$python_version = python --version
if ($python_version -like "Python 3.10.*.")
{
    Write-Host "Python version {0} installation succeeded!" -f $python_version
}
# ---

# install Git
Write-Host "Install Git to access source codes..."
winget install --silent --wait -e --id Git.Git
# refresh Path
RefreshShell
$git_version = git --version
if ($git_version -like "git version 2.*.")
{
    Write-Host "Git version {0} installation succeeded!" -f $git_version
}
# ---

# install FFmpeg
Write-Host "Install FFmpeg..."
winget install --silent --wait -e --id Gyan.FFmpeg
# refresh Path
RefreshShell
$ffmpeg_version = (ffmpeg -version)[0].Substring(0, 18)
if ($ffmpeg_version -like "ffmpeg version 6.*.")
{
    Write-Host "FFmpeg version {0} installation succeeded!" -f $ffmpeg_version
}
# ---

# clone the source code of facefusion
Write-Host "Clone the source code of facefusion..."
git clone https://github.com/Nikronic/facefusion-easy-install.git
Write-Host "Code clone succeeded!"
# --

# create a virtual environment
Write-Host "Create a Python virtual environment..."
cd facefusion-easy-install
python -m venv venv
Set-ExecutionPolicy RemoteSigned -Force  # allow running scripts
.\venv\Scripts\activate  # activate virtual env
# check if the environment is activated
$is_venv_activated = (Get-Command python).Source -like "*facefusion*"
if ($is_venv_activated)
{
    Write-Host "Python virtual environment activation succeeded!"
}
# ---

# install python packages and dependencies
Write-Host "Install pyton packages and dependencies. This might take few mins given your connection speed..."
# update pip
python.exe -m pip install --upgrade pip
# install dependencies
pip install -r requirements.txt
Write-Host "Python dependency installation succeeded!"

[Console]::ReadKey()
