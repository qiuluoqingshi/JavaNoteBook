## 一、总结与计划

#### 1.1 总结

- SpringBoot整合Shiro完成权限管理

- Shiro功能

- |                                                              |
  | ------------------------------------------------------------ |
  | ![image-20200427094830658](imgs\image-20200427094830658.png) |

  - 认证
  - 授权

- SpringBoot项目部署

  - jar包
  - nohup java -jar   *.jar

- layui使用

#### 1.2 计划

- shiro
  - 加密（认证）
  - 授权
    - 过滤器
    - 注解
    - java代码
    - HTML（√）
  - 缓存管理
  - session管理
  - RememberMe
  - 多Realm的配置

## 二、加密

> - 明文-----（加密规则）-----密文
> - 加密规则可以自定义，在项目开发中我们通常使用BASE64和MD5编码方式
>   - BASE64：可反编码的编码方式(对称)
>     - 明文----密文
>     - 密文----明文
>   - MD5: 不可逆的编码方式（非对称）
>     - 明文----密文                                      

- 如果数据库用户的密码存储的密文，Shiro该如何完成验证呢？
- 使用Shiro提供的加密功能，对输入的密码进行加密之后再进行认证。

#### 2.1 加密介绍

|                                                              |
| ------------------------------------------------------------ |
| ![image-20200427115525065](imgs\image-20200427115525065.png) |

#### 2.2 Shiro使用加密认证

- 配置matcher

  ```java
  @Configuration
  public class ShiroConfig {
  
      //...
      @Bean
      public HashedCredentialsMatcher getHashedCredentialsMatcher(){
          HashedCredentialsMatcher matcher = new HashedCredentialsMatcher();
          //matcher就是用来指定加密规则
          //加密方式
          matcher.setHashAlgorithmName("md5");
          //hash次数
          matcher.setHashIterations(1);	//此处的循环次数要与用户注册是密码加密次数一致
          return matcher;
      }
  
      //自定义Realm
      @Bean
      public MyRealm getMyRealm( HashedCredentialsMatcher matcher ){
          MyRealm myRealm = new MyRealm();
          myRealm.setCredentialsMatcher(matcher);
          return myRealm;
      }
  
  	//...
  }
  
  ```

#### 2.3 用户注册密码加密处理

- registh.html

  ```html
  <form action="/user/regist" method="post">
      <p>帐号:<input type="text" name="userName"/></p>
      <p>密码:<input type="text" name="userPwd"/></p>
      <p><input type="submit" value="提交注册"/></p>
  </form>
  ```

  

- UserController

  ```java
  @Controller
  @RequestMapping("user")
  public class UserController {
  
      @Resource
      private UserServiceImpl userService;
  
  
  
      @RequestMapping("/regist")
      public String regist(String userName,String userPwd) {
          System.out.println("------注册");
  
          //注册的时候要对密码进行加密存储
          Md5Hash md5Hash = new Md5Hash(userPwd);
          System.out.println("--->>>"+ md5Hash.toHex());
  
          //加盐加密
          int num = new Random().nextInt(90000)+10000;   //10000—99999
          String salt = num+"";
          Md5Hash md5Hash2 = new Md5Hash(userPwd,salt);
          System.out.println("--->>>"+md5Hash2);
  
          //加盐加密+多次hash
          Md5Hash md5Hash3 = new Md5Hash(userPwd,salt,3);
          System.out.println("--->>>"+md5Hash3);
  
          //SimpleHash hash = new SimpleHash("md5",userPwd,num,3);
  		
          //将用户信息保存到数据库时，保存加密后的密码，如果生成的随机盐，盐也要保存
          
          return "login";
      }
  
  }
  ```

#### 2.4 如果密码进行了加盐处理，则Realm在返回认证数据时需要返回盐

- 在自定义Realm中：

  ```java
  public class MyRealm extends AuthorizingRealm {
      
      @Resource
      private UserDAO userDAO;
      @Resource
      private RoleDAO roleDAO;
      @Resource
      private PermissionDAO permissionDAO;
  
      public String getName() {
          return "myRealm";
      }
  
      /**
       * 获取认证的安全数据（从数据库查询的用户的正确数据）
       */
      protected AuthenticationInfo doGetAuthenticationInfo(AuthenticationToken authenticationToken) throws AuthenticationException {
          //参数authenticationToken就是传递的  subject.login(token)
          // 从token中获取用户名
          UsernamePasswordToken token = (UsernamePasswordToken) authenticationToken;
          String username = token.getUsername();
          //根据用户名，从数据库查询当前用户的安全数据
          User user = userDAO.queryUserByUsername(username);
  
  //        AuthenticationInfo info = new SimpleAuthenticationInfo(
  //                username,           //当前用户用户名
  //                user.getUserPwd(),   //从数据库查询出来的安全密码
  //                getName());
  
          //如果数据库中用户的密码是加了盐的
          AuthenticationInfo info = new SimpleAuthenticationInfo(
                  username,           //当前用户用户名
                  user.getUserPwd(),   //从数据库查询出来的安全密码
                  ByteSource.Util.bytes(user.getPwdSalt()),
                  getName());
  
          return info;
      }
  }
  ```

## 三、退出登录

- 在Shiro过滤器中进行配置，配置logut对应的路径

  ```java
  filterMap.put("/exit","logout");
  ```

- 在页面的“退出”按钮上，跳转到logout对应的url

  ```html
  <a href="exit">退出</a>
  ```

## 四、授权

> 用户登录成功之后，要进行响应的操作就需要有对应的权限；在进行操作之前对权限进行检查—授权
>
> 权限控制通常有两类做法：
>
> - 不同身份的用户登录，我们现在不同的操作菜单（没有权限的菜单不现实）
> - 对所有用户显示所有菜单，当用户点击菜单以后再验证当前用户是否有此权限，如果没有则提示权限不足

#### 4.1 HTML授权

- 在菜单页面只显示当前用户拥有权限操作的菜单

- shiro标签

  ```html
  <shiro:hasPermission name="sys:c:save">
      <dd><a href="javascript:;">入库</a></dd>
  </shiro:hasPermission>
  ```

#### 4.2 过滤器授权

- 在shiro过滤器中对请求的url进行权限设置

  ```java
  filterMap.put("/c_add.html","perms[sys:c:save]");
  
  //设置未授权访问的页面路径—当权限不足时显示此页面
  filter.setUnauthorizedUrl("/lesspermission.html");
  ```

#### 4.3 注解授权

- 配置Spring对Shiro注解的支持：ShiroConfig.java

  ```java
  @Bean
  public DefaultAdvisorAutoProxyCreator getDefaultAdvisorAutoProxyCreator(){
      DefaultAdvisorAutoProxyCreator autoProxyCreator = new DefaultAdvisorAutoProxyCreator();
      autoProxyCreator.setProxyTargetClass(true);
      return autoProxyCreator;
  }
  
  @Bean
  public AuthorizationAttributeSourceAdvisor getAuthorizationAttributeSourceAdvisor( DefaultWebSecurityManager securityManager){
      AuthorizationAttributeSourceAdvisor advisor = new AuthorizationAttributeSourceAdvisor();
      advisor.setSecurityManager(securityManager);
      return advisor;
  }
  ```

- 在请求的控制器添加权限注解

  ```java
  @Controller
  @RequestMapping("customer")
  public class CustomerController {
  
      @RequestMapping("list")
      //如果没有 sys:k:find 权限，则不允许执行此方法
      @RequiresPermissions("sys:k:find")
      //    @RequiresRoles("")
      public String list(){
          System.out.println("----------->查询客户信息");
          return "customer_list";
      }
  
  }
  ```

- 通过全局异常处理，指定权限不足时的页面跳转

  ```java
  @ControllerAdvice
  public class GlobalExceptionHandler {
  
      @ExceptionHandler
      public String doException(Exception e){
          if(e instanceof AuthorizationException){
              return  "lesspermission";
          }
          return null;
      }
  
  }
  ```

#### 4.4 手动授权

- 在代码中进行手动的权限校验

  ```java
  Subject subject = SecurityUtils.getSubject();
  if(subject.isPermitted("sys:k:find")){
      System.out.println("----------->查询客户信息");
      return "customer_list";
  }else{
      return "lesspermission";
  }
  ```

## 五、缓存使用

> 使用Shiro进行权限管理过程中，每次授权都会访问realm中的doGetAuthorizationInfo方法查询当前用户的角色及权限信息，如果系统的用户量比较大则会对数据库造成比较大的压力
>
> Shiro支持缓存以降低对数据库的访问压力（缓存的是授权信息）

#### 5.1 导入依赖

```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-cache</artifactId>
</dependency>

<dependency>
    <groupId>net.sf.ehcache</groupId>
    <artifactId>ehcache</artifactId>
</dependency>

<dependency>
    <groupId>org.apache.shiro</groupId>
    <artifactId>shiro-ehcache</artifactId>
    <version>1.4.0</version>
</dependency>
```

#### 5.2 配置缓存策略

- 在resources目录下创建一个xml文件(ehcache.xml)

```xml
<?xml version="1.0" encoding="UTF-8"?>
<ehcache updateCheck="false" dynamicConfig="false">

    <diskStore path="C:\TEMP" />

    <cache name="users"  timeToLiveSeconds="300"  maxEntriesLocalHeap="1000"/>

    <defaultCache name="defaultCache"
                  maxElementsInMemory="10000"
                  eternal="false"
                  timeToIdleSeconds="120"
                  timeToLiveSeconds="120"
                  overflowToDisk="false"
                  maxElementsOnDisk="100000"
                  diskPersistent="false"
                  diskExpiryThreadIntervalSeconds="120"
                  memoryStoreEvictionPolicy="LRU"/>
            <!--缓存淘汰策略：当缓存空间比较紧张时，我们要存储新的数据进来，就必然要删除一些老的数据
                LRU 最近最少使用
                FIFO 先进先出
                LFU  最少使用
            -->
</ehcache>
```

#### 5.3 加入缓存管理

- ShiroConfig.java

```java
@Bean
public EhCacheManager getEhCacheManager(){
    EhCacheManager ehCacheManager = new EhCacheManager();
    ehCacheManager.setCacheManagerConfigFile("classpath:ehcache.xml");
    return ehCacheManager;
}

@Bean
public DefaultWebSecurityManager getDefaultWebSecurityManager(MyRealm myRealm){
    DefaultWebSecurityManager securityManager = new DefaultWebSecurityManager();
    securityManager.setRealm(myRealm);
    securityManager.setCacheManager(getEhCacheManager());
    return securityManager;
}
```

## 六、session管理

> Shiro进行认证和授权是基于session实现的，Shiro包含了对session的管理

- 如果我们需要对session进行管理

  - 自定义session管理器
  - 将自定义的session管理器设置给SecurityManager

- 配置自定义SessionManager：ShiroConfig.java

  ```java
  @Bean
  public DefaultWebSessionManager getDefaultWebSessionManager(){
      DefaultWebSessionManager sessionManager = new DefaultWebSessionManager();
      System.out.println("----------"+sessionManager.getGlobalSessionTimeout()); // 1800000
      //配置sessionManager
      sessionManager.setGlobalSessionTimeout(5*60*1000);
      return sessionManager;
  }
  
  @Bean
  public DefaultWebSecurityManager getDefaultWebSecurityManager(MyRealm myRealm){
      DefaultWebSecurityManager securityManager = new DefaultWebSecurityManager();
      securityManager.setRealm(myRealm);
      securityManager.setCacheManager(getEhCacheManager());
      securityManager.setSessionManager(getDefaultWebSessionManager());
      return securityManager;
  }
  ```

  