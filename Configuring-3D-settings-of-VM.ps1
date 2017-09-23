#Author : Jyothsna Terli
#Product : vSphere/VM Video Card 3D settings.


function Set-VMVideoCard3D  {
<# .Synopsis  This changes the 3d and swRendering settings of the VM to enable and disable the 3D support.
#>

[CmdletBinding()]
Param (
   [parameter(Mandatory = $true, valuefrompipeline = $true, HelpMessage = "Enter a VM info")]
   [VMware.VimAutomation.ViCore.Impl.V1.Inventory.VirtualMachineImpl]$VM,
   [parameter(Mandatory = $true, valuefrompipeline = $true, HelpMessage = "Enter True to enable and False to disable 3D support")]
   [String]$Enable,
   [parameter(Mandatory = $false, valuefrompipeline = $true, HelpMessage = "The valid entries for3D rendering are Automatic, Hardware, Software")]
   [String]$SwRenderer
     )


Process {
Write-Host "Verify that the VM is powered off."
$VM  | foreach {
if ($_.PowerState -eq "PoweredOff")
{ 
  $vm_view = $_ | Get-View 
  if  ($vm_view.Guest.ToolsStatus -ne "toolsNotInstalled") 
   {
      $videoCard = $_.ExtensionData.Config.Hardware.Device | Where {$_.GetType().Name -eq "VirtualMachineVideoCard"}
      $spec = New-Object VMware.Vim.VirtualMachineConfigSpec
      $Config = New-Object VMware.Vim.VirtualDeviceConfigSpec
  $Config.Device = $videoCard
    if ($Enable -eq "True") {
         $Config.Device.Enable3DSupport = $true
      } else { 
         $Config.Device.Enable3DSupport = $false
      }
   
   if ($SwRenderer) {
         $Config.Device.Use3dRenderer = $SwRenderer
     } 
   $Config.Operation = "edit"
   $spec.DeviceChange += $Config
   Write-Host "Changing the 3d settings of the video card"
   $vm_view.ReconfigVM($spec)
} else {
         Write-Host "Skipping the Operation since tools are not installed"
       }
} else {
         Write-Host "This Operation is not supported in powered on state"
       }
}
}
}


# Getting help for the command Usage
#Get-Help -Full Set-VMVideoCard3D

# Provide the name of the Server and VM on which 3D needs to be enabled

$cluster_name = Read-Host -Prompt 'Input your cluster name:'
$server_name = Read-Host -Prompt 'Input your server name:'
$vm_name = Read-Host -Prompt 'Input your VM name:'


#############  Ebabling/disabling  the 3D Support ######################

#Get-VM -Name $vm_name | Set-VMVideoCard3D -Enable False 


###########  Enabling and setting the 3D Rendering #################
Get-VM -Name $vm_name | Set-VMVideoCard3D -Enable True -SwRenderer "Software"

#############  Enabling and setting the 3D rederer for all VMs on the host#########
#Get-VMHost -Name $server_name | Get-VM | Set-VMVideoCard3D -Enable True -SwRenderer "Software"

#############  Enabling and setting the 3D rederer for all VMs on the cluster #########

#Get-Cluster -Name $cluster_name | Get-VM | Set-VMVideoCard3D -Enable True -SwRenderer "Software"




###############   Printing the properties of Video Card #######################
#$vm.ExtensionData.Config.Hardware.Device | Where {$_.GetType().Name -eq "VirtualMachineVideoCard"}


 
