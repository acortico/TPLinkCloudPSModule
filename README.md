# TPLinkCloudPSModule
Powershell Module to interact with TPLink Cloud API

# Introduction
With this Powershell module you are able to intereactive with your TPLink Cloud Account, 
allowing you to control your TP Link Smart devices also to retrive your energy consumption 
historic

# Getting Started

1.	Import Module
    a. Open Powershell and import the Module
        Import-module .\TPLinkCloud.psm1
2.	Connect to TP-Link Cloud
    use the cmdlt:
    Connect-TPLinkCloud
    You will be prompt for Username and Password.
    
# TPLinkCloudPSModule Functions

1.  Connect-TPLinkCloud -
    Connect your powershell session to TP-Link Cloud API

2.  Get-TPLinkDevice - 
    Retrives the list of devices on your account.
    
3.  Set-TPLinkDevice - 
    Allows you to trun on or off a device:

    Set-TPLinkDevice -deviceId <string> -on 
    Set-TPLinkDevice -deviceId <string> -off 
 
4.  Get-TPLinkDeviceStatus - 
    Returns the current status of the device ON/OFF

    Get-TPLinkDeviceStatus [-deviceId] <string>
    
5.  Get-TPLinkDeviceSysInfo - 
    Returns device system information.
    
    Get-TPLinkDeviceSysInfo [-deviceId] <string>
    
6.  Get-TPLinkDeviceStatistics - 
    Returns your device energy meter stats.
    
    For daily stats: 
    Get-TPLinkDeviceStatistics [-DeviceId] <string> [-Daily] -Month <int> -Year <int>
    
    For monthly stats: 
    Get-TPLinkDeviceStatistics [-DeviceId] <string> -Monthly -Year <int>
    
7.  Get-TPLinkDeviceRealTime - 
    Returns device real time energy consumption
    
    Get-TPLinkDeviceRealTime [-deviceId] <string>

8.  Get-TPLinkDeviceSchedule - 
    Returns the device schedule plan
    
    Get-TPLinkDeviceSchedule [-deviceId] <string>
    
9.  Export-TPLinkDeviceStatistics - 
    Exports all statistics in JSON format
    
    Export-TPLinkDeviceStatistics [-deviceId] <string>
