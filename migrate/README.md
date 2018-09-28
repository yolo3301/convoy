## Migrate container images between registries

### Migrate via Skopeo in a k8s cluster

#### Define images to migrate

Modify the `images.yaml` file to contain a list of the images in your source registry.
Notice the images should be the **name pattern** you want to keep in the destination registry.

E.g. if your source image is `gcr.io/my-project/path/to/img:tag` and if you want to keep
`path/to/img:tag` in the destination registry, then use `path/to/img:tag`. But if you want
just `img:tag`, then use `img:tag` in the file.

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: image-list
data:
  images: |
    ubuntu:latest
    alpine:latest
```

Create a ConfigMap.

```shell
kubectl apply -f images.yaml
```

#### Prepare registry credentials

Modify `secrets.yaml`.
Replace `{{SRC_USER}}` and `{{SRC_PWD}}` with your source registry credentials.
Replace `{{DEST_USER}}` and `{{DEST_PWD}}` with your destination registry credentials.

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: src-reg-secret
type: Opaque
data:
  username: {{SRC_USER}}
  password: {{SRC_PWD}}

---
apiVersion: v1
kind: Secret
metadata:
  name: dest-reg-secret
type: Opaque
data:
  username: {{DEST_USER}}
  password: {{DEST_PWD}}
```

Create the secrets.

```shell
kubectl apply -f secrets.yaml
```

#### Start the image migration job

Replace `{{SRC_PREFIX}}` and `{{DEST_PREFIX}}` with the prefix you want. These prefix
should at least contain the registry server.

E.g. if you define your image in `images.yaml` as `path/to/img:tag` and `{{SRC_PREFIX}}=gcr.io/my-project`,
then the full image name will be `gcr.io/my-project/path/to/img:tag`. Similarly for `{{DEST_PREFIX}}`.

Create a pod to run the job.

```shell
kubectl apply -f job.yaml
```

Checking the logs.

```shell
kubectl logs img-migrate -f
```

#### Leverage k8s

You can leverage k8s to schedule multiple pods to migrate images in parallel. Make sure
to given distinct names for ConfigMap and Pod.

You can also set up k8s [CronJob](https://kubernetes.io/docs/tasks/job/automated-tasks-with-cron-jobs/)
to keep images in sync between source and destination registry.


### Migrate locally

If you have [Skopeo](https://github.com/containers/skopeo) installed locally, you can leverage
`migrate.sh` to do the same. Just make sure all required environment variables are set.

If you have docker client installed and configured to talk to your registries, you don't have to
specify the credentials when using Skopeo.

And of course, you can always use docker client.

```shell
docker pull ${SRC_REPO}/${IMAGE} &&
docker tag ${SRC_REPO}/${IMAGE} ${DEST_REPO}/${IMAGE} &&
docker push ${DEST_REPO}/${IMAGE}
```
However, this will download a bunch of images to your local machine. If you have a lot of images,
there might be a problem.
