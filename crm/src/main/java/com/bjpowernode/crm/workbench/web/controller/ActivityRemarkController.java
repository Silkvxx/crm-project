package com.bjpowernode.crm.workbench.web.controller;

import com.bjpowernode.crm.commons.contants.Contants;
import com.bjpowernode.crm.commons.domain.ReturnObject;
import com.bjpowernode.crm.commons.utils.DateUtils;
import com.bjpowernode.crm.commons.utils.UUIDUtils;
import com.bjpowernode.crm.settings.domain.User;
import com.bjpowernode.crm.workbench.domain.ActivitiesRemark;
import com.bjpowernode.crm.workbench.service.ActivitiesRemarkService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import javax.servlet.http.HttpSession;
import java.util.Date;

@Controller
public class ActivityRemarkController {

    @Autowired
    private ActivitiesRemarkService activitiesRemarkService;

    @RequestMapping("/workbench/activity/saveCreateActivityRemark.do")
    @ResponseBody
    public Object saveCreateActivityRemark(ActivitiesRemark remark, HttpSession session){
        User user = (User) session.getAttribute(Contants.SESSION_USER);
        ReturnObject returnObject = new ReturnObject();

        remark.setId(UUIDUtils.getUUID());
        remark.setCreateTime(DateUtils.formatDateTime(new Date()));
        remark.setCreateBy(user.getId());
        remark.setEditFlag(Contants.REMARK_EDIT_FLAG_NO_EDITED);
        try {
            int ret = activitiesRemarkService.saveCreateActivityRemark(remark);
            if (ret>0){
                returnObject.setCode(Contants.RETURN_OBJECT_CODE_SUCCESS);
                returnObject.setReturnData(remark);
            }else {
                returnObject.setCode(Contants.RETURN_OBJECT_CODE_FAIL);
                returnObject.setMessage("网络异常,请稍后重试...");
            }
        }catch (Exception e){
            e.printStackTrace();
            returnObject.setCode(Contants.RETURN_OBJECT_CODE_FAIL);
            returnObject.setMessage("网络异常,请稍后重试...");
        }
        return returnObject;
    }

    @RequestMapping("/workbench/activity/deleteCreateActivityRemark.do")
    @ResponseBody
    public Object deleteCreateActivityRemark(String id){
        ReturnObject returnObject = new ReturnObject();
        try {
            int ret = activitiesRemarkService.deleteActivityRemarkById(id);
            if (ret>0){
                returnObject.setCode(Contants.RETURN_OBJECT_CODE_SUCCESS);
            }else {
                returnObject.setCode(Contants.RETURN_OBJECT_CODE_FAIL);
                returnObject.setMessage("网络异常,请稍后重试!");
            }
        }catch (Exception e){
            returnObject.setCode(Contants.RETURN_OBJECT_CODE_FAIL);
            returnObject.setMessage("网络异常,请稍后重试!");
        }
        return returnObject;
    }
    @RequestMapping("/workbench/activity/editCreateActivityRemark.do")
    @ResponseBody
    public Object editCreateActivityRemark(ActivitiesRemark remark,HttpSession session){
        User user = (User) session.getAttribute(Contants.SESSION_USER);
        ReturnObject returnObject = new ReturnObject();

        remark.setEditBy(user.getId());
        remark.setEditTime(DateUtils.formatDateTime(new Date()));
        remark.setEditFlag(Contants.REMARK_EDIT_FLAG_YES_EDITED);
        try {
            int ret = activitiesRemarkService.saveEditActivityRemark(remark);
            if (ret > 0){
                returnObject.setCode(Contants.RETURN_OBJECT_CODE_SUCCESS);
                returnObject.setReturnData(remark);
            }else {
                returnObject.setCode(Contants.RETURN_OBJECT_CODE_FAIL);
                returnObject.setMessage("网络异常,请稍后重试!");
            }
        }catch (Exception e){
            e.printStackTrace();
            returnObject.setCode(Contants.RETURN_OBJECT_CODE_FAIL);
            returnObject.setMessage("网络异常,请稍后重试!");
        }
        return returnObject;
    }

}
