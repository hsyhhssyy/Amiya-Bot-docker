# 如何使用
# 首先创建镜像，在本地配置文件修改完毕的情况下，执行下面的命令打包镜像
# docker build -t amiya-bot .
# 然后执行下面的命令来启动阿米娅bot
# 注意他将plugins和pluginsDev以Volume的形式映射出来了，你需要磁盘上有对应的目录才行
# docker run -dit --name amiya-bot --restart=always -p 5080:5080 -p 5443:5443 -v /opt/amiya-bot/amiya-bot-v6/plugins:/amiyabot/plugins -v /opt/amiya-bot/amiya-bot-v6/resource:/amiyabot/resource amiya-bot python3.8 /amiyabot/amiya.py
FROM ubuntu:22.04 AS amiya-bot-base

WORKDIR /amiyabot

EXPOSE 5080
EXPOSE 5443

# 设置时区和换源

ENV TZ=Asia/Shanghai

RUN apt-get -y update

RUN apt install -y --reinstall software-properties-common

# RUN cp /etc/apt/sources.list /etc/apt/sources.list.ori
# RUN sed -i s@/archive.ubuntu.com/@/mirrors.aliyun.com/@g /etc/apt/sources.list
# RUN sed -i s@/security.ubuntu.com/@/mirrors.aliyun.com/@g /etc/apt/sources.list

RUN add-apt-repository ppa:deadsnakes/ppa -y

# 可以通过修改这一段来丢弃缓存

RUN apt-get -y update
RUN apt-get clean

ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get -y install git tzdata


RUN apt-get -y install python3.8
RUN apt-get -y install python3-pip

RUN apt-get -y install curl
RUN apt-get -y install dnsutils

RUN apt-get -y install python3.8 python3.8-dev python3.8-distutils python3-pip

# RUN python3.8 -m pip install --upgrade pip -i https://pypi.tuna.tsinghua.edu.cn/simple

# 不管用得上与否，都强制安装playwright，因为这东西的安装非常慢，不适合在启动时执行

# 1.31.1对应版本111.0.5563.19
RUN python3.8 -m pip install playwright==1.31.1

RUN playwright install chromium

RUN python3.8 -m pip show playwright
RUN python3.8 -c "import sys; print('\n'.join(sys.path))"

RUN python3.8 -m playwright install --with-deps

# 适当添加一些安装的比较久的lib


# paddlespeech 报错 AttributeError: module 'numpy' has no attribute 'complex'.
# 需要降低numpy的版本
# RUN python3.8 -m pip install numpy==1.23.5
# RUN python3.8 -m pip install paddlenlp==2.5.0
RUN python3.8 -m pip install paddlepaddle==2.4.2
# RUN python3.8 -m pip install paddlespeech==1.4.1

RUN python3.8 -m pip install paddleocr

# 预先安装paddle的一系列内容
RUN echo "from paddleocr import PaddleOCR" > paddle_init.py && \
    echo "ocr = PaddleOCR(lang='ch')" >> paddle_init.py && \
    echo "print('PaddleOCR初始化完成')" >> paddle_init.py

# RUN echo "from paddlespeech.cli.asr.infer import ASRExecutor" >> paddle_init.py && \
#     echo "asr = ASRExecutor()" >> paddle_init.py && \
#     echo "print('ASRExecutor初始化完成')" >> paddle_init.py && \
#     echo "from paddlespeech.cli.tts.infer import TTSExecutor" >> paddle_init.py && \
#     echo "tts = TTSExecutor()" >> paddle_init.py && \
#     echo "print('TTSExecutor初始化完成')" >> paddle_init.py

RUN cat paddle_init.py

RUN python3.8 paddle_init.py

RUN python3.8 -m pip install openai

# 根据需要的插件，安装依赖

RUN python3.8 -m pip install wordcloud==1.8.2.2

# 安装阿米娅bot的依赖

COPY ./Amiya-Bot/requirements.txt requirements.txt

# 删除对Core的依赖
RUN sed -i '/amiyabot==[0-9]*\.[0-9]*\.[0-9]*/d' requirements.txt

RUN python3.8 -m pip install -r requirements.txt

# 使用dev-core

COPY ./Amiya-Bot-core/ /amiyabot-core/

WORKDIR /amiyabot-core

RUN echo "n\n0.0.1" > inputs.txt && \
    python3.8 setup.py bdist_wheel < inputs.txt

RUN ls -ltr dist/

# 版本更新后，脚本将会变更，届时修改切换注释即可
# RUN python3.8 -m pip install dist/amiyabot-0.0.1-*-py3-none-any.whl
RUN python3.8 -m pip install dist/amiyabot-0.0.1-py3-none-any.whl

# 上述命令替换了旧有的core安装。如果需要使用当前live版本的core，可以使用下面的命令
# RUN python3.8 -m pip install amiyabot

# 切回到原始目录并继续后续步骤

WORKDIR /amiyabot

COPY ./Amiya-Bot/ .

COPY ./Amiya-Bot-docker/docker_start.sh .

# 配置启动脚本

CMD ./docker_start.sh
