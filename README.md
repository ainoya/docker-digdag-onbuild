# docker-digdag-onbuild

docker onbuild image for digdag

# Build onbuild image

```sh
docker build -t digadag:onbuild .
```

# Usage

Dockerfile example:

```Dockerfile
FROM digdag:onbuild

USER root
# for example, you can install another package if you need to run some commands inside digdag container
RUN curl -sL https://deb.nodesource.com/setup_6.x | bash - && \
    apt-get update && apt-get upgrade -y && apt-get install -y --no-install-recommends \
    mysql-client nodejs && \
    apt-get clean && rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*
RUN npm install -g xlsx

USER digdag
```

By default, onbuild image resolve embulk dependencies by execute `embulk bundle` command in `embulk_bundle` directory. (You can modify bundle directory path by setting `EMBULK_BUNDLE_DIR` variable.) 

Example directory layout to use this onbuild image:

```
├── Dockerfile 
├── embulk_bundle
│   ├── embulk
│   │   ├── filter
│   │   ├── input
│   │   └── output
│   ├── Gemfile
│   ├── Gemfile.lock
│   └── jruby
│       └── 2.3.0
├── main.dig
└── tasks
    └── embulk
        ├── embulk config .yml files...
```

And you can run digdag container like commands below:

```sh
# Run digdag server
docker run -p 65432:65432 -d --name digdag-server <image-you-built>

# Otherhands you can also oneshot digdag workflow
docker run -v ${PWD}/main.dig:/home/digdag/main.dig -v ${PWD}/tasks:/home/digdag/tasks -v ${PWD}/../data:/data  --rm  --entrypoint=/bin/sh  <image-you-built> /usr/local/bin/digdag run main.dig
```