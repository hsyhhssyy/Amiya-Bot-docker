# Amiya-Bot

![DockerHub](https://img.shields.io/docker/v/hsyhhssyy/amiyabot) [![Workflow](https://img.shields.io/github/actions/workflow/status/hsyhhssyy/amiya-bot-docker/docker-image.yml?branch=master)](https://github.com/hsyhhssyy/amiya-bot-docker/actions)
![License](https://img.shields.io/github/license/hsyhhssyy/amiya-bot-docker)


## 介绍
Amiya-Bot 是一个高效的机器人项目，适用于各种自动化任务。

本项目提供了一个官方Docker容器，确保了跨平台的兼容性和易于部署的特性。

## 快速开始
要开始使用Amiya-Bot，请确保你已经安装了Docker。首先，创建必要的Docker卷：

```bash
docker volume create amiya-bot-plugins
docker volume create amiya-bot-config
docker volume create amiya-bot-resource
```

然后，使用以下命令来启动你的Amiya-Bot实例，这些命令将使用刚刚创建的卷：

```bash
docker run -dit --name amiya-bot --restart=always -p 5080:5080 -p 5443:5443 -v amiya-bot-plugins:/amiyabot/plugins -v amiya-bot-config:/amiyabot/config -v amiya-bot-resource:/amiyabot/resource amiya-bot python3.8 /amiyabot/amiya.py
```

这将会启动Amiya-Bot，并暴露5080和5443端口。同时，它会将Docker卷映射到容器内的指定目录。

## 如何贡献
我们欢迎所有形式的贡献，无论是新功能的建议，代码贡献，还是文档的改进。感谢下面这些朋友的共享：

[![Contributors](https://contributors-img.web.app/image?repo=hsyhhssyy/Amiya-Bot-docker&max=114514&columns=15)](https://github.com/hsyhhssyy/Amiya-Bot-docker/graphs/contributors)

## 联系方式
如有任何问题或建议，请通过[GitHub Issues](https://github.com/hsyhhssyy/amiya-bot-docker/issues)与我们联系。