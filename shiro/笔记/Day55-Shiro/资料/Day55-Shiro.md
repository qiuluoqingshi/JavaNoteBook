## 判断用户是否是游客身份，如果是游客身份则显示此标签内容一、Shiro认证流程

|                                                              |
| ------------------------------------------------------------ |
| ![image-20200424104531685](imgs\image-20200424104531685.png) |

## 二、SpringBoot应用整合Shiro

- JavaSE应用中使用
- web应用中使用
  - SSM整合Shiro(配置多，用的少)
  - SpringBoot应用整合Shiro

#### 2.1 创建SpringBoot应用

- lombok
- spring web
- thymeleaf

#### 2.2 整合Druid和MyBatis

- 依赖

  ```xml
  <!-- druid starter -->
  <dependency>
      <groupId>com.alibaba</groupId>
      <artifactId>druid-spring-boot-starter</artifactId>
      <version>1.1.10</version>
  </dependency>
   <!--mysql -->
  <dependency>
      <groupId>mysql</groupId>
      <artifactId>mysql-connector-java</artifactId>
      <version>5.1.47</version>
  </dependency>
  <!-- mybatis -->
  <dependency>
      <groupId>org.mybatis.spring.boot</groupId>
      <artifactId>mybatis-spring-boot-starter</artifactId>
      <version>2.1.0</version>
  </dependency>
  ```

- 配置

  ```yaml
  spring:
    datasource:
      druid:
        url: jdbc:mysql://47.96.11.185:3306/test
        # MySQL如果是8.x   com.mysql.cj.jdbc.Driver
        driver-class-name: com.mysql.jdbc.Driver
        username: root
        password: admin123
        initial-size: 1
        min-idle: 1
        max-active: 20
  mybatis:
    mapper-locations: classpath:mappers/*Mapper.xml
    type-aliases-package: com.qfedu.springbootssm.beans
  ```

#### 2.3 整合Shiro

- 导入依赖

  ```xml
  <dependency>
      <groupId>org.apache.shiro</groupId>
      <artifactId>shiro-spring</artifactId>
      <version>1.4.1</version>
  </dependency>
  ```

- Shiro配置（java配置方式）

  - SpringBoot默认没有提供对Shiro的自动配置

  ```java
  @Configuration
  public class ShiroConfig {
  
      @Bean
      public IniRealm getIniRealm(){
          IniRealm iniRealm = new IniRealm("classpath:shiro.ini");
          return iniRealm;
      }
  
      @Bean
      public DefaultWebSecurityManager getDefaultWebSecurityManager(IniRealm iniRealm){
          DefaultWebSecurityManager securityManager = new DefaultWebSecurityManager();
          //securityManager要完成校验，需要realm
          securityManager.setRealm(iniRealm);
          return securityManager;
      }
  
      @Bean
      public ShiroFilterFactoryBean shiroFilter(DefaultWebSecurityManager securityManager){
          ShiroFilterFactoryBean filter = new ShiroFilterFactoryBean();
          //过滤器就是shiro就行权限校验的核心，进行认证和授权是需要SecurityManager的
          filter.setSecurityManager(securityManager);
  
          //设置shiro的拦截规则
          // anon   匿名用户可访问
          // authc  认证用户可访问
          // user   使用RemeberMe的用户可访问
          // perms  对应权限可访问
          // role   对应的角色可访问
          Map<String,String> filterMap = new HashMap<>();
          filterMap.put("/","anon");
          filterMap.put("/login.html","anon");
          filterMap.put("/regist.html","anon");
          filterMap.put("/user/login","anon");
          filterMap.put("/user/regist","anon");
          filterMap.put("/static/**","anon");
          filterMap.put("/**","authc");
  
          filter.setFilterChainDefinitionMap(filterMap);
          filter.setLoginUrl("/login.html");
          //设置未授权访问的页面路径
          filter.setUnauthorizedUrl("/login.html");
          return filter;
      }
  
  
  }
  ```

- 认证测试

  - UserServiceImpl.java

  ```java
  @Service
  public class UserServiceImpl {
  
      public void checkLogin(String userName,String userPwd) throws Exception{
          Subject subject = SecurityUtils.getSubject();
          UsernamePasswordToken token = new UsernamePasswordToken(userName,userPwd);
          subject.login(token);
      }
  
  }
  ```

  - UserController.java

  ```java
  @Controller
  @RequestMapping("user")
  public class UserController {
  
      @Resource
      private UserServiceImpl userService;
  
      @RequestMapping("login")
      public String login(String userName,String userPwd){
          try {
              userService.checkLogin(userName,userPwd);
              System.out.println("------登录成功！");
              return "index";
          } catch (Exception e) {
              System.out.println("------登录失败！");
              return "login";
          }
  
      }
  }
  ```
  
- login.html
  
```html
  <!DOCTYPE html>
  <html lang="en">
  <head>
      <meta charset="UTF-8">
      <title>Title</title>
  </head>
  <body>
      login
      <hr/>
      <form action="user/login">
          <p>帐号:<input type="text" name="userName"/></p>
          <p>密码:<input type="text" name="userPwd"/></p>
          <p><input type="submit" value="登录"/></p>
      </form>
  </body>
  </html>
  ```

## 三、SpringBoot应用整合Shiro—案例（JdbcRealm）

#### 3.1 JdbcRealm介绍

|                                                              |
| ------------------------------------------------------------ |
| ![image-20200424145508674](imgs\image-20200424145508674.png) |

- 如果使用JdbcRealm，则必须提供JdbcRealm所需的表结构(权限设计)

|                                                              |
| ------------------------------------------------------------ |
| ![image-20200424152851569](imgs\image-20200424152851569.png) |

#### 3.2 JdbcRealm规定的表结构

- 用户信息表： users

  ```sql
  create table users(
      id int primary key auto_increment,
      username varchar(60) not null unique,
      password varchar(20) not null,
      password_salt varchar(20)
  );
  
  insert into users(username,password) values('zhangsan','123456');
  insert into users(username,password) values('lisi','123456');
  insert into users(username,password) values('wangwu','123456');
  insert into users(username,password) values('zhaoliu','123456');
  insert into users(username,password) values('chenqi','123456');
  ```

- 角色信息表： user_roles

  ```sql
  create table user_roles(
  	id int primary key auto_increment,
      username varchar(60) not null,
      role_name varchar(100) not null
  );
  
  -- admin系统管理员
  -- cmanager 库管人员
  -- xmanager 销售人员
  -- kmanager 客服人员
  -- zmanager 行政人员 
  insert into user_roles(username,role_name) values('zhangsan','admin');
  insert into user_roles(username,role_name) values('lisi','cmanager');
  insert into user_roles(username,role_name) values('wangwu','xmanager');
  insert into user_roles(username,role_name) values('zhaoliu','kmanager');
  insert into user_roles(username,role_name) values('chenqi','zmanager');
  
  ```

- 权限信息表：roles_permissions

  ```sql
  create table roles_permissions(
  	id int primary key auto_increment,
      role_name varchar(100) not null,
      permission varchar(100) not null
  );
  
  -- 权限  sys:c:save   sys:c:delete...
  -- 管理员具备所有权限
  insert into roles_permissions(role_name,permission) values("admin","*");
  -- 库管人员
  insert into roles_permissions(role_name,permission) values("cmanager","sys:c:save");		
  insert into roles_permissions(role_name,permission) values("cmanager","sys:c:delete");
  insert into roles_permissions(role_name,permission) values("cmanager","sys:c:update");
  insert into roles_permissions(role_name,permission) values("cmanager","sys:c:find");
  -- 销售人员
  insert into roles_permissions(role_name,permission) values("xmanager","sys:c:find");
  insert into roles_permissions(role_name,permission) values("xmanager","sys:x:save");
  insert into roles_permissions(role_name,permission) values("xmanager","sys:x:delete");
  insert into roles_permissions(role_name,permission) values("xmanager","sys:x:update");
  insert into roles_permissions(role_name,permission) values("xmanager","sys:x:find");
  
  insert into roles_permissions(role_name,permission) values("xmanager","sys:k:save");
  insert into roles_permissions(role_name,permission) values("xmanager","sys:k:delete");
  insert into roles_permissions(role_name,permission) values("xmanager","sys:k:update");
  insert into roles_permissions(role_name,permission) values("xmanager","sys:k:find");
  -- 客服人员
  insert into roles_permissions(role_name,permission) values("kmanager","sys:k:find");
  insert into roles_permissions(role_name,permission) values("kmanager","sys:k:update");
  -- 新增人员
  insert into roles_permissions(role_name,permission) values("zmanager","sys:*:find");
  ```

#### 3.3 SpringBoot整合Shiro

- 创建SpringBoot应用

- 整合Druid和MyBatis

- 整合shiro

  - 添加依赖

    ```xml
    <dependency>
        <groupId>org.apache.shiro</groupId>
        <artifactId>shiro-spring</artifactId>
        <version>1.4.1</version>
    </dependency>
    ```

    

  - 配置Shiro

    ```java
    @Configuration
    public class ShiroConfig {
    
        @Bean
        public JdbcRealm getJdbcRealm(DataSource dataSource){
            JdbcRealm jdbcRealm = new JdbcRealm();
            //JdbcRealm会自行从数据库查询用户及权限数据（数据库的表结构要符合JdbcRealm的规范）
            jdbcRealm.setDataSource(dataSource);
            //JdbcRealm默认开启认证功能，需要手动开启授权功能
            jdbcRealm.setPermissionsLookupEnabled(true);
            return  jdbcRealm;
        }
    
        @Bean
        public DefaultWebSecurityManager getDefaultWebSecurityManager(JdbcRealm jdbcRealm){
            DefaultWebSecurityManager securityManager = new DefaultWebSecurityManager();
            securityManager.setRealm(jdbcRealm);
            return securityManager;
        }
    
        @Bean
        public ShiroFilterFactoryBean shiroFilter(DefaultWebSecurityManager securityManager){
            ShiroFilterFactoryBean filter = new ShiroFilterFactoryBean();
            //过滤器就是shiro就行权限校验的核心，进行认证和授权是需要SecurityManager的
            filter.setSecurityManager(securityManager);
    
            Map<String,String> filterMap = new HashMap<>();
            filterMap.put("/","anon");
            filterMap.put("/login.html","anon");
            filterMap.put("/regist.html","anon");
            filterMap.put("/user/login","anon");
            filterMap.put("/user/regist","anon");
            filterMap.put("/static/**","anon");
            filterMap.put("/**","authc");
    
            filter.setFilterChainDefinitionMap(filterMap);
            filter.setLoginUrl("/login.html");
            //设置未授权访问的页面路径
            filter.setUnauthorizedUrl("/login.html");
            return filter;
        }
    
    }
    ```

  #### 3.4 认证功能测试

  略

## 四、Shiro的标签使用

> 当用户认证进入到主页面之后，需要显示用户信息及当前用户的权限信息；Shiro就提供了一套标签用于在页面来进行权限数据的呈现

- Shiro提供了可供JSP使用的标签以及Thymeleaf中标签

  - JSP页面中引用：

    ```jsp
    <%@ taglib prefix="shiro" uri="http://shiro.apache.org/tags" %>
    ```

  - Thymeleaf模版中引用：

    - 在pom.xml文件中导入thymeleaf模版对shiro标签支持的依赖

    ```xml
    <dependency>
        <groupId>com.github.theborakompanioni</groupId>
        <artifactId>thymeleaf-extras-shiro</artifactId>
        <version>2.0.0</version>
    </dependency>
    ```

    - 在ShiroConfig中配置Shiro的

    ```java
    @Configuration
    public class ShiroConfig {
    
        @Bean
        public ShiroDialect getShiroDialect(){
            return new ShiroDialect();
        }
        //...
    }
    ```

    - Thymeleaf模版中引入shiro的命名空间

    ```html
    <html xmlns:th="http://www.thymeleaf.org"
          xmlns:shiro="http://www.pollix.at/thymeleaf/shiro">
        ...
    </html>
    ```

#### 常用标签

- guest，判断用户是否是游客身份，如果是游客身份则显示此标签内容

  ```html
  <shiro:guest>
      欢迎游客访问，<a href="login.html">登录</a>
  </shiro:guest>
  ```

- user，判断用户是否是认证身份，如果是认证身份则显示此标签内容

- principal，获取当前登录用户名

  ```html
  <shiro:user>
      用户[<shiro:principal/>]欢迎您！
  </shiro:user>
  ```

- notAuthenticated/authenticated

- hasRole

- hasPermission

  ```html
  <!DOCTYPE html>
  <html xmlns:th="http://www.thymeleaf.org"
        xmlns:shiro="http://www.pollix.at/thymeleaf/shiro">
  <head>
      <meta charset="UTF-8">
      <title>Title</title>
  </head>
  <body>
      index
      <hr/>
      <shiro:guest>
          欢迎游客访问，<a href="login.html">登录</a>
      </shiro:guest>
      <shiro:user>
          用户[<shiro:principal/>]欢迎您！
          当前用户为<shiro:hasRole name="admin">超级管理员</shiro:hasRole>
                  <shiro:hasRole name="cmanager">仓管人员</shiro:hasRole>
                  <shiro:hasRole name="xmanager">销售人员</shiro:hasRole>
                  <shiro:hasRole name="kmanager">客服人员</shiro:hasRole>
                  <shiro:hasRole name="zmanager">行政人员</shiro:hasRole>
      </shiro:user>
  
      <hr/>
      仓库管理
      <ul>
          <shiro:hasPermission name="sys:c:save"><li><a href="#">入库</a></li></shiro:hasPermission>
          <shiro:hasPermission name="sys:c:delete"><li><a href="#">出库</a></li></shiro:hasPermission>
          <shiro:hasPermission name="sys:c:update"><li><a href="#">修改</a></li></shiro:hasPermission>
          <shiro:hasPermission name="sys:c:find"><li><a href="#">查询</a></li></shiro:hasPermission>
      </ul>
  
      订单管理
      <ul>
          <shiro:hasPermission name="sys:x:save"><li><a href="#">添加订单</a></li></shiro:hasPermission>
          <shiro:hasPermission name="sys:x:delete"><li><a href="#">删除订单</a></li></shiro:hasPermission>
          <shiro:hasPermission name="sys:x:update"><li><a href="#">修改订单</a></li></shiro:hasPermission>
          <shiro:hasPermission name="sys:x:find"><li><a href="#">查询订单</a></li></shiro:hasPermission>
      </ul>
  
      客户管理
      <ul>
          <shiro:hasPermission name="sys:k:save"><li><a href="#">添加客户</a></li></shiro:hasPermission>
          <shiro:hasPermission name="sys:k:delete"><li><a href="#">删除客户</a></li></shiro:hasPermission>
          <shiro:hasPermission name="sys:k:update"><li><a href="#">修改客户</a></li></shiro:hasPermission>
          <shiro:hasPermission name="sys:k:find"><li><a href="#">查询客户</a></li></shiro:hasPermission>
      </ul>
  
  
  </body>
  </html>
  ```

  

## 作业

完成SpringBoot整合Shiro，使用JdbcRealm完成4S店权限管理案例（前端需要实现Bootstrap|layui完成折叠菜单效果），完成之后项目部署到云服务器，然后将访问地址给辅导老师。