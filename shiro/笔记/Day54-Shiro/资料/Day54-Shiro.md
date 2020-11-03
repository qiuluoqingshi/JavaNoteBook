## 一、总结与计划

#### 1.1 总结

- thymeleaf碎片使用
- SpringBoot静态资源的使用
- 热部署
  - IDE设置自动编译
  - 项目中添加devtools依赖
  - 服务器更新设置（update classes and resources）
- tkMapper
  - 封装了单表操作
    - 增
    - 删
    - 改
    - 查
    - 条件：Example
  - 逆向工程

#### 1.2 计划

- 权限管理
  - 认证
  - 授权
- shiro简介
- shiro核心
- shiro认证及授权
- shiro使用

## 二、权限管理

#### 2.1 什么是权限管理？

> 不同身份的用户进入到系统所能够完成的操作是不相同的，我们对不同用户进行的可执行的操作的管理称之为权限管理。

|                                                              |
| ------------------------------------------------------------ |
| ![image-20200423102307700](imgs\image-20200423102307700.png) |

#### 2.2 如何实现权限管理？

> 权限管理设计

- 基于主页的权限管理（不同用户使用不同的主页，权限通过主页功能菜单进行限制）

  - 适用于权限管理比较单一、用户少、每类用户权限固定

  |                                                              |
  | ------------------------------------------------------------ |
  | ![image-20200423105515169](imgs\image-20200423105515169.png) |

   

- 基于用户和权限的权限管理

  -  可以实现权限的动态分配，但是不够灵活

  |                                                              |
  | ------------------------------------------------------------ |
  | ![image-20200423112002954](imgs\image-20200423112002954.png) |

  

- 基于角色的访问控制

  -  RBAC 基于角色的访问控制

  |                                                              |
  | ------------------------------------------------------------ |
  | ![image-20200423114311087](imgs\image-20200423114311087.png) |

## 三、安全框架简介

#### 3.1 认证授权流程

- 认证：对用户的身份进行检查（登录验证）

- 授权：对用户的权限进行检查（是否有对应的操作权限）

- 流程示意图：

  |                                                              |
  | ------------------------------------------------------------ |
  | ![image-20200423144726733](imgs\image-20200423144726733.png) |

#### 3.2 安全框架

- 帮助我们完成用户身份认证及权限检查功能框架
- 常用的安全框架：
  - Shiro：Apache Shiro是一个功能强大并且易用的Java安全框架 （小而简单）
  - Spring Security：基于Spring的一个安全框架，依赖Spring
  - OAuth2：第三方授权登录
  - 自定义安全认证中心

#### 3.3 Shiro

- Apache Shiro是一个功能强大并且易用的Java安全框架
- 可以完成用户认证、授权、密码及会话管理
- 可以在任何的应用系统中使用（主要针对单体项目的权限管理）

## 四、Shiro的工作原理

#### 4.1 Shiro的核心功能

![image-20200423151533733](imgs\image-20200423151533733.png)

- Anthentication  认证，验证用户是否有相应的身份—登录认证；
- Authorization  授权，即权限验证；对已经通过认证的用户检查是否具有某个权限或者角色，从而控制是否能够进行某种操作；
- Session Managment 会话管理，用户在认证成功之后创建会话，在没有退出之前，当前用户的所有信息都会保存在这个会话中；可以是普通的JavaSE应用，也可以是web应用；
- Cryptography 加密，对敏感信息进行加密处理，shiro就提供这种加密机制；
- 支持的特性：
  - Web Support  — Shiro提供了过滤器，可以通过过滤器拦截web请求来处理web应用的访问控制
  - Caching 缓存支持，shiro可以缓存用户信息以及用户的角色权限信息，可以提高执行效率
  - Concurrency shiro支持多线程应用
  - Testing 提供测试支持
  - Run As 允许一个用户以另一种身份去访问
  - Remeber Me

- 说明：Shiro是一个安全框架，不提供用户、权限的维护（用户的权限管理需要我们自己去设计）

#### 4.2 Shiro核心组件

|                                                              |
| ------------------------------------------------------------ |
| ![image-20200423155316468](imgs\image-20200423155316468.png) |

- Shiro三大核心组件：Subject、Security Manager、Realms
  - Subject，表示待认证和授权的用户
  - Security Manager，它是Shiro框架的核心，Shiro就是通过Security Manager来进行内部实例的管理，并通过它来提供安全管理的各种服务。
    - Authenticator，认证器
    - Anthorizer，授权器
    - SessionManager，会话管理器
    - CacheManager，缓存管理器
  - Realm，相当于Shiro进行认证和授权的数据源，充当了Shiro与安全数据之间的“桥梁”或者“连接器”。也就是说，当对用户进行认证(登录)和授权（访问控制）验证时，Shiro会用应用配置的Realm中查找用户及其权限信息。

|                                                              |
| ------------------------------------------------------------ |
| ![image-20200423163414191](imgs\image-20200423163414191.png) |

## 五、基于JavaSE应用—Shiro的基本使用

#### 5.1 创建Maven项目

#### 5.2 导入Shiro依赖库

```xml
<dependency>
    <groupId>org.apache.shiro</groupId>
    <artifactId>shiro-core</artifactId>
    <version>1.4.1</version>
</dependency>
```

#### 5.3 创建Shiro配置文件

- 在resource目录下创建名为shiro.ini的文件
- 在文件中完成用户、角色及权限的配置

```ini
[users]
zhangsan=123456,seller
lisi=666666,ckmgr
admin=222222,admin

[roles]
admin=*
seller=order-add,order-del,order-list
ckmgr=ck-add,ck-del,ck-list
```

#### 5.4 Shiro的基本使用

```java
package com.qfedu.shiro;

import org.apache.shiro.SecurityUtils;
import org.apache.shiro.authc.IncorrectCredentialsException;
import org.apache.shiro.authc.UsernamePasswordToken;
import org.apache.shiro.mgt.DefaultSecurityManager;
import org.apache.shiro.mgt.SecurityManager;
import org.apache.shiro.realm.text.IniRealm;
import org.apache.shiro.subject.Subject;

import java.util.Scanner;

public class TestShiro {

    public static void main(String[] args) {

        Scanner scan = new Scanner(System.in);
        System.out.println("请输入帐号：");
        String username = scan.nextLine();
        System.out.println("请输入密码：");
        String password = scan.nextLine();

        //1.创建安全管理器
        DefaultSecurityManager securityManager = new DefaultSecurityManager();
        //2.创建realm
        IniRealm iniRealm = new IniRealm("classpath:shiro.ini");
        //3.将realm设置给安全管理器
        securityManager.setRealm(iniRealm);
        //4.将Realm设置给SecurityUtils工具
        SecurityUtils.setSecurityManager(securityManager);
        //5.通过SecurityUtils工具类获取subject对象
        Subject subject = SecurityUtils.getSubject();

        //【认证流程】
        //a.将认证帐号和密码封装到token对象中
        UsernamePasswordToken token = new UsernamePasswordToken(username,password);
        //b.通过subject对象调用login方法进行认证申请：
        boolean b = false;
        try{
            subject.login(token);
            b = true;
        }catch(IncorrectCredentialsException e){
            b = false;
        }
        System.out.println(b?"登录成功":"登录失败");


        //【授权】
        //判断是否有某个角色
        System.out.println(subject.hasRole("seller"));

        //判断是否有某个权限
        boolean permitted = subject.isPermitted("order-del");
        System.out.println(permitted);

    }


}
```

#### 1.2 计划

- Shiro工作流程：认证授权流程
- SpringBoot整合Shiro（SSM）
- 权限管理案例—基于Shiro提供的JdbcRealm实现（特定的表结构）
- 权限管理案例—基于自定义的Realm实现（自定义的权限设计）