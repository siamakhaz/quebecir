FROM mcr.microsoft.com/powershell
#COPY YMCA-badminton1.ps1 YMCA-badminton1.ps1
RUN pwsh -Command "Install-Module -Name PoshGram -RequiredVersion 2.0.0 -AllowClobber -Force"
RUN mkdir /app
WORKDIR /app
CMD ["pwsh", "-File", "send-daily-quebecir.ps1"]