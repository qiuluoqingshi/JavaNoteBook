## 一、总结与计划

#### 1.1 上周总结

- SpringBoot
  - 基于SpringBoot整合SSM项目开发
  - 自定义starter(理解流程)
  - Thymeleaf
  - tkMapper
    - 单表操作
    - 逆向工程
- Shiro
  - 权限管理
    - RBAC
    - 安全框架
  - Shiro核心功能
    - 认证 ca
    - 授权 za
    - 会话管理
    - 加密处理
    - 缓存管理
  - Shiro核心组件
    - Subject
      - 认证：subject.login(token)
      - 授权：hasRole, isPermitted
    - SecurityManager
      - 认证器
      - 授权器
    - Realm
  - SpringBoot项目整合Shiro
    - 整合SSM
    - 整合Shiro
      - 依赖
      - 配置（Java方式配置）
  - Shiro的常用标签

#### 1.2 本周计划

- shiro
- 前后端分离
  - vue
  - axios
  - RESTFul
- SpringBoot整合Swagger

## 二、Shiro认证流程回顾

> 结合上周的案例（SpringBoot整合Shiro案例—JdbcRealm）复习认证流程

- subject调用login方法，将包含用户和密码的token传递给SecurityManager
- SecurityManager就会调用认证器（Authenticator）进行认证
- Authenticator就将token传递给绑定的Realm，在Realm中进行用户的认证检查；如果认证通过则正常执行，如果认证不通过则抛出认证异常

## 三、SpringBoot整合Shiro完成权限管理案例—自定义Realm

> 使用JdbcRealm可以完成用户权限管理，但是我们必须提供JdbcRealm规定的数据表结构；如果在我们的项目开发中 ，这个JdbcRealm规定的数据表结构不能满足开发需求，该如何处理呢？
>
> - 自定义数据库表结构
> - 自定义Realm实现认证和授权

|                                                              |
| ------------------------------------------------------------ |
| ![image-20200426143303884](imgs\image-20200426143303884.png) |

#### 3.1 数据库设计

- RBAC基于角色的访问控制

  ```sql
  -- 用户信息表
  create table tb_users(
  	user_id int primary key auto_increment,
  	username varchar(60) not null unique,
  	password varchar(20) not null,
    password_salt varchar(60)
  );
  
  insert into tb_users(username,password) values('zhangsan','123456');
  insert into tb_users(username,password) values('lisi','123456');
  insert into tb_users(username,password) values('wangwu','123456');
  insert into tb_users(username,password) values('zhaoliu','123456');
  insert into tb_users(username,password) values('chenqi','123456');
  
  -- 角色信息表
  create table tb_roles(
  	role_id int primary key auto_increment,
  	role_name varchar(60) not null
  );
  
  insert into tb_roles(role_name) values('admin');
  insert into tb_roles(role_name) values('cmanager');  -- 仓管
  insert into tb_roles(role_name) values('xmanager');  --  销售
  insert into tb_roles(role_name) values('kmanager');  -- 客服
  insert into tb_roles(role_name) values('zmanager');  -- 行政
  
  -- 权限信息表
  create table tb_permissions(
  	permission_id int primary key auto_increment,		-- 1
  	permission_code varchar(60) not null,						-- sys:c:find
  	permission_name varchar(60)											-- 仓库查询
  );
  insert into tb_permissions(permission_code,permission_name) values('sys:c:save','入库');
  insert into tb_permissions(permission_code,permission_name) values('sys:c:delete','出库');
  insert into tb_permissions(permission_code,permission_name) values('sys:c:update','修改');
  insert into tb_permissions(permission_code,permission_name) values('sys:c:find','查询');
  
  insert into tb_permissions(permission_code,permission_name) values('sys:x:save','新增订单');
  insert into tb_permissions(permission_code,permission_name) values('sys:x:delete','删除订单');
  insert into tb_permissions(permission_code,permission_name) values('sys:x:update','修改订单');
  insert into tb_permissions(permission_code,permission_name) values('sys:x:find','查询订单');
  
  
  insert into tb_permissions(permission_code,permission_name) values('sys:k:save','新增客户');
  insert into tb_permissions(permission_code,permission_name) values('sys:k:delete','删除客户');
  insert into tb_permissions(permission_code,permission_name) values('sys:k:update','修改客户');
  insert into tb_permissions(permission_code,permission_name) values('sys:k:find','查询客户');
  
  -- 用户角色表
  create table tb_urs(
  	uid int not null,
  	rid int not null
  	-- primary key(uid,rid),
  	-- constraint FK_user foreign key(uid) references tb_users(user_id),
  	-- constraint FK_role foreign key(rid) references tb_roles(role_id)
  );
  insert into tb_urs(uid,rid) values(1,1);
  insert into tb_urs(uid,rid) values(1,2);
  insert into tb_urs(uid,rid) values(1,3);
  insert into tb_urs(uid,rid) values(1,4);
  insert into tb_urs(uid,rid) values(1,5);
  
  insert into tb_urs(uid,rid) values(2,2);
  insert into tb_urs(uid,rid) values(3,3);
  insert into tb_urs(uid,rid) values(4,4);
  insert into tb_urs(uid,rid) values(5,5);
  
  -- 角色权限表
  create table tb_rps(
  	rid int not null,
  	pid int not null
  );
  -- 给仓管角色分配权限
  insert into tb_rps(rid,pid) values(2,1);
  insert into tb_rps(rid,pid) values(2,2);
  insert into tb_rps(rid,pid) values(2,3);
  insert into tb_rps(rid,pid) values(2,4);
  -- 给销售角色分配权限
  insert into tb_rps(rid,pid) values(3,4);
  insert into tb_rps(rid,pid) values(3,5);
  insert into tb_rps(rid,pid) values(3,6);
  insert into tb_rps(rid,pid) values(3,7);
  insert into tb_rps(rid,pid) values(3,8);
  insert into tb_rps(rid,pid) values(3,9);
  insert into tb_rps(rid,pid) values(3,10);
  insert into tb_rps(rid,pid) values(3,11);
  insert into tb_rps(rid,pid) values(3,12);
  -- 给客服角色分配权限
  insert into tb_rps(rid,pid) values(4,11);
  insert into tb_rps(rid,pid) values(4,12);
  -- 给行政角色分配权限
  insert into tb_rps(rid,pid) values(5,4);
  insert into tb_rps(rid,pid) values(5,8);
  insert into tb_rps(rid,pid) values(5,12);
  ```

#### 3.2 DAO实现

> - Shiro进行认证需要用户信息：
>   - 根据用户名查询用户信息
>
> - Shiro进行授权管理需要当前用户的角色和权限
>
>   - 根据用户名查询当前用户的角色列表（3张表连接查询）
>
>   - 根据用户名查询当前用户的权限列表（5张表连接查询）

###### 3.2.1 创建SpringBoot项目，整合MyBatis

###### 3.2.2 根据用户名查询用户信息

- 创建BeanBean

```java
@Data
public class User {
    private Integer userId;
    private String userName;
    private String userPwd;
    private String pwdSalt;
}
```

- 创建DAO

```JAVA
public interface UserDAO {
    public User queryUserByUsername(String username) throws  Exception;
}
```

- 映射配置

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE mapper
        PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN"
        "http://mybatis.org/dtd/mybatis-3-mapper.dtd">
<mapper namespace="com.qfedu.shiro4.dao.UserDAO">

    <resultMap id="userMap" type="User">
        <id column="user_id" property="userId"></id>
        <result column="username" property="userName"/>
        <result column="password" property="userPwd"/>
        <result column="password_salt" property="pwdSalt"/>
    </resultMap>

    <select id="queryUserByUsername" resultMap="userMap">
        select * from tb_users
        where username=#{username}
    </select>

</mapper>
```



###### 3.2.3 根据用户名查询角色名列表

- 创建DAO

```JAVA
public interface RoleDAO {
    public Set<String>  queryRoleNamesByUsername(String username) throws Exception;
}
```

- 映射配置

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE mapper
        PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN"
        "http://mybatis.org/dtd/mybatis-3-mapper.dtd">
<mapper namespace="com.qfedu.shiro4.dao.RoleDAO">

    <select id="queryRoleNamesByUsername" resultSets="java.util.Set" resultType="string">
        select role_name
        from tb_users inner join tb_urs
        on tb_users.user_id = tb_urs.uid
        inner join tb_roles
        on tb_urs.rid = tb_roles.role_id
        where tb_users.username=#{username}
    </select>

</mapper>
```

###### 3.2.4 根据用户名查询权限列表

- 创建DAO

```java
public interface PermissionDAO {
    public Set<String> queryPermissionsByUsername(String  username) throws Exception;
}
```

- 映射配置

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE mapper
        PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN"
        "http://mybatis.org/dtd/mybatis-3-mapper.dtd">
<mapper namespace="com.qfedu.shiro4.dao.PermissionDAO">

    <select id="queryPermissionsByUsername" resultSets="java.util.Set" resultType="string">
        select tb_permissions.permission_code from tb_users
        inner join tb_urs on tb_users.user_id=tb_urs.uid
        inner join tb_roles on tb_urs.rid=tb_roles.role_id
        inner join tb_rps on tb_roles.role_id=tb_rps.rid
        inner join tb_permissions on tb_rps.pid=tb_permissions.permission_id
        where tb_users.username=#{username}
    </select>

</mapper>
```

#### 3.3 整合Shiro

- 导入依赖

```xml
<dependency>
    <groupId>org.apache.shiro</groupId>
    <artifactId>shiro-spring</artifactId>
    <version>1.4.1</version>
</dependency>
<dependency>
    <groupId>com.github.theborakompanioni</groupId>
    <artifactId>thymeleaf-extras-shiro</artifactId>
    <version>2.0.0</version>
</dependency>
```

- 配置Shiro-基于Java配置方式

```java
@Configuration
public class ShiroConfig {

    @Bean
    public ShiroDialect getShiroDialect(){
        return new ShiroDialect();
    }

    //自定义Realm
    @Bean
    public MyRealm getMyRealm(){
        MyRealm myRealm = new MyRealm();
        return myRealm;
    }

    @Bean
    public DefaultWebSecurityManager getDefaultWebSecurityManager(MyRealm myRealm){
        DefaultWebSecurityManager securityManager = new DefaultWebSecurityManager();
        securityManager.setRealm(myRealm);
        return securityManager;
    }

    @Bean
    public ShiroFilterFactoryBean shiroFilter(DefaultWebSecurityManager securityManager){
        ShiroFilterFactoryBean filter = new ShiroFilterFactoryBean();
        //过滤器就是shiro就行权限校验的核心，进行认证和授权是需要SecurityManager的
        filter.setSecurityManager(securityManager);

        Map<String,String> filterMap = new HashMap<>();
        filterMap.put("/","anon");
        filterMap.put("/index.html","anon");
        filterMap.put("/login.html","anon");
        filterMap.put("/regist.html","anon");
        filterMap.put("/user/login","anon");
        filterMap.put("/user/regist","anon");
        filterMap.put("/layui/**","anon");
        filterMap.put("/**","authc");

        filter.setFilterChainDefinitionMap(filterMap);
        filter.setLoginUrl("/login.html");
        //设置未授权访问的页面路径（）
        filter.setUnauthorizedUrl("/login.html");
        return filter;
    }

}

```

- 自定义Realm

```java
/**
 * 1.创建一个类继承AuthorizingRealm类（实现了Realm接口的类）
 * 2.重写doGetAuthorizationInfo和doGetAuthenticationInfo方法
 * 3.重写getName方法返回当前realm的一个自定义名称
 */
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
     * 获取授权数据(将当前用户的角色及权限信息查询出来)
     */
    protected AuthorizationInfo doGetAuthorizationInfo(PrincipalCollection principalCollection) {
        //获取用户的用户名
        String username = (String) principalCollection.iterator().next();
        //根据用户名查询当前用户的角色列表
        Set<String> roleNames = roleDAO.queryRoleNamesByUsername(username);
        //根据用户名查询当前用户的权限列表
        Set<String> ps = permissionDAO.queryPermissionsByUsername(username);

        SimpleAuthorizationInfo info = new SimpleAuthorizationInfo();
        info.setRoles(roleNames);
        info.setStringPermissions(ps);
        return info;
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

        AuthenticationInfo info = new SimpleAuthenticationInfo(
                username,           //当前用户用户名
                user.getUserPwd(),   //从数据库查询出来的安全密码
                getName());

        return info;
    }
}
```

## 四、SpringBoot应用打包部署

- SpringBoot项目集成了web容器(Tomcat),所以SpringBoot应用是可以打包成jar直接运行的