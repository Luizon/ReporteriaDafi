# Sistema de reportería básico

Este sistema permite generar y visualizar reportes desde una aplicación móvil, y administrar usuarios y reportes de usuarios desde la web.

## Tecnologías

Backend: ASP.NET Core
Frontend (web): Blazor
Frontend (mobile): Flutter

## Ambientación

Versión de desarrollo
**.Net 8.0.418** para Backend y web
**Flutter 3.3x** para mobile


### Blazor y ASP.NET

Limpia y obten las dependencias antes de ejecutar los proyectos:

    cd ReportesApi
    dotnet clean
    dotnet restore
    dotnet build
    cd ../ReportesAdmin
    dotnet clean
    dotnet restore
    dotnet build

Instala Entity Framework con una versión acorde al .NET utilizado

    dotnet tool install --global dotnet-ef --version 8.0.8

Genera la base de datos

    cd ReportesApi
    dotnet ef migrations add NewMigrations
    dotnet ef database update

Genera el certificado de https para ambos proyectos

    dotnet dev-certs https --trust

Con esto ya puedes ejecutar el servidor y la web usando estos comandos en la carpeta raíz

    dotnet run --project ReportesApi
    dotnet run --project ReportesAdmin

Una vez corriendo el servidor, puedes revisar los endpoints directamente en el Swagger

    https://localhost:7212/swagger

Y puedes visitar la página de admin entrando a la raíz o al /login

    https://localhost:7017/login

### Flutter

Con Flutter es más simple aún, si ya tienes Flutter ambientado en tu máquina (con todos los checks de **flutter doctor** en verde) solo limpia las dependencias y descargalas nuevamente

    flutter clean
    flutter pub get

Luego, puedes ejecutar el sistema

    flutter run

o construirlo directamente

    flutter build apk --split-per-abi

## Notas

Esta aplicación maneja base de datos SQLite generada en el proyecto del API para ASP.NET por conveniencia para pruebas en múltiples plataformas, pero una mejor práctica sería realizar una configuración con SQL Server y persistir esta base de datos de forma independiente al API. Si realizas un fork de este proyecto, sugiero modificar la configuración de base de datos a algo más robusto, seguro y escalable.

El API tiene el secret para generar los JWT en appsettings.json y este archivo por conveniencia de pruebas no está siendo ignorado en este repositorio, pero esto es una terrible practica por temas de seguridad. Si haces un fork de este proyecto, modifica esta configuración para empezar a esconder appsettings.json o aplica un nuevo archivo secrets.json/.env que no sea versionado en git.