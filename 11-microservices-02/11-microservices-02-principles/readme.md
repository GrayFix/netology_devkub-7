# Как запускать
После написания nginx.conf для запуска выполните команду
```
docker-compose up --build -d
```

# Как тестировать

## Login
Получить токен
```
curl -X POST -H 'Content-Type: application/json' -d '{"login":"bob", "password":"qwe123"}' http://localhost/v1/token
```
Пример
```
$ curl -X POST -H 'Content-Type: application/json' -d '{"login":"bob", "password":"qwe123"}' http://localhost/v1/token
eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJib2IifQ.hiMVLmssoTsy1MqbmIoviDeFPvo-nCd92d4UFiN2O2I
```

## Test
Использовать полученный токен для загрузки картинки
```
curl -X POST -H 'Authorization: Bearer <TODO: INSERT TOKEN>' -H 'Content-Type: octet/stream' --data-binary @1.jpg http://localhost/v1/upload
```
Пример
```
$ curl -X POST -H 'Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJzdWIiOiJib2IifQ.hiMVLmssoTsy1MqbmIoviDeFPvo-nCd92d4UFiN2O2I' -H 'Content-Type: octet/stream' --data-binary @1.jpg http://localhost/v1/upload
{"filename":"c31e9789-3fab-4689-aa67-e7ac2684fb0e.jpg"}
```

 ## Проверить
Загрузить картинку и проверить что она открывается
```
curl localhost/v1/user/<filnename> > <filnename>
```
Example
```
$ curl localhost/v1/user/c31e9789-3fab-4689-aa67-e7ac2684fb0e.jpg > c31e9789-3fab-4689-aa67-e7ac2684fb0e.jpg
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100 13027  100 13027    0     0   706k      0 --:--:-- --:--:-- --:--:--  748k

$ ls
c31e9789-3fab-4689-aa67-e7ac2684fb0e.jpg
```