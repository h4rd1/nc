docker exec -u www-data app-server php occ --no-warnings config:system:get trusted_domains > trusted_domain.tmp

findstr /C:"nginx-server" trusted_domain.tmp > nul
if %errorlevel% neq 0 (
    for /f %%a in ('type trusted_domain.tmp ^| find /C /V ""') do set TRUSTED_INDEX=%%a
    docker exec -u www-data app-server php occ --no-warnings config:system:set trusted_domains %TRUSTED_INDEX% --value="nginx-server"
)

del trusted_domain.tmp

docker exec -u www-data app-server php occ --no-warnings app:install onlyoffice

docker exec -u www-data app-server php occ --no-warnings config:system:set onlyoffice DocumentServerUrl --value="/ds-vpath/"
docker exec -u www-data app-server php occ --no-warnings config:system:set onlyoffice DocumentServerInternalUrl --value="http://onlyoffice-document-server/"
docker exec -u www-data app-server php occ --no-warnings config:system:set onlyoffice StorageUrl --value="http://nginx-server/"
docker exec -u www-data app-server php occ --no-warnings config:system:set onlyoffice jwt_secret --value="secret"
