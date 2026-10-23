# Upgrading Your Flarum Instance

- [Official Flarum Update Docs](https://docs.flarum.org/update/)

This project gives you full control over your Flarum version by allowing you to rebuild the Docker image with new dependencies.

---

## Applying an Upgrade

Here is the general workflow for upgrading your Flarum instance.

### 1. Set the Version and Check PHP Extensions

1.  **Set the Flarum Version:** In the `.env` file deployed by Ansible, set:

    ```dotenv
    FLARUM_VERSION_TAG=v2.0.2
    ```

    The Dockerfile creates `composer.json` during the build and pins `flarum/core` to `v2.0.2`. You do not need to edit `composer.json` for the bundled extensions. Check third-party extensions against the official upgrade guide before rebuilding.

2.  **Add PHP Extensions (if required):** Add it to the `apk add` list in your `Dockerfile`.

    ```dockerfile
    RUN apk add --no-progress --no-cache \
        # ...
        php84-some-new-extension \
        # ...
    ```

### 2. Rebuild the Docker Image

Back up your database and `volumes/flarum` before rebuilding. Test the upgrade on staging first.

```bash
docker compose build flarum
docker compose up -d --no-deps --force-recreate flarum
```

### 3. Run Post-Upgrade Commands

```bash
# Run Flarum database migrations
docker compose exec flarum php flarum migrate

# Clear the Flarum cache
docker compose exec flarum php flarum cache:clear
```

Your forum is now upgraded.