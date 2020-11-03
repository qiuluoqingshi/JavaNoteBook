## 一、总结与计划

#### 1.1 总结

- 加密处理
- 授权
  - HTML（shiro标签）
  - 过滤器
  - 注解
  - 代码
- 缓存管理
  - 缓存的授权信息
- session管理

#### 1.2 计划

- Shiro
  - RememberMe
  - 多Realm配置
- 前后端分离（vue）

#### 1.3 解疑

- 如何避免登录页面显示在页面框架中？

- 在登录页面添如下JS代码：

  ```html
  <script type="text/javascript">
      //页面框架
      if(window.top != window.self){
          window.top.location = window.self.location;
      }
  </script>
  ```

## 二、RememberMe

>将用户对页面访问的权限分为三个级别：
>
>- 未认证—可访问的页面—(陌生人)—问候
>  - login.html、regist.html
>- 记住我—可访问的页面—(前女友)—朋友间的拥抱
>  - info.html
>- 已认证—可访问的页面—(现女友)—牵手
>  - 转账.html

#### 2.1 在过滤器中设置“记住我”可访问的url

```java
// anon     表示未认证可访问的url
// user     表示记住我可访问的url（已认证也可以访问）
//authc     表示已认证可访问的url
//perms		表示必须具备指定的权限才可访问
//logout	表示指定退出的url
filterMap.put("/","anon");
filterMap.put("/index.html","user");
filterMap.put("/login.html","anon");
filterMap.put("/regist.html","anon");
filterMap.put("/user/login","anon");
filterMap.put("/user/regist","anon");
filterMap.put("/layui/**","anon");
filterMap.put("/**","authc");
filterMap.put("/c_add.html","perms[sys:c:save]");
filterMap.put("/exit","logout");
```

#### 2.2  在ShiroConfig.java中配置基于cookie的rememberMe管理器

```java
@Bean
public CookieRememberMeManager cookieRememberMeManager(){
    CookieRememberMeManager rememberMeManager = new CookieRememberMeManager();
   
    //cookie必须设置name
    SimpleCookie cookie = new SimpleCookie("rememberMe");
    cookie.setMaxAge(30*24*60*60);
    
    rememberMeManager.setCookie(cookie);
    return  rememberMeManager;
}
@Bean
public DefaultWebSecurityManager getDefaultWebSecurityManager(MyRealm myRealm){
    DefaultWebSecurityManager securityManager = new DefaultWebSecurityManager();
    securityManager.setRealm(myRealm);
    securityManager.setCacheManager(getEhCacheManager());
    securityManager.setSessionManager(getDefaultWebSessionManager());
    //设置remember管理器
    securityManager.setRememberMeManager(cookieRememberMeManager());
    return securityManager;
}
```

#### 2.3 登录认证时设置token“记住我”

- 登录页面

```html
<form action="/user/login" method="post">
    <p>帐号:<input type="text" name="userName"/></p>
    <p>密码:<input type="text" name="userPwd"/></p>
    <p>记住我:<input type="checkbox" name="rememberMe"/></p>
    <p><input type="submit" value="登录"/></p>
</form>
```

- 控制器

```java
@Controller
@RequestMapping("user")
public class UserController {

    @Resource
    private UserServiceImpl userService;

    @RequestMapping("login")
    public String login(String userName,String userPwd,boolean rememberMe){
        try {
            userService.checkLogin(userName,userPwd,rememberMe);
            System.out.println("------登录成功！");
            return "index";
        } catch (Exception e) {
            System.out.println("------登录失败！");
            return "login";
        }

    }
    
    //...
}
```

- service

```java
@Service
public class UserServiceImpl {

    public void checkLogin(String userName, String userPwd,boolean rememberMe) throws Exception {
        //Shiro进行认证 ——入口
        Subject subject = SecurityUtils.getSubject();
        UsernamePasswordToken token = new UsernamePasswordToken(userName,userPwd);
        token.setRememberMe(rememberMe);
        subject.login(token);
    }
}
```

## 三、Shiro多Realm配置

#### 3.1 使用场景

- 当shiro进行权限管理，数据来自于不同的数据源时，我们可以给SecurityManager配置多个Realm

|                                                              |
| ------------------------------------------------------------ |
| ![image-20200428112627378](D:\NZ1902\Day58-Shiro&前端分离\资料\imgs\image-20200428112627378.png) |

#### 3.2 多个Realm的处理方式

###### 3.2.1 链式处理

- 多个Realm依次进行认证

###### 3.2.2 分支处理

- 根据不同的条件从多个Realm中选择一个进行认证处理

#### 3.3 多Realm配置（链式处理）

- 定义多个Realm

  - UserRealm

    ```java
    public class UserRealm extends AuthorizingRealm {
    
        Logger logger = LoggerFactory.getLogger(UserRealm.class);
    
        @Override
        public String getName() {
            return "UserRealm";
        }
    
        @Override
        protected AuthorizationInfo doGetAuthorizationInfo(PrincipalCollection principalCollection) {
            return null;
        }
    
        @Override
        protected AuthenticationInfo doGetAuthenticationInfo(AuthenticationToken authenticationToken) throws AuthenticationException {
            logger.info("--------------------------------UserRealm");
            //从token中获取username
            UsernamePasswordToken token = (UsernamePasswordToken) authenticationToken;
            String username = token.getUsername();
            //根据username从users表中查询用户信息
    
            SimpleAuthenticationInfo info = new SimpleAuthenticationInfo(username,"123456",getName());
            return info;
        }
    }
    ```

  - ManagerRealm

    ```java
    public class ManagerRealm extends AuthorizingRealm {
    
        Logger logger = LoggerFactory.getLogger(ManagerRealm.class);
    
        @Override
        public String getName() {
            return "ManagerRealm";
        }
    
        @Override
        protected AuthorizationInfo doGetAuthorizationInfo(PrincipalCollection principalCollection) {
            return null;
        }
    
        @Override
        protected AuthenticationInfo doGetAuthenticationInfo(AuthenticationToken authenticationToken) throws AuthenticationException {
            logger.info("--------------------------------ManagerRealm");
            //从token中获取username
            UsernamePasswordToken token = (UsernamePasswordToken) authenticationToken;
            String username = token.getUsername();
            //根据username从吗managers表中查询用户信息
    
            SimpleAuthenticationInfo info = new SimpleAuthenticationInfo(username,"222222",getName());
            return info;
        }
    }
    ```

- 在ShiroConfig.java中为SecurityManager配置多个Realm

  ```java
  @Configuration
  public class ShiroConfig {
  
      @Bean
      public UserRealm userRealm(){
          UserRealm userRealm = new UserRealm();
          return  userRealm;
      }
  
      @Bean
      public ManagerRealm managerRealm(){
          ManagerRealm managerRealm = new ManagerRealm();
          return managerRealm;
      }
  
      @Bean
      public DefaultWebSecurityManager getDefaultWebSecurityManager(){
          DefaultWebSecurityManager securityManager = new DefaultWebSecurityManager();
          
          //securityManager中配置多个realm
          Collection<Realm> realms = new ArrayList<>();
          realms.add(userRealm());
          realms.add(managerRealm());
  
          securityManager.setRealms(realms);
          return securityManager;
      }
  
     //...
  
  }
  
  ```

- 测试代码：
  
  - login.html
  
    ```html
    <form action="user/login" method="post">
        <p>帐号：<input type="text" name="userName"/></p>
        <p>密码：<input type="text" name="userPwd"/></p>
        <p><input type="radio" name="loginType" value="User"/>普通用户
            <input type="radio" name="loginType" value="Manager"/>管理员</p>
    
        <p><input type="submit" value="登录"/></p>
    </form>
    ```
  
  - UserController.java
  
    ```java
    @Controller
    @RequestMapping("user")
    public class UserController {
        Logger logger = LoggerFactory.getLogger(UserController.class);
    
        @RequestMapping("login")
        public String login(String userName,String userPwd, String loginType){
            logger.info("~~~~~~~~~~~~~UserController-login");
            try{
                UsernamePasswordToken token = new UsernamePasswordToken(userName,userPwd);
                Subject subject = SecurityUtils.getSubject();
                subject.login(token);
                return "index";
            }catch (Exception e){
                return "login";
            }
    
        }
    
    }
    ```
  
    

#### 3.4 Shiro认证处理源码分析

|                                                              |
| ------------------------------------------------------------ |
| ![image-20200428150707431](imgs\image-20200428150707431.png) |

```java
protected AuthenticationInfo doAuthenticate(AuthenticationToken authenticationToken) throws AuthenticationException {
        this.assertRealmsConfigured();
        Collection<Realm> realms = this.getRealms();
    	
    	// this.doMultiRealmAuthentication(realms, authenticationToken);中的realms参数就是认证会执行的Realm
        return realms.size() == 1 ? this.doSingleRealmAuthentication((Realm)realms.iterator().next(), authenticationToken) : this.doMultiRealmAuthentication(realms, authenticationToken);
    }
```

#### 3.5 多Realm配置（分支处理）

> 根据不同的条件执行不同的Realm

- 流程分析

  |                                                              |
  | ------------------------------------------------------------ |
  | ![image-20200428155141159](imgs\image-20200428155141159.png) |

- 实现案例：用户不同身份登录执行不同的Realm

  - 自定义Realm(UserRealm\ManagerRealm)

    - 当在登录页面选择“普通用户”登录，则执行UserRealm的认证
    - 当在登录页面选择“管理员”登录，则执行ManagerRealm的认证

  - Realm的声明及配置

  - 自定义Token

    ```java
    public class MyToken extends UsernamePasswordToken {
    
        private String loginType;
    
        public MyToken(String userName,String userPwd, String loginType) {
            super(userName,userPwd);
            this.loginType = loginType;
        }
    
        public String getLoginType() {
            return loginType;
        }
    
        public void setLoginType(String loginType) {
            this.loginType = loginType;
        }
    }
    ```

  - 自定义认证器

    ```java
    public class MyModularRealmAuthenticator extends ModularRealmAuthenticator {
    
        Logger logger = LoggerFactory.getLogger(MyModularRealmAuthenticator.class);
    
        @Override
        protected AuthenticationInfo doAuthenticate(AuthenticationToken authenticationToken) throws AuthenticationException {
            logger.info("------------------------------MyModularRealmAuthenticator");
    
            this.assertRealmsConfigured();
            Collection<Realm> realms = this.getRealms();
    
            MyToken token = (MyToken) authenticationToken;
            String loginType = token.getLoginType(); // User
            logger.info("------------------------------loginType:"+loginType);
    
            Collection<Realm> typeRealms = new ArrayList<>();
            for(Realm realm:realms){
                if(realm.getName().startsWith(loginType)){  //UserRealm
                    typeRealms.add(realm);
                }
            }
    
           if(typeRealms.size()==1){
               return this.doSingleRealmAuthentication((Realm)typeRealms.iterator().next(), authenticationToken);
           }else{
               return this.doMultiRealmAuthentication(typeRealms, authenticationToken);
           }
    
        }
    
    }
    ```

  - 配置自定义认证器

    ```java
    @Configuration
    public class ShiroConfig {
    
        @Bean
        public UserRealm userRealm(){
            UserRealm userRealm = new UserRealm();
            return  userRealm;
        }
    
        @Bean
        public ManagerRealm managerRealm(){
            ManagerRealm managerRealm = new ManagerRealm();
            return managerRealm;
        }
    
        @Bean
        public MyModularRealmAuthenticator myModularRealmAuthenticator(){
            MyModularRealmAuthenticator myModularRealmAuthenticator = new MyModularRealmAuthenticator();
            return myModularRealmAuthenticator;
        }
    
        @Bean
        public DefaultWebSecurityManager getDefaultWebSecurityManager(){
            DefaultWebSecurityManager securityManager = new DefaultWebSecurityManager();
            //配置自定义认证器(放在realms设置之前)
            securityManager.setAuthenticator(myModularRealmAuthenticator());
    
            //securityManager中配置多个realm
            Collection<Realm> realms = new ArrayList<>();
            realms.add(userRealm());
            realms.add(managerRealm());
    
            securityManager.setRealms(realms);
            return securityManager;
        }
    
        //...
    
    }
    ```

  - 测试：控制器接受数据进行认证

    - login.html

    ```html
    <form action="user/login" method="post">
        <p>帐号：<input type="text" name="userName"/></p>
        <p>密码：<input type="text" name="userPwd"/></p>
        <p><input type="radio" name="loginType" value="User" checked/>普通用户
        <input type="radio" name="loginType" value="Manager"/>管理员</p>
    
        <p><input type="submit" value="登录"/></p>
    </form>
    ```

    - UserController.java

    ```java
    @Controller
    @RequestMapping("user")
    public class UserController {
        Logger logger = LoggerFactory.getLogger(UserController.class);
    
        @RequestMapping("login")
        public String login(String userName,String userPwd, String loginType){
            logger.info("~~~~~~~~~~~~~UserController-login");
            try{
                //UsernamePasswordToken token = new UsernamePasswordToken(userName,userPwd);
                MyToken token = new MyToken(userName,userPwd,loginType);
                Subject subject = SecurityUtils.getSubject();
                subject.login(token);
                return "index";
            }catch (Exception e){
                return "login";
            }
    
        }
    
    }
    ```

## 四、单体项目开发技术清单

#### 4.1 JSP应用

- View  JSP（Java Server Page）

- Control   Servlet

- Model  JDBC（Java Database Connection）
- 第一阶段的项目：JSP/Servlet+JDBC

#### 4.2 SSM

- View  JSP
- Control   SpringMVC
- Model    MyBatis
- 第二阶段项目：JSP+SSM

#### 4.3 SpringBoot

- View  Thymeleaf
- Control  SpringMVC
- Model  MyBatis/tkMapper
- 第三阶段练习项目：thymeleaf+SpringBoot(SSM)

单体项目：项目的前端页面与服务端的代码在同一个项目中（部署在同一个服务器上）

|                                                              |
| ------------------------------------------------------------ |
| ![image-20200428165545814](imgs\image-20200428165545814.png) |



