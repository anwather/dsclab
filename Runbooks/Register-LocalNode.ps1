Param(
    $EndpointURL,
    $RegistrationKey,
    $NodeName,
    $Configuration
)

[DscLocalConfigurationManager()]
Configuration LCM {
    Param($EndpointURL, $RegistrationKey, $Nodename, $Configuration)

    Node $Nodename {
        Settings {
            RefreshMode        = "Pull"
            RebootNodeIfNeeded = "False"
        }

        ConfigurationRepositoryWeb Web01 {
            ServerURL          = $EndpointURL
            RegistrationKey    = $RegistrationKey
            ConfigurationNames = $Configuration
        }

        ReportServerWeb RP1 {
            ServerURL       = $EndpointURL
            RegistrationKey = $RegistrationKey
        }
    }
}

$params = @{
    EndpointURL     = $EndpointURL
    RegistrationKey = $RegistrationKey
    NodeName        = $NodeName
    Configuration   = $Configuration
}

LCM @params
Set-DscLocalConfigurationManager -Path .\LCM -Verbose -Force