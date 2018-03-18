
function Get-JsonRequest($url, $jsonBody){

     $jsonrequest =Invoke-WebRequest -Uri $url -Method Post -ContentType application/json -Body $jsonBody
     $checkError = convertfrom-json $jsonrequest.Content
     if($checkError.error_code -ne 0){
        Write-Output $checkError.msg
     }
     else{
            $jsonresponse = ConvertFrom-Json $jsonrequest.Content
            return $jsonresponse
         }
}

function Connect-TPLinkCloud {
   
    $cred=(Get-Credential)
    $passwd = $Cred.GetNetworkCredential().Password
    $user = $cred.UserName
    $termid =  [guid]::NewGuid()
    $url = "https://wap.tplinkcloud.com"
    $login_payload = '{"method":"login","url":"'+$url+'","params": {"appType":"Powershell","cloudPassword":"' + $passwd +'","cloudUserName":"'+ $user+'","terminalUUID":"'+$termid+'"} }'

    $login = get-JsonRequest -url $url -jsonBody $login_payload

    if($login.result.email){
        $token = $login.result.token
        $uri = "https://eu-wap.tplinkcloud.com/?token="+$token

        [Environment]::SetEnvironmentVariable("TPLinkURI", $uri, "Process")
        
    }
    else{
        "Web Request failed, try again."
        $jsonresponse
    }
}
                                              
function Get-TPLinkDevice {
    #Parameters
    Param(
    [parameter(Mandatory=$false)]
    [String]
    $alias
    )
    #Json Body Build
    $getDevicesList = '{"method":"getDeviceList"}'
    $uri = [environment]::GetEnvironmentVariable("TPLinkURI", "Process")

    # get Json Request
    $deviceList = get-JsonRequest -url $uri -jsonBody $getDevicesList
    $devices = $deviceList.result.deviceList
    
    #filter by parameter     
    if($alias){
        $device = $devices | Where-Object {$_.alias -eq $alias}
        return $device
    }
    else {
        return $devices
    }    

}

function Set-TPLinkDevice {
    #Parameters
    Param(
    [parameter(Mandatory=$True)]
    [String]
    $deviceId,
    [parameter(Mandatory=$True, ParameterSetName = 'ON')]
    [Switch]
    $on,
    [parameter(Mandatory=$True, ParameterSetName = 'OFF')]
    [Switch]
    $off
    )
    $uri = [environment]::GetEnvironmentVariable("TPLinkURI", "Process")
    if($deviceId){
        #Json Body Build
        If($on){
            $setDevice=  '{"method":"passthrough","params": {"deviceId": "'+$deviceid+'","requestData": "{\"system\":{\"set_relay_state\":{\"state\":1}}}" }}'
        }
        If($off){
            $setDevice= '{"method":"passthrough","params": {"deviceId": "'+$deviceid+'","requestData": "{\"system\":{\"set_relay_state\":{\"state\":0}}}" }}'
         
        }
        # get Json Request 
        $jsonrequest = Invoke-WebRequest -Uri $uri -Method Post -ContentType application/json -Body $setDevice
        $jsonresponse = ConvertFrom-Json $jsonrequest
        
        
        if($jsonresponse.error_code -eq 0) {
            if($on){
                Write-Host $device.alias "ON" #### TO FIX
            }
            if($off){
                Write-Host $device.alias "OFF" #### TO FIX
            }
        }
    }    
}

function Get-TPLinkDeviceStatus{
 Param(
    [parameter(Mandatory=$True)]
    [String]
    $deviceId
    )
    $uri = [environment]::GetEnvironmentVariable("TPLinkURI", "Process")
    if($deviceId){
        #Json Body Build
        $sysinfo = '{"method":"passthrough","params": {"deviceId":"'+$deviceId+'","requestData":"{\"system\":{\"get_sysinfo\":null}}" }}'
  
        # get Json Request 
        $deviceInfo = get-JsonRequest -url $uri -jsonBody $sysinfo
        
        $deviceSysInfo = convertfrom-json $deviceInfo.result.responseData
        $deviceStatus = $deviceSysInfo.system.get_sysinfo.relay_state

        switch ($deviceStatus){
            0 {write-host $deviceSysInfo.system.get_sysinfo.alias "is OFF"}
            1 {write-host $deviceSysInfo.system.get_sysinfo.alias "is ON"}
        }
    }
}

function Get-TPLinkDeviceSysInfo{
    Param(
       [parameter(Mandatory=$True)]
       [String]
       $deviceId
       )
       $uri = [environment]::GetEnvironmentVariable("TPLinkURI", "Process")
       if($deviceId){
           #Json Body Build
           $sysinfo = '{"method":"passthrough","params": {"deviceId":"'+$deviceId+'","requestData":"{\"system\":{\"get_sysinfo\":null}}" }}'
     
           # get Json Request 
           $deviceInfo = get-JsonRequest -url $uri -jsonBody $sysinfo
           
           $deviceSysInfo = convertfrom-json $deviceInfo.result.responseData
           return $deviceSysInfo.system.get_sysinfo
        }
       
   }

function Get-TPLinkDeviceStatistics{
    Param(
       [parameter(Mandatory=$True,position=1)]
       [String]
       $DeviceId,
       [parameter(Mandatory=$True,position=2, ParameterSetName = 'Daily')]
       [Switch]
       $Daily,
       [parameter(Mandatory=$True, ParameterSetName = 'Monthly')]
       [Switch]
       $Monthly,
       [parameter(Mandatory=$True, ParameterSetName = 'Daily')]
       [int]
       $Month,
       [parameter(Mandatory=$True)]
       [int]
       $Year
    )
    $uri = [environment]::GetEnvironmentVariable("TPLinkURI", "Process")

    if($deviceId){
        if($daily){
            $emeterd = '{"method":"passthrough","params": {"deviceId": "'+$deviceId+'","requestData":"{\"emeter\":{\"get_daystat\":{\"month\":'+$month+',\"year\":'+$year+'}}}" }}'
            $deviceStats = get-JsonRequest -url $uri -jsonBody $emeterd
            $deviceDstats = convertfrom-json $deviceStats.result.responseData
            $dailyList = $deviceDstats.emeter.get_daystat.day_list
            return $dailyList
        }   
        if($monthly){
            $emeterm = '{"method":"passthrough","params": {"deviceId": "'+$deviceId+'","requestData":"{\"emeter\":{\"get_monthstat\":{\"year\":'+$year+'}}}" }}'
            $deviceStats = get-JsonRequest -url $uri -jsonBody $emeterm
            $deviceMStats = convertfrom-json $deviceStats.result.responseData
            $monthlyList = $deviceMstats.emeter.get_monthstat.month_list
            return $monthlyList       
        }   
    }
}
   
   function Get-TPLinkDeviceRealTime{
    Param(
       [parameter(Mandatory=$True)]
       [String]
       $deviceId
       )
       $uri = [environment]::GetEnvironmentVariable("TPLinkURI", "Process")
       if($deviceId){
           #Json Body Build
           $jsonBody = '{"method":"passthrough","params":  {"deviceId":"'+$deviceId+'","requestData":"{\"emeter\":{\"get_realtime\":null}}" }}'
     
           # get Json Request 
           $jsonResponse = get-JsonRequest -url $uri -jsonBody $jsonBody
           
           $deviceEmeter = convertfrom-json $jsonResponse.result.responseData

           $reading =  $deviceEmeter.emeter.get_realtime |select-object current,voltage,power,total 
           return $reading
       }       
   }

   function Get-TPLinkDeviceSchedule{
    Param(
       [parameter(Mandatory=$True)]
       [String]
       $deviceId
       )
       $uri = [environment]::GetEnvironmentVariable("TPLinkURI", "Process")
       if($deviceId){
           #Json Body Build
           $jsonBody = '{"method":"passthrough","params": {"deviceId": "'+$deviceId+'","requestData":"{\"schedule\":{\"get_rules\":null}}" }}'
     
           # get Json Request 
           $jsonResponse = get-JsonRequest -url $uri -jsonBody $jsonBody
           
           $deviceSchedule = convertfrom-json $jsonResponse.result.responseData

           $scheduleRules =  $deviceSchedule.schedule.get_rules.rule_list 
           return $scheduleRules
       }       
   }

function Export-TPLinkDeviceStatistics{
    Param(
    [parameter(Mandatory=$True)]
    [String]
    $deviceId
    )
    
    if($deviceId){
        Get-TPLinkDeviceSysInfo -deviceId $deviceId | ConvertTo-Json | out-file sysinfo.json
        
        Get-TPLinkDeviceRealTime -deviceId $deviceId| ConvertTo-Json | out-file RealTime.json

        $currentDate = Get-Date

        # get monthly
        $i=0
        Do {
            $mStats = Get-TPLinkDeviceStatistics -DeviceId $deviceId -Monthly -Year $currentDate.AddYears($i).Year 
            $totalMStats = $totalMStats + $mStats
            $i--
            $empty = $false
            
            if($mStats.count -like 0){
                $empty = $True
            }
        }until ($empty -like $True)
   
        $totalMStats | ConvertTo-Json|  out-file .\MonthlyStats.json

        # get Daily
        $i=0
        Do {
            for ($m = 12; $m -gt 0; $m--) {
                $dStats = Get-TPLinkDeviceStatistics -DeviceId $deviceId -Daily -Month $m -Year $currentDate.AddYears($i).Year 
                $totaldStats = $totaldStats + $dStats
            }
            $empty = $false
            $i--
            if($dStats.count -like 0){
                $empty = $True
            }
        }until ($empty -like $True)
        
   
        $totaldStats | ConvertTo-Json|  out-file .\DailyStats.json
    
    }
}
Export-ModuleMember -Function Get-TPLinkDevice, Get-TPLinkDeviceStatistics, Get-TPLinkDeviceStatus, Get-TPLinkDeviceSysInfo, Get-TPLinkDeviceRealTime, Get-TPLinkDeviceSchedule, Set-TPLinkDevice, Connect-TPLinkCloud, Export-TPLinkDeviceStatistics

 



##### Commands #####

#$off= '{"method":"passthrough","params": {"deviceId": "'+$device.deviceid+'","requestData": "{\"system\":{\"set_relay_state\":{\"state\":0}}}" }}'

#$on=  '{"method":"passthrough","params": {"deviceId": "'+$device.deviceid+'","requestData": "{\"system\":{\"set_relay_state\":{\"state\":1}}}" }}'

#$sysinfo = '{"method":"passthrough","params": {"deviceId":"'+$device.deviceId+'","requestData":"{\"system\":{\"get_sysinfo\":null},\"emeter\":{\"get_realtime\":null},\"time\":{\"get_time\":null}}" }}'
                                                                                         #     "{\"system\":{\"get_sysinfo\":null},\"emeter\":{\"get_realtime\":null}}"
                                                                                
#$emeter = '{"method":"passthrough","params":  {"deviceId":"'+$device.deviceId+'","requestData":"{\"emeter\":{\"get_realtime\":null}}" }}'

#$emeterd = '{"method":"passthrough","params": {"deviceId": "'+$device.deviceId+'","requestData":"{\"emeter\":{\"get_daystat\":{\"month\":6,\"year\":2017}}}" }}'
                                                                                                                                
#$emeterm = '{"method":"passthrough","params": {"deviceId": "'+$device.deviceId+'","requestData":"{\"emeter\":{\"get_monthstat\":{\"year\":2017}}}" }}'
                                                                                                                                
#$emeterreset = '{"method":"passthrough","params": {"deviceId": "'+$device.deviceId+'","requestData":"{\"emeter\":{\"erase_emeter_stat\":null}}" }}'

#$emetercalib = '{"method":"passthrough","params": {"deviceId": "'+$device.deviceId+'","requestData":"{\"emeter\":{\"get_vgain_igain\":null}}" }}'

#$getSchedule ='{"method":"passthrough","params": {"deviceId": "'+$device.deviceId+'","requestData":"{\"schedule\":{\"get_rules\":null}}" }}'