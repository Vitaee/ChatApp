# Setup

- Install requirements with pip.
```
cd api_app

cd app

pip install -r requirements.txt
```

- Simply run the api like this.

```
python main.py
```

# Config file

- Find project config file from here.

```
cd api_app

cd app

cd core

ls

```
- If you face any issue edit this file according to your config.

# Setup MongoDB via Docker
- If you don't have docker you can install it from [here](https://docs.docker.com/get-docker/).
- Firstly, run this command to create and start your db  ```docker run --name some-mongo -p 27017:27017 -d mongo ```.
- Check your container via ```docker ps``` this will return a container ID (the first 12 characters from the hash), the image name (in this case, mongo), command, created, status, ports and the name of the container (some-mongo).
- If you want you can also install [MongoDB Compass](https://www.mongodb.com/products/compass)
- If you using <b>MongoDB Compass</b> you can connect your virtual db with this url. ``` mongodb://0.0.0.0:27017/?readPreference=primary&appname=MongoDB%20Compass&ssl=false ```.
- If you can't connect check your ip adress via this command. ``` docker inspect some-mongo```
- It will return a dict. Then you should find key which name is ```IPAddress``` just copy and paste the value into connection url. In this case replace with ``` 0.0.0.0 ```.

