package com.bjpowernode.crm.settings.web.controller;

import com.bjpowernode.crm.commons.contants.Contants;
import com.bjpowernode.crm.commons.domain.ReturnObject;
import com.bjpowernode.crm.commons.utils.DateUtils;
import com.bjpowernode.crm.settings.domain.User;
import com.bjpowernode.crm.settings.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

@Controller
public class UserController {

    @Autowired
    private UserService userService;

    //访问这个controller的这个方法,跳转到登录页面
    @RequestMapping("/settings/qx/user/toLogin.do")
    public String toLogin(){
        return "settings/qx/user/login";  //这里前面不加"/" 因为视图解析器里最后加了
    }

    //这里需要返回一个json类型的数据
    @RequestMapping("/settings/qx/user/login.do")
    @ResponseBody
    public Object login(String loginAct, String loginPwd, String isRemPwd, HttpServletRequest request, HttpServletResponse response, HttpSession session){
        Map<String,Object> map = new HashMap<>();
        map.put("loginAct",loginAct);
        map.put("loginPwd",loginPwd);
        User user = userService.queryUserByLoginActAndPwd(map);
        ReturnObject returnObject = new ReturnObject();
        //通过查询到的数据对象,检查是否符合要求
        if (user == null){
            //需要返回的格式为以下,所以需要一个实体类来传输过去
            //code: 0|1
            //message:xxxx
            returnObject.setCode(Contants.RETURN_OBJECT_CODE_FAIL);
            returnObject.setMessage("用户名或密码错误");
        }else {
            String nowTime = DateUtils.formatDateTime(new Date());
            String expireTime = user.getExpireTime();
            if (expireTime.compareTo(nowTime) < 0){
                //用户已过期
                returnObject.setCode(Contants.RETURN_OBJECT_CODE_FAIL);
                returnObject.setMessage("用户已过期");
            }else if ("0".equals(user.getLockState())){
                //用户状态被锁定
                returnObject.setCode(Contants.RETURN_OBJECT_CODE_FAIL);
                returnObject.setMessage("用户状态被锁定");
            }else if (!user.getAllowIps().contains(request.getRemoteAddr())){
                //ip受限
                returnObject.setCode(Contants.RETURN_OBJECT_CODE_FAIL);
                returnObject.setMessage("ip受限");
            }else {
                //这里代表登录成功
                returnObject.setCode(Contants.RETURN_OBJECT_CODE_SUCCESS);
                returnObject.setMessage("");

                session.setAttribute(Contants.SESSION_USER,user);
                //登录成功并且记住密码 往外写cookie
                System.out.println(isRemPwd);
                if ("true".equals(isRemPwd)){
                    Cookie loginActcookie = new Cookie("loginAct",user.getLoginAct());
                    loginActcookie.setMaxAge(60*60*24*10);
                    response.addCookie(loginActcookie);

                    Cookie loginPwdcookie = new Cookie("loginPwd",user.getLoginPwd());
                    loginPwdcookie.setMaxAge(60*60*24*10);
                    response.addCookie(loginPwdcookie);
                }else {
                    //说明没选中记住密码,则删除cookie
                    Cookie loginActcookie = new Cookie("loginAct","1");
                    loginActcookie.setMaxAge(0);
                    response.addCookie(loginActcookie);

                    Cookie loginPwdcookie = new Cookie("loginPwd","1");
                    loginPwdcookie.setMaxAge(0);
                    response.addCookie(loginPwdcookie);
                }
            }
        }
        //这里相当于returnObject这个对象中已经在上面被赋值了,直接返回
        return returnObject;
    }
    @RequestMapping("/settings/qx/user/logout.do")
    public String logout(HttpServletResponse response, HttpSession session){
        Cookie loginActcookie = new Cookie("loginAct","1");
        loginActcookie.setMaxAge(0);
        response.addCookie(loginActcookie);

        Cookie loginPwdcookie = new Cookie("loginPwd","1");
        loginPwdcookie.setMaxAge(0);
        response.addCookie(loginPwdcookie);

        session.invalidate();    //删除session域中所有数据,并且session.setAttribute中的也删除
        return "redirect:/";  //重定向返回到首页,加了这个redirect就不管有没有视图解析器了
    }
}
