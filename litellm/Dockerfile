# 使用基础镜像 ollama/ollama
FROM ollama/ollama

# 执行 apt 更新和安装 python3 和 pip3
RUN apt update && apt install -y python3 && apt install -y python3-pip

# 安装 litellm 和 litellm[proxy]，指定豆瓣镜像源
RUN pip3 install litellm -i https://pypi.douban.com/simple
RUN pip3 install 'litellm[proxy]' -i https://pypi.douban.com/simple

# 设置ENTRYPOINT
ENTRYPOINT ["litellm", "--model", "ollama/qwen2:7b"]
