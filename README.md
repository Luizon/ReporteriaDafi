# Sistema de reportería básico

Este sistema permite generar y visualizar reportes desde una aplicación móvil, y administrar usuarios y reportes de usuarios desde la web.

## Tecnologías

Backend: ASP.NET Core
Frontend (web): Blazor
Frontend (mobile): Flutter

## Ambientación

Versión de desarrollo
**.Net 8 SDK** para Backend y web
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

Instala dependencia para Firebase en el API

    dotnet add package Google.Apis.Auth
    dotnet add package Google.Apis.FirebaseCloudMessaging.v1

Con esto ya puedes ejecutar el servidor y la web usando estos comandos en la carpeta raíz

    dotnet run --project ReportesApi
    dotnet run --project ReportesAdmin

Una vez corriendo el servidor, puedes revisar los endpoints directamente en el Swagger

    https://localhost:7212/swagger

Y puedes visitar la página de admin entrando a la raíz o al /login

    https://localhost:7017/login

Pero Android y iOS no confían en certificados SSL si no son de fuentes confiables como Lets Encrypt, para probar la app primero tuneliza el API y desde la app consume al tunel, no a localhost. Usa el dominio que ngrok te regala en tu cuenta, para no estar cambiando url a cada que abras un tunel
    
    ngrok http --domain=besiegingly-pseudopolitical-lenita.ngrok-free.dev 5274

### Flutter

Se sugiere correr flutter doctor para asegurar que todo esté en orden con el ambiente flutter

Ambienta la máquina para firebase

    dart pub global activate flutterfire_cli
    flutterfire configure

flutterfire configure configurará el proyecto para las plataformas soportadas por tu app, en este caso se debe seleccionar ios y android. Si tu cuenta de firebase tiene más de un proyecto entonces flutterfire configure te mostrará una lista de ellos, selecciona el proyecto correspondiente a la app

    flutter clean
    flutter pub get

Luego, puedes ejecutar el sistema

    flutter run

o construirlo directamente

    flutter build apk --split-per-abi

## Notas

Esta aplicación maneja base de datos SQLite generada en el proyecto del API para ASP.NET por conveniencia para pruebas en múltiples plataformas, pero una mejor práctica sería realizar una configuración con SQL Server y persistir esta base de datos de forma independiente al API. Si realizas un fork de este proyecto, sugiero modificar la configuración de base de datos a algo más robusto, seguro y escalable.

El API tiene el secret para generar los JWT en appsettings.json y este archivo por conveniencia de pruebas no está siendo ignorado en este repositorio, pero esto es una terrible practica por temas de seguridad. Si haces un fork de este proyecto, modifica esta configuración para empezar a esconder appsettings.json o aplica un nuevo archivo secrets.json/.env que no sea versionado en git.