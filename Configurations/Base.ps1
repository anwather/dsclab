Configuration Base {

    Node Server {
        File TempFolder {
            DestinationPath = "C:\Temp"
            Ensure = "Present"
            Type = "Directory"
        }
    }
}