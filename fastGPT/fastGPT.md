fastGPT

准备docker环境（`docker-compose`版本最好在2.17以上）

```shell
安装 Docker

curl -fsSL https://get.docker.com | bash -s docker --mirror Aliyun
systemctl enable --now docker

# 安装 docker-compose

sudo curl -L https://github.com/docker/compose/releases/download/v2.29.1/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# 验证安装

docker -v
docker-compose -v
```



安装oneapi

[OneAPI](https://link.zhihu.com/?target=https%3A//github.com/songquanpeng/one-api) 是一个 API 管理和分发系统，支持几乎所有主流 API 服务。OneAPI 通过简单的配置**允许使用一个 API 密钥调用不同的服务**，实现服务的高效管理和分发。类似开源项目还有 [AI GateWay](https://link.zhihu.com/?target=https%3A//github.com/Portkey-AI/gateway) 或 [LiteLLM](https://link.zhihu.com/?target=https%3A//github.com/BerriAI/litellm)等

```
 git clone https://github.com/songquanpeng/one-api.git
 cd one-api/web/default/
 npm i
 npm run build
cd ../..

wget https://mirrors.aliyun.com/golang/go1.22.4.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.22.4.linux-amd64.tar.gz
echo "export GOROOT=/usr/local/go" >> ~/.bashrc
echo "export PATH=$PATH:$GOROOT/bin" >> ~/.bashrc
source ~/.bashrc
go version

export GOPROXY=https://mirrors.aliyun.com/goproxy/
go mod download
go build -ldflags "-s -w" -o one-api

chmod u+x one-api
./one-api --port 3001 --log-dir ./logs

```

访问 http://localhost:3001/ 并登录。初始账号用户名为 `root`，密码为 `123456`,首次登录更改密码。

配置渠道：

配置qwen2大模型：类型选择OpenAI,名称ollama，分组默认default，模型输入：qwen2:7b点填入，密码随便输入ollama，代理输入ollama地址http://localhost:11434，提交后，点渠道，点测试，测试连通性



创建key：

名称输入ollama，模型范围输入qwen2:7b和m3e，过期时间设置永不过期，设置无限额度，提交后点令牌，点复制就可以得到一个ollama的访问key，如：sk-n9cG3pjWkpg6Qt6XFe70De3dDe4a47Cc8157B462514226Af

LiteLLM

```
git clone https://github.com/BerriAI/litellm

cd litellm

echo 'LITELLM_MASTER_KEY="sk-1234"' > .env
echo 'LITELLM_SALT_KEY="sk-1234"' > .env

source .env

docker-compose up
```

oneapi如需nginx代理：

```
server {
    listen 80;
    server_name one-api.example.com;
    location /{
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        # 流式
        chunked_transfer_encoding off;
        proxy_buffering off;
        proxy_cache off;
        # 设置等待响应的时长
        proxy_read_timeout          300;
        # proxy_connect_timeout       300;
        # proxy_send_timeout          300;
        # send_timeout                300;
    }
}

```

反向代理用于 OpenAI, Gemini, Claude 等限制国内 IP 访问的服务。以 Gemini 为例，在支持访问的服务器上配置 Nginx：

```
server {
   listen 80;
   server_name your.domain.com;
   location / {
        proxy_pass https://generativelanguage.googleapis.com;
        proxy_set_header Host generativelanguage.googleapis.com;
        proxy_ssl_server_name on;
        proxy_set_header Connection '';
        proxy_http_version 1.1;
        chunked_transfer_encoding off;
        proxy_buffering off;
        proxy_cache off;
        proxy_set_header X-Forwarded-For $remote_addr;
        proxy_set_header X-Forwarded-Proto $scheme;
 }
}
```

然后将代理链接 `your.domain.com` 并导入 OneAPI 的 Gemini 渠道。类似方法适用于对 Claude 和 OpenAI 等服务的转发。





部署M3E向量模型：

目前市面主流的向量模型有openai的text-embedding-ada、国产的m3e、bge。其中m3e和bge均有开源版本可以本地部署。

Embedding 模型：https://ollama.com/blog/embedding-models



```
docker run -d --name m3e -p 6008:6008 registry.cn-hangzhou.aliyuncs.com/fastgpt_docker/m3e-large-api
# nvida-docker 使用GPU
docker run -d --name m3e -p 6008:6008 --gpus all registry.cn-hangzhou.aliyuncs.com/fastgpt_docker/m3e-large-api
```

不支持macos arm架构：

```
m3e_api The requested image's platform (linux/amd64) does not match the detected host platform (linux/arm64/v8) and no specific platform was requested
```

oneapi配置m3e向量模型: 类型选择自定义渠道，base url输入：http://192.168.110.132:6008，名称输入：m3e,分组默认default,模型输入：m3e,密钥：***sk-aaabbbcccdddeeefffggghhhiiijjjkkk***，测试连通性会报404不用管。



**nomic-embed-text**向量模型：

```
ollama pull nomic-embed-text
ollama serve
curl http://localhost:11434/api/embeddings -d '{ "model": "nomic-embed-text", "prompt": "this is test,who are you?" }' 
```

类似的向量模型还有：

```
ollama run mofanke/acge_text_embedding
ollama run shaw/dmeta-embedding-zh
ollama run herald/dmeta-embedding-zh
```

服务启动脚本：

```
#!/bin/bash

# 设置环境变量
export OLLAMA_HOST=0.0.0.0:11434

# 检查 tmux 是否已安装
if ! command -v tmux &> /dev/null
then
    if [ -x "$(command -v apt)" ]; then
        sudo apt-get update && sudo apt-get install -y tmux
    elif [ -x "$(command -v yum)" ]; then
        sudo yum install -y tmux
    else
        echo "请手动安装tmux。"
        exit 1
    fi
fi

if [ $(ps -ef | grep '[o]llama serve' | wc -l) -eq 0 ]; then
  nohup ollama serve > ollama.log 2>&1 &
  ollama pull nomic-embed-text
  ollama list
fi

if [ $(ps -ef | grep '[o]llama run qwen2:7b' | grep -v grep | wc -l) -eq 0 ]; then
  #screen -dmS qwen2 -t xterm bash -c 'ollama run qwen2:7b; exec bash'
  tmux new-session -d -s qwen2 'bash -c "ollama run qwen2:7b; exec bash"'
  echo "重新连接到qwen2会话执行：tmux attach-session -t qwen2"
fi
if [ $(ps -ef | grep '[o]llama run llama3.1:8b' | grep -v grep | wc -l) -eq 0 ]; then
  tmux new-session -d -s llama3 'bash -c "ollama run llama3.1:8b; exec bash"'
  echo "连接llama3:tmux attach-session -t llama3"
fi

```

服务停止脚本：

```
#!/bin/bash
process=$(ps -ef|grep ollama|grep -v grep|grep -v "$0")
echo "$process"
if [ $(echo $process|wc -l) -eq 0 ];then
  exit 0
fi
echo "$process" |awk '{print $2}'|xargs kill -9
```





开始部署FastGPT

下载docker-compose.yml

```shell
mkdir fastgpt
cd fastgpt
curl -O https://raw.githubusercontent.com/labring/FastGPT/main/projects/app/data/config.json

# pgvector 版本(测试推荐，简单快捷)
curl -o docker-compose.yml https://raw.githubusercontent.com/labring/FastGPT/main/files/docker/docker-compose-pgvector.yml
# milvus 版本
# curl -o docker-compose.yml https://raw.githubusercontent.com/labring/FastGPT/main/files/docker/docker-compose-milvus.yml
# zilliz 版本
# curl -o docker-compose.yml https://raw.githubusercontent.com/labring/FastGPT/main/files/docker/docker-compose-zilliz.yml
```

根据向量数据的规模，官方也推荐了不同的向量数据库方案：

1. 千万级以下的数据或体验使用，postgreSQL数据库+pgvector插件就足够了
2. 千万级以上的数据量，推荐使用Milvus数据库
3. 亿级以上的数据量，推荐使用zilliz cloud

修改配置（只限zilliz版本）

```shell
修改`MILVUS_ADDRESS`和`MILVUS_TOKEN`链接参数，分别对应 `zilliz` 的 `Public Endpoint` 和 `Api key`，记得把自己ip加入白名单。
```



docker-compose.yml:

```
version: '3.3'
services:
  # db
  pg:
    # image: pgvector/pgvector:0.7.0-pg15 # docker hub
    image: registry.cn-hangzhou.aliyuncs.com/fastgpt/pgvector:v0.7.0 # 阿里云
    container_name: pg
    restart: always
    privileged: true
    ports: # 生产环境建议不要暴露
      - 5432:5432
    networks:
      - fastgpt
    environment:
      # 这里的配置只有首次运行生效。修改后，重启镜像是不会生效的。需要把持久化数据删除再重启，才有效果
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=postgres
      - POSTGRES_DB=postgres
    volumes:
      - ./pg/data:/var/lib/postgresql/data
  mongo:
    # image: mongo:5.0.18 # dockerhub
    image: registry.cn-hangzhou.aliyuncs.com/fastgpt/mongo:5.0.18 # 阿里云
    # image: mongo:4.4.29 # cpu不支持AVX时候使用
    container_name: mongo
    restart: always
    ports:
      - 27017:27017
    networks:
      - fastgpt
    command: mongod --keyFile /data/mongodb.key --replSet rs0
    environment:
      - MONGO_INITDB_ROOT_USERNAME=root
      - MONGO_INITDB_ROOT_PASSWORD=123456
    volumes:
      - ./mongo/data:/data/db
    entrypoint:
      - bash
      - -c
      - |
        openssl rand -base64 128 > /data/mongodb.key
        chmod 400 /data/mongodb.key
        chown 999:999 /data/mongodb.key
        echo 'const isInited = rs.status().ok === 1
        if(!isInited){
          rs.initiate({
              _id: "rs0",
              members: [
                  { _id: 0, host: "mongo:27017" }
              ]
          })
        }' > /data/initReplicaSet.js
        # 启动MongoDB服务
        exec docker-entrypoint.sh "$$@" &

        # 等待MongoDB服务启动
        until mongo -u root -p 123456 --authenticationDatabase admin --eval "print('waited for connection')" > /dev/null 2>&1; do
          echo "Waiting for MongoDB to start..."
          sleep 2
        done

        # 执行初始化副本集的脚本
        mongo -u root -p 123456 --authenticationDatabase admin /data/initReplicaSet.js

        # 等待docker-entrypoint.sh脚本执行的MongoDB服务进程
        wait $$!

  # fastgpt
  sandbox:
    container_name: sandbox
    # image: ghcr.io/labring/fastgpt-sandbox:latest # git
    image: registry.cn-hangzhou.aliyuncs.com/fastgpt/fastgpt-sandbox:latest # 阿里云
    networks:
      - fastgpt
    restart: always
    ports:
      - 3003:3000
  fastgpt:
    container_name: fastgpt
    # image: ghcr.io/labring/fastgpt:v4.8.9 # git
    image: registry.cn-hangzhou.aliyuncs.com/fastgpt/fastgpt:v4.8.9 # 阿里云
    ports:
      - 3000:3000
    networks:
      - fastgpt
    depends_on:
      - mongo
      - pg
      - sandbox
    restart: always
    environment:
      # root 密码，用户名为: root。如果需要修改 root 密码，直接修改这个环境变量，并重启即可。
      - DEFAULT_ROOT_PSW=123456
      # AI模型的API地址哦。务必加 /v1。这里默认填写了OneApi的访问地址。
      - OPENAI_BASE_URL=http://oneapi:3000/v1
      # AI模型的API Key。（这里默认填写了OneAPI的快速默认key，测试通后，务必及时修改）
      - CHAT_API_KEY=sk-fastgpt
      # 数据库最大连接数
      - DB_MAX_LINK=30
      # 登录凭证密钥
      - TOKEN_KEY=any
      # root的密钥，常用于升级时候的初始化请求
      - ROOT_KEY=root_key
      # 文件阅读加密
      - FILE_TOKEN_KEY=filetoken
      # MongoDB 连接参数. 用户名myusername,密码mypassword。
      - MONGODB_URI=mongodb://root:123456@mongo:27017/fastgpt?authSource=admin
      # pg 连接参数
      - PG_URL=postgresql://postgres:postgres@pg:5432/postgres
      # sandbox 地址
      - SANDBOX_URL=http://sandbox:3000
      # 日志等级: debug, info, warn, error
      - LOG_LEVEL=info
      - STORE_LOG_LEVEL=warn
    volumes:
      - ./config.json:/app/data/config.json

  # oneapi
  mysql:
    image: registry.cn-hangzhou.aliyuncs.com/fastgpt/mysql:8.0.36 # 阿里云
    # image: mysql:8.0.36
    container_name: mysql
    restart: always
    ports:
      - 3306:3306
    networks:
      - fastgpt
    command: --default-authentication-plugin=mysql_native_password
    environment:
      # 默认root密码，仅首次运行有效
      MYSQL_ROOT_PASSWORD: oneapimmysql
      MYSQL_DATABASE: oneapi
    volumes:
      - ./mysql:/var/lib/mysql
  oneapi:
    container_name: oneapi
    # image: ghcr.io/songquanpeng/one-api:v0.6.7
    image: registry.cn-hangzhou.aliyuncs.com/fastgpt/one-api:v0.6.6 # 阿里云
    ports:
      - 3002:3000
    depends_on:
      - mysql
    networks:
      - fastgpt
    restart: always
    privileged: true
    environment:
      # mysql 连接参数
      - SQL_DSN=root:oneapimmysql@tcp(mysql:3306)/oneapi
      # 登录凭证加密密钥
      - SESSION_SECRET=oneapikey
      # 内存缓存
      - MEMORY_CACHE_ENABLED=true
      # 启动聚合更新，减少数据交互频率
      - BATCH_UPDATE_ENABLED=true
      # 聚合更新时长
      - BATCH_UPDATE_INTERVAL=10
      # 初始化的 root 密钥（建议部署完后更改，否则容易泄露）
      - INITIAL_ROOT_TOKEN=fastgpt
    volumes:
      - ./oneapi:/data
networks:
  fastgpt:
```

关键配置：

```
# oneapi地址端口，也可以是openai或liteLLM地址
OPENAI_BASE_URL=http://oneapi:3000/v1
# AI模型的API Key ,oneapi中的令牌
CHAT_API_KEY=sk-fastgpt
```



config.json:

```
// 已使用 json5 进行解析，会自动去掉注释，无需手动去除
{
  "feConfigs": {
    "lafEnv": "https://laf.dev" // laf环境。 https://laf.run （杭州阿里云） ,或者私有化的laf环境。如果使用 Laf openapi 功能，需要最新版的 laf 。
  },
  "systemEnv": {
    "vectorMaxProcess": 15,
    "qaMaxProcess": 15,
    "pgHNSWEfSearch": 100 // 向量搜索参数。越大，搜索越精确，但是速度越慢。设置为100，有99%+精度。
  },
  "llmModels": [
    {
      "model": "qwen2:7b",
      "name": "千问2",
      "avatar": "/imgs/model/qwen.svg",
      "maxContext": 125000,
      "maxResponse": 4000,
      "quoteMaxToken": 120000,
      "maxTemperature": 1.2,
      "charsPointsPrice": 0,
      "censor": false,
      "vision": true,
      "datasetProcess": true, 
      "usedInClassify": true,
      "usedInExtractFields": true,
      "usedInToolCall": true,
      "usedInQueryExtension": true,
      "toolChoice": true,
      "functionCall": true,
      "customCQPrompt": "",
      "customExtractPrompt": "",
      "defaultSystemChatPrompt": "",
      "defaultConfig": {}
    },	  
    {
      "model": "gpt-4o-mini", // 模型名(对应OneAPI中渠道的模型名)
      "name": "gpt-4o-mini", // 模型别名
      "avatar": "/imgs/model/openai.svg", // 模型的logo
      "maxContext": 125000, // 最大上下文
      "maxResponse": 16000, // 最大回复
      "quoteMaxToken": 120000, // 最大引用内容
      "maxTemperature": 1.2, // 最大温度
      "charsPointsPrice": 0, // n积分/1k token（商业版）
      "censor": false, // 是否开启敏感校验（商业版）
      "vision": true, // 是否支持图片输入
      "datasetProcess": true, // 是否设置为知识库处理模型（QA），务必保证至少有一个为true，否则知识库会报错
      "usedInClassify": true, // 是否用于问题分类（务必保证至少有一个为true）
      "usedInExtractFields": true, // 是否用于内容提取（务必保证至少有一个为true）
      "usedInToolCall": true, // 是否用于工具调用（务必保证至少有一个为true）
      "usedInQueryExtension": true, // 是否用于问题优化（务必保证至少有一个为true）
      "toolChoice": true, // 是否支持工具选择（分类，内容提取，工具调用会用到。目前只有gpt支持）
      "functionCall": false, // 是否支持函数调用（分类，内容提取，工具调用会用到。会优先使用 toolChoice，如果为false，则使用 functionCall，如果仍为 false，则使用提示词模式）
      "customCQPrompt": "", // 自定义文本分类提示词（不支持工具和函数调用的模型
      "customExtractPrompt": "", // 自定义内容提取提示词
      "defaultSystemChatPrompt": "", // 对话默认携带的系统提示词
      "defaultConfig": {} // 请求API时，挟带一些默认配置（比如 GLM4 的 top_p）
    },
    {
      "model": "gpt-4o",
      "name": "gpt-4o",
      "avatar": "/imgs/model/openai.svg",
      "maxContext": 125000,
      "maxResponse": 4000,
      "quoteMaxToken": 120000,
      "maxTemperature": 1.2,
      "charsPointsPrice": 0,
      "censor": false,
      "vision": true,
      "datasetProcess": false,
      "usedInClassify": true,
      "usedInExtractFields": true,
      "usedInToolCall": true,
      "usedInQueryExtension": true,
      "toolChoice": true,
      "functionCall": false,
      "customCQPrompt": "",
      "customExtractPrompt": "",
      "defaultSystemChatPrompt": "",
      "defaultConfig": {}
    }
  ],
  "vectorModels": [
    {
      "model": "m3e", 
      "name": "m3e", 
      "inputPrice": 0,
      "outputPrice": 0, 
      "defaultToken": 500, 
      "maxToken": 1800,
      "weight": 100,
      "defaultConfig": {},
      "queryConfig": {} 
    },	  
    {
      "model": "text-embedding-ada-002", // 模型名（与OneAPI对应）
      "name": "Embedding-2", // 模型展示名
      "avatar": "/imgs/model/openai.svg", // logo
      "charsPointsPrice": 0, // n积分/1k token
      "defaultToken": 700, // 默认文本分割时候的 token
      "maxToken": 3000, // 最大 token
      "weight": 100, // 优先训练权重
      "defaultConfig": {}, // 自定义额外参数。例如，如果希望使用 embedding3-large 的话，可以传入 dimensions:1024，来返回1024维度的向量。（目前必须小于1536维度）
      "dbConfig": {}, // 存储时的额外参数（非对称向量模型时候需要用到）
      "queryConfig": {} // 参训时的额外参数
    },
    {
      "model": "text-embedding-3-large",
      "name": "text-embedding-3-large",
      "avatar": "/imgs/model/openai.svg",
      "charsPointsPrice": 0,
      "defaultToken": 512,
      "maxToken": 3000,
      "weight": 100,
      "defaultConfig": {
        "dimensions": 1024
      }
    },
    {
      "model": "text-embedding-3-small",
      "name": "text-embedding-3-small",
      "avatar": "/imgs/model/openai.svg",
      "charsPointsPrice": 0,
      "defaultToken": 512,
      "maxToken": 3000,
      "weight": 100
    }
  ],
  "reRankModels": [],
  "audioSpeechModels": [
    {
      "model": "tts-1",
      "name": "OpenAI TTS1",
      "charsPointsPrice": 0,
      "voices": [
        { "label": "Alloy", "value": "alloy", "bufferId": "openai-Alloy" },
        { "label": "Echo", "value": "echo", "bufferId": "openai-Echo" },
        { "label": "Fable", "value": "fable", "bufferId": "openai-Fable" },
        { "label": "Onyx", "value": "onyx", "bufferId": "openai-Onyx" },
        { "label": "Nova", "value": "nova", "bufferId": "openai-Nova" },
        { "label": "Shimmer", "value": "shimmer", "bufferId": "openai-Shimmer" }
      ]
    }
  ],
  "whisperModel": {
    "model": "whisper-1",
    "name": "Whisper1",
    "charsPointsPrice": 0
  }
}

```

如果有自己的大模型，可以去掉oneapi和mysql，

```
services:
  # db
  pg:
    # image: pgvector/pgvector:0.7.0-pg15 # docker hub
    image: registry.cn-hangzhou.aliyuncs.com/fastgpt/pgvector:v0.7.0 # 阿里云
    container_name: pg
    restart: always
    privileged: true
    ports: # 生产环境建议不要暴露
      - 5432:5432
    networks:
      - fastgpt
    environment:
      # 这里的配置只有首次运行生效。修改后，重启镜像是不会生效的。需要把持久化数据删除再重启，才有效果
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=postgres
      - POSTGRES_DB=postgres
    volumes:
      - ./pg/data:/var/lib/postgresql/data
  mongo:
    # image: mongo:5.0.18 # dockerhub
    image: registry.cn-hangzhou.aliyuncs.com/fastgpt/mongo:5.0.18 # 阿里云
    # image: mongo:4.4.29 # cpu不支持AVX时候使用
    container_name: mongo
    restart: always
    ports:
      - 27017:27017
    networks:
      - fastgpt
    command: mongod --keyFile /data/mongodb.key --replSet rs0
    environment:
      - MONGO_INITDB_ROOT_USERNAME=root
      - MONGO_INITDB_ROOT_PASSWORD=123456
    volumes:
      - ./mongo/data:/data/db
    entrypoint:
      - bash
      - -c
      - |
        openssl rand -base64 128 > /data/mongodb.key
        chmod 400 /data/mongodb.key
        chown 999:999 /data/mongodb.key
        echo 'const isInited = rs.status().ok === 1
        if(!isInited){
          rs.initiate({
              _id: "rs0",
              members: [
                  { _id: 0, host: "mongo:27017" }
              ]
          })
        }' > /data/initReplicaSet.js
        # 启动MongoDB服务
        exec docker-entrypoint.sh "$$@" &

        # 等待MongoDB服务启动
        until mongo -u root -p 123456 --authenticationDatabase admin --eval "print('waited for connection')" > /dev/null 2>&1; do
          echo "Waiting for MongoDB to start..."
          sleep 2
        done

        # 执行初始化副本集的脚本
        mongo -u root -p 123456 --authenticationDatabase admin /data/initReplicaSet.js

        # 等待docker-entrypoint.sh脚本执行的MongoDB服务进程
        wait $$!
#  nginx:
#    container_name: nginx
#    image: nginx
#    ports:
#      - 9080:80
#    volumes:
#      - ./nginx/html:/usr/share/nginx/html
#      - ./nginx/conf:/etc/nginx
#      - ./nginx/log:/var/log/nginx
#    restart: unless-stopped
#    environment:
#      TZ: Asia/Shanghai
#      LANG: en_US.UTF-8
  # fastgpt
  sandbox:
    container_name: sandbox
    # image: ghcr.io/labring/fastgpt-sandbox:latest # git
    image: registry.cn-hangzhou.aliyuncs.com/fastgpt/fastgpt-sandbox:latest # 阿里云
    networks:
      - fastgpt
    restart: always
    ports:
      - 3003:3000
  fastgpt:
    container_name: fastgpt
    # image: ghcr.io/labring/fastgpt:v4.8.9 # git
    image: registry.cn-hangzhou.aliyuncs.com/fastgpt/fastgpt:v4.8.9 # 阿里云
    ports:
      - 3000:3000
    networks:
      - fastgpt
    depends_on:
      - mongo
      - pg
      - sandbox
#      - nginx
    restart: always
    environment:
      # root 密码，用户名为: root。如果需要修改 root 密码，直接修改这个环境变量，并重启即可。
      - DEFAULT_ROOT_PSW=123456
      # AI模型的API地址哦。务必加 /v1。这里默认填写了OneApi的访问地址。
      - OPENAI_BASE_URL=http://192.168.110.195:11434/api
      # AI模型的API Key。（这里默认填写了OneAPI的快速默认key，测试通后，务必及时修改）
      - CHAT_API_KEY=sk-fastgpt
      # 数据库最大连接数
      - DB_MAX_LINK=30
      # 登录凭证密钥
      - TOKEN_KEY=any
      # root的密钥，常用于升级时候的初始化请求
      - ROOT_KEY=root_key
      # 文件阅读加密
      - FILE_TOKEN_KEY=filetoken
      # MongoDB 连接参数. 用户名myusername,密码mypassword。
      - MONGODB_URI=mongodb://root:123456@mongo:27017/fastgpt?authSource=admin
      # pg 连接参数
      - PG_URL=postgresql://postgres:postgres@pg:5432/postgres
      # sandbox 地址
      - SANDBOX_URL=http://sandbox:3000
      # 日志等级: debug, info, warn, error
      - LOG_LEVEL=info
      - STORE_LOG_LEVEL=warn
    volumes:
      - ./config.json:/app/data/config.json

networks:
  fastgpt:
```

再把fastgpt中oneapi的地址和密钥修改为自己的大模型服务的地址和密钥即可。

```
OPENAI_BASE_URL=http://oneapi:3000/v1
改为
OPENAI_BASE_URL=http://ollama:11434/v1
ollama运行Embedding服务(http://localhost:11434/api/embeddings)
ollama serve
ollama pull nomic-embed-text

```



启动容器

```shell
# 启动容器
docker-compose up -d
# 等待10s，OneAPI第一次总是要重启几次才能连上Mysql
sleep 10
# 重启一次oneapi(由于OneAPI的默认Key有点问题，不重启的话会提示找不到渠道，临时手动重启一次解决，等待作者修复)
docker restart oneapi
```

打开http://localhost:3000

默认用户root/123456

配置：

1. 先新建知识库，知识库类型选择通用知识库，输入自定义名称，索引模型选择m3e,文件处理模型选择千问2，然后新建数据集，新建文本数据集，选择本地文件，上传文件，等待文件状态变为已就绪

2. 工作台创建应用，选择简易应用，输入自定义应用名称，模板选择知识库+对话引导，AI模型选择千问2，关联知识库选择前面创建的知识库，提示词输入：

   ```
   1. 你是计量大学研究院平台的知识助手，你的主要任务是帮助用户获取信息、解答疑问和提供各种知识上的支持。无论是学术研究、技术咨询还是日常生活中的问题，你都要致力于以最准确的方式提供帮助。你需要按照上文得到的知识库的内容进行回答，当没有搜索到相关知识时，不要瞎说，也不要回答不知道，要帮助用户改进问题引导到可能的问题上。
   2. 对于实在不知道或者不确定的事情不要瞎说，不要随意回答，一定要保证你作为研究院平台知识助手的严谨性，避免商业纠纷和法律、道德风险！
   3. 不要和用户闲聊，请时刻记住你研究院平台知识助手的身份！
   ```

   

不通过docker安装fastGPT:

预先安装nodejs后，安装好oneapi、mysql、mongodb、pg数据库及pgvector，然后下载fastGPT源码进行安装

```
git clone git@github.com:labring/FastGPT.git
cd FastGPT
npm install -g pnpm
pnpm i
```

依赖安装完成后，进入projects/app目录fastgpt应用的源码目录，把这个目录下的.env.template文件复制一份，改名为.env.local，再把里面的oneapi的地址和密钥、mongodb连接、pg连接参数，按自己实际的情况进行修改。再找到这个目录下的package.json，如果你想在本地开发调试，就在projects/app目录下运行下面这个命令：

```
pnpm dev
```

使用调试运行的方式，你可以在代码中打断点进行debug跟踪，对于了解源码的运行流程、二次开发，都是非常有帮助的。但调试运行的方式相对来说会比较慢，你打开哪个页面，对应的代码才开始编译，如果你想在本地直接运行，并不想调试，那么你需要运行下面的命令：

```
pnpm build
pnpm start
```

直接运行的方式，需要先执行build进行打包，打包的过程比较慢，也比较耗cpu和内存，打包完成后，基于打成的包直接运行，速度就会非常快了。



ollama

ollama的官网https://www.ollama.com/

ollama的github项目地址https://github.com/ollama/ollama

下载地址：https://ollama.com/download

windows默认安装位置：C:\Users\Administrator\AppData\Local\Programs\Ollama

linux安装：

```shell
curl -fsSL https://ollama.com/install.sh | sh
```

验证安装：

```shell
ollama -v
```

配置端口：

ollama serve默认端口为127.0.0.1:11434，这个端口在部署open-webui时需要用到，建议默认即可。如果需要修改默认端口，则需要添加一个环境变量OLLAMA_HOST=0.0.0.0:11434。

配置模型文件路径：

配置系统环境变量OLLAMA_MODELS设置模型文件保存位置

启动服务：

```shell
ollama serve
```

运行模型

```shell
ollama run llama3:8b
ollama run qwen2:7b
```

请求ollama api：

```
curl http://192.168.110.195:11434/api/generate -d '{"model": "qwen2:7b","prompt": "你是谁?","stream":false}'
```



open-webui

Open WebUI 是一种可扩展、功能丰富且用户友好的自托管 WebUI，旨在完全离线运行。它支持各种LLM运行器，包括 Ollama 和 OpenAI 兼容的 API。

open-webui项目地址https://github.com/open-webui/open-webui/tree/main

需要安装python3.10和nodejs(21.7.1)

下载源码后安装nodejs依赖

```shell
npm config set registry https://mirrors.huaweicloud.com/repository/npm/
npm i
npm run build

```

安装python依赖

```shell
cd backend
pyenv local 3.10.14
pip3 install -r requirements.txt
```

启动webui

启动时会自动从[huggingface.co](https://huggingface.co/)下载sentence-transformers模型文件all-MiniLM-L6-v2，服务器在国外，无法下载，所以先要设置代理或从国内镜像网站上将模型和配置文件下载到本地。[HF-Mirror - Huggingface 镜像站](https://hf-mirror.com/)

```shell
export HF_ENDPOINT=https://hf-mirror.com
./start.sh
```

