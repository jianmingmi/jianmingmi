---
uuid: ed4e2d50-bd8f-11ed-a50e-3d071851c438
title: Channels实现WebSocket
date: 2023-3-19
tags:
  - Web
abbrlink: 3e4ef478
---

Channels实现WebSocket

<!--more-->

## WebSocket是什么？

WebSocket是一种在单个TCP连接上进行全双工通讯的协议。WebSocket允许服务端主动向客户端推送数据。在WebSocket协议中，客户端浏览器和服务器只需要完成一次握手就可以创建持久性的连接，并在浏览器和服务器之间进行双向的数据传输。

## WebSocket有什么用？

WebSocket区别于HTTP协议的一个最为显著的特点是，WebSocket协议可以由服务端主动发起消息，对于浏览器需要及时接收数据变化的场景非常适合，例如在Django中遇到一些耗时较长的任务我们通常会使用Celery来异步执行，那么浏览器如果想要获取这个任务的执行状态，在HTTP协议中只能通过轮训的方式由浏览器不断的发送请求给服务器来获取最新状态，这样发送很多无用的请求不仅浪费资源，还不够优雅，如果使用WebSokcet来实现就很完美了

WebSocket的另外一个应用场景就是下文要说的聊天室，一个用户（浏览器）发送的消息需要实时的让其他用户（浏览器）接收，这在HTTP协议下是很难实现的，但WebSocket基于长连接加上可以主动给浏览器发消息的特性处理起来就游刃有余了

初步了解WebSocket之后，我们看看如何在Django中实现WebSocket

## Channels
Django本身不支持WebSocket，但可以通过集成Channels框架来实现WebSocket

Channels是针对Django项目的一个增强框架，可以使Django不仅支持HTTP协议，还能支持WebSocket，MQTT等多种协议，同时Channels还整合了Django的auth以及session系统方便进行用户管理及认证。

我下文所有的代码实现使用以下python和Django版本

* python==3.6.3
* django==2.2

## 集成Channels
我假设你已经新建了一个django项目，``项目名字就叫webapp``，目录结构如下

```
project
    - webapp
        - __init__.py
        - settings.py
        - urls.py
        - wsgi.py
    - manage.py
```

1. 安装channels

```
pip install channels==2.1.7
```

2. 修改settings.py文件

```
# APPS中添加channels
INSTALLED_APPS = [
    'django.contrib.staticfiles',
    'channels',
]

# 指定ASGI的路由地址
ASGI_APPLICATION = 'webapp.routing.application'
```

channels运行于ASGI协议上，ASGI的全名是Asynchronous Server Gateway Interface。它是区别于Django使用的WSGI协议 的一种异步服务网关接口协议，正是因为它才实现了websocket

``ASGI_APPLICATION`` 指定主路由的位置为webapp下的routing.py文件中的application

3. setting.py的同级目录下创建routing.py路由文件，routing.py类似于Django中的url.py指明websocket协议的路由

```
from channels.routing import ProtocolTypeRouter

application = ProtocolTypeRouter({
    # 暂时为空，下文填充
})
```

4. 运行Django项目

```
C:\python36\python.exe D:/demo/tailf/manage.py runserver 0.0.0.0:80
Performing system checks...
Watching for file changes with StatReloader

System check identified no issues (0 silenced).
April 12, 2019 - 17:44:52
Django version 2.2, using settings 'webapp.settings'
Starting ASGI/Channels version 2.1.7 development server at http://0.0.0.0:80/
Quit the server with CTRL-BREAK.
```

仔细观察上边的输出会发现Django启动中的``Starting development server``已经变成了``Starting ASGI/Channels version 2.1.7 development server``，这表明项目已经由django使用的WSGI协议转换为了Channels使用的ASGI协议

至此Django已经基本集成了Channels框架

## 构建聊天室

上边虽然在项目中集成了Channels，但并没有任何的应用使用它，接下来我们以聊天室的例子来讲解Channels的使用

假设你已经创建好了一个叫chat的app，并添加到了settings.py的INSTALLED_APPS中，app的目录结构大概如下

```
chat
    - migrations
        - __init__.py
    - __init__.py
    - admin.py
    - apps.py
    - models.py
    - tests.py
    - views.py
```

我们构建一个标准的Django聊天页面，相关代码如下

url:
```
from django.urls import path
from chat.views import chat

urlpatterns = [
    path('chat', chat, name='chat-url')
]
```

view:
```
from django.shortcuts import render

def chat(request):
    return render(request, 'chat/index.html')
```

template:
```
{% extends "base.html" %}

{% block content %}
  <textarea class="form-control" id="chat-log" disabled rows="20"></textarea><br/>
  <input class="form-control" id="chat-message-input" type="text"/><br/>
  <input class="btn btn-success btn-block" id="chat-message-submit" type="button" value="Send"/>
{% endblock %}
```

通过上边的代码一个简单的web聊天页面构建完成了，访问页面大概样子如下：

![](/images/2023-3-19Channels实现WebSocket/1.jpg)

接下来我们利用Channels的WebSocket协议实现消息的发送接收功能

1. 先从路由入手，上边我们已经创建了routing.py路由文件，现在来填充里边的内容

```
from channels.auth import AuthMiddlewareStack
from channels.routing import ProtocolTypeRouter, URLRouter
import chat.routing

application = ProtocolTypeRouter({
    'websocket': AuthMiddlewareStack(
        URLRouter(
            chat.routing.websocket_urlpatterns
        )
    ),
})
```

``ProtocolTypeRouter``： ASIG支持多种不同的协议，在这里可以指定特定协议的路由信息，我们只使用了websocket协议，这里只配置websocket即可

``AuthMiddlewareStack``： django的channels封装了django的auth模块，使用这个配置我们就可以在consumer中通过下边的代码获取到用户的信息

```
def connect(self):
    self.user = self.scope["user"]
```

``self.scope``类似于django中的request，包含了请求的type、path、header、cookie、session、user等等有用的信息

URLRouter： 指定路由文件的路径，也可以直接将路由信息写在这里，代码中配置了路由文件的路径，会去chat下的routeing.py文件中查找websocket_urlpatterns，``chat/routing.py``内容如下

```
from django.urls import path
from chat.consumers import ChatConsumer

websocket_urlpatterns = [
    path('ws/chat/', ChatConsumer),
]
```

routing.py路由文件跟django的url.py功能类似，语法也一样，意思就是访问``ws/chat/``都交给``ChatConsumer``处理

2. 接着编写consumer，consumer类似django中的view，内容如下

```
from channels.generic.websocket import WebsocketConsumer
import json

class ChatConsumer(WebsocketConsumer):
    def connect(self):
        self.accept()

    def disconnect(self, close_code):
        pass

    def receive(self, text_data):
        text_data_json = json.loads(text_data)
        message = '运维：' + text_data_json['message']

        self.send(text_data=json.dumps({
            'message': message
        }))
```

这里是个最简单的同步websocket consumer类，connect方法在连接建立时触发，disconnect在连接关闭时触发，receive方法会在收到消息后触发。整个ChatConsumer类会将所有收到的消息加上“运维：”的前缀发送给客户端

3. 最后我们在html模板页面添加websocket支持

```
{% extends "base.html" %}

{% block content %}
  <textarea class="form-control" id="chat-log" disabled rows="20"></textarea><br/>
  <input class="form-control" id="chat-message-input" type="text"/><br/>
  <input class="btn btn-success btn-block" id="chat-message-submit" type="button" value="Send"/>
{% endblock %}

{% block js %}
<script>
  var chatSocket = new WebSocket(
    'ws://' + window.location.host + '/ws/chat/');

  chatSocket.onmessage = function(e) {
    var data = JSON.parse(e.data);
    var message = data['message'];
    document.querySelector('#chat-log').value += (message + '\n');
  };

  chatSocket.onclose = function(e) {
    console.error('Chat socket closed unexpectedly');
  };

  document.querySelector('#chat-message-input').focus();
  document.querySelector('#chat-message-input').onkeyup = function(e) {
    if (e.keyCode === 13) {  // enter, return
        document.querySelector('#chat-message-submit').click();
    }
  };

  document.querySelector('#chat-message-submit').onclick = function(e) {
    var messageInputDom = document.querySelector('#chat-message-input');
    var message = messageInputDom.value;
    chatSocket.send(JSON.stringify({
        'message': message
    }));

    messageInputDom.value = '';
  };
</script>
{% endblock %}
```

WebSocket对象一个支持四个消息：onopen，onmessage，oncluse和onerror，我们这里用了两个onmessage和onclose

onopen： 当浏览器和websocket服务端连接成功后会触发onopen消息

onerror： 如果连接失败，或者发送、接收数据失败，或者数据处理出错都会触发onerror消息

onmessage： 当浏览器接收到websocket服务器发送过来的数据时，就会触发onmessage消息，参数``e``包含了服务端发送过来的数据

onclose： 当浏览器接收到websocket服务器发送过来的关闭连接请求时，会触发onclose消息

4. 完成前边的代码，一个可以聊天的websocket页面就完成了，运行项目，在浏览器中输入消息就会通过websocket-->rouging.py-->consumer.py处理后返回给前端

![](/images/2023-3-19Channels实现WebSocket/2.jpg)

## 启用Channel Layer

上边的例子我们已经实现了消息的发送和接收，但既然是聊天室，肯定要支持多人同时聊天的，当我们打开多个浏览器分别输入消息后发现只有自己收到消息，其他浏览器端收不到，如何解决这个问题，让所有客户端都能一起聊天呢？

Channels引入了一个layer的概念，channel layer是一种通信系统，允许多个consumer实例之间互相通信，以及与外部Djanbo程序实现互通。

channel layer主要实现了两种概念抽象：

channel name： channel实际上就是一个发送消息的通道，每个Channel都有一个名称，每一个拥有这个名称的人都可以往Channel里边发送消息

group： 多个channel可以组成一个Group，每个Group都有一个名称，每一个拥有这个名称的人都可以往Group里添加/删除Channel，也可以往Group里发送消息，Group内的所有channel都可以收到，但是无法发送给Group内的具体某个Channel

了解了上边的概念，接下来我们利用channel layer实现真正的聊天室，能够让多个客户端发送的消息被彼此看到

1. 官方推荐使用redis作为channel layer，所以先安装channels_redis
```
pip install channels_redis==2.3.3
```

2. 然后修改settings.py添加对layer的支持

```
CHANNEL_LAYERS = {
    'default': {
        'BACKEND': 'channels_redis.core.RedisChannelLayer',
        'CONFIG': {
            "hosts": [('ops-coffee.cn', 6379)],
        },
    },
}
```

添加channel之后我们可以通过以下命令检查通道层是否能够正常工作

```
>python manage.py shell
Python 3.6.3 (v3.6.3:2c5fed8, Oct  3 2017, 18:11:49) [MSC v.1900 64 bit (AMD64)] on win32
Type "help", "copyright", "credits" or "license" for more information.
(InteractiveConsole)
>>> import channels.layers
>>> channel_layer = channels.layers.get_channel_layer()
>>>
>>> from asgiref.sync import async_to_sync
>>> async_to_sync(channel_layer.send)('test_channel',{'site':'https://ops-coffee.cn'})
>>> async_to_sync(channel_layer.receive)('test_channel')
{'site': 'https://ops-coffee.cn'}
>>>
```

3. consumer做如下修改引入channel layer

```
from asgiref.sync import async_to_sync
from channels.generic.websocket import WebsocketConsumer
import json

class ChatConsumer(WebsocketConsumer):
    def connect(self):
        self.room_group_name = 'ops_coffee'

        # Join room group
        async_to_sync(self.channel_layer.group_add)(
            self.room_group_name,
            self.channel_name
        )

        self.accept()

    def disconnect(self, close_code):
        # Leave room group
        async_to_sync(self.channel_layer.group_discard)(
            self.room_group_name,
            self.channel_name
        )

    # Receive message from WebSocket
    def receive(self, text_data):
        text_data_json = json.loads(text_data)
        message = text_data_json['message']

        # Send message to room group
        async_to_sync(self.channel_layer.group_send)(
            self.room_group_name,
            {
                'type': 'chat_message',
                'message': message
            }
        )

    # Receive message from room group
    def chat_message(self, event):
        message = '运维：' + event['message']

        # Send message to WebSocket
        self.send(text_data=json.dumps({
            'message': message
        }))
```

这里我们设置了一个固定的房间名作为Group name，所有的消息都会发送到这个Group里边，当然你也可以通过参数的方式将房间名传进来作为Group name，从而建立多个Group，这样可以实现仅同房间内的消息互通

当我们启用了channel layer之后，所有与consumer之间的通信将会变成异步的，所以必须使用``async_to_sync``

一个链接（channel）创建时，通过``group_add``将channel添加到Group中，链接关闭通过``group_discard``将channel从Group中剔除，收到消息时可以调用``group_send``方法将消息发送到Group，这个Group内所有的channel都可以收的到

``group_send``中的type指定了消息处理的函数，这里会将消息转给``chat_message``函数去处理

4. 经过以上的修改，我们再次在多个浏览器上打开聊天页面输入消息，发现彼此已经能够看到了，至此一个完整的聊天室已经基本完成

## 修改为异步

我们前边实现的consumer是同步的，为了能有更好的性能，官方支持异步的写法，只需要修改consumer.py即可

```
from channels.generic.websocket import AsyncWebsocketConsumer
import json

class ChatConsumer(AsyncWebsocketConsumer):
    async def connect(self):
        self.room_group_name = 'ops_coffee'

        # Join room group
        await self.channel_layer.group_add(
            self.room_group_name,
            self.channel_name
        )

        await self.accept()

    async def disconnect(self, close_code):
        # Leave room group
        await self.channel_layer.group_discard(
            self.room_group_name,
            self.channel_name
        )

    # Receive message from WebSocket
    async def receive(self, text_data):
        text_data_json = json.loads(text_data)
        message = text_data_json['message']

        # Send message to room group
        await self.channel_layer.group_send(
            self.room_group_name,
            {
                'type': 'chat_message',
                'message': message
            }
        )

    # Receive message from room group
    async def chat_message(self, event):
        message = '运维：' + event['message']

        # Send message to WebSocket
        await self.send(text_data=json.dumps({
            'message': message
        }))
```

其实异步的代码跟之前的差别不大，只有几个小区别：

ChatConsumer由``WebsocketConsumer``修改为了``AsyncWebsocketConsumer``

所有的方法都修改为了异步``defasync def``

用``await``来实现异步I/O的调用

channel layer也不再需要使用``async_to_sync``了

## 原文

[地址](https://mp.weixin.qq.com/s/hqaPrPS7w3D-9SeegQAB2Q)