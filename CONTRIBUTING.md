## Build the image

```
docker build --platform linux/amd64 -f build.Dockerfile -t qvdk/prolamb4j:latest .
```

## Run bash in the container

```
docker run -ti --entrypoint bash qvdk/prolamb4j:latest
```
