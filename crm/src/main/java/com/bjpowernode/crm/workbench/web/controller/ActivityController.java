package com.bjpowernode.crm.workbench.web.controller;

import com.bjpowernode.crm.commons.contants.Contants;
import com.bjpowernode.crm.commons.domain.ReturnObject;
import com.bjpowernode.crm.commons.utils.DateUtils;
import com.bjpowernode.crm.commons.utils.HSSFUtils;
import com.bjpowernode.crm.commons.utils.UUIDUtils;
import com.bjpowernode.crm.settings.domain.User;
import com.bjpowernode.crm.settings.service.UserService;
import com.bjpowernode.crm.workbench.domain.ActivitiesRemark;
import com.bjpowernode.crm.workbench.domain.Activity;
import com.bjpowernode.crm.workbench.service.ActivitiesRemarkService;
import com.bjpowernode.crm.workbench.service.ActivityService;
import org.apache.poi.hssf.usermodel.HSSFCell;
import org.apache.poi.hssf.usermodel.HSSFRow;
import org.apache.poi.hssf.usermodel.HSSFSheet;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.aspectj.lang.annotation.AdviceName;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;

import javax.annotation.Resource;
import javax.servlet.ServletOutputStream;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.*;
import java.util.*;

@Controller
public class ActivityController {

    @Autowired
    private UserService userService;

    @Autowired
    private ActivityService activityService;

    @Autowired
    private ActivitiesRemarkService activitiesRemarkService;

    @RequestMapping("/workbench/activity/index.do")
    public String index(HttpServletRequest request){
        //去后台查User,放到模态窗口的创建,修改的所有者里面
        List<User> userList = userService.queryAllUsers();
        //把数据放进request请求域中,让jsp页面取出来部分就行
        request.setAttribute("userList",userList);
        return "workbench/activity/index";
    }

    @RequestMapping("/workbench/activity/saveCreateActivity.do")
    @ResponseBody
    //需要返回json格式的数据,返回值类型变成Object
    public Object saveCreateActivity(Activity activity, HttpSession session){
        //后台sql语句接受9个数据,我们只有6个,少了id,创建人,创建时间
        User user = (User) session.getAttribute(Contants.SESSION_USER);
        //封装进去
        activity.setId(UUIDUtils.getUUID());    //id
        activity.setCreateBy(user.getId());     //创建人的id
        activity.setCreateTime(DateUtils.formatDateTime(new Date()));   //创建时间

        ReturnObject returnObject = new ReturnObject();
        try {
            int i = activityService.saveCreateActivity(activity);
            if (i>0){   //表示插入成功,返回json格式的数据
                returnObject.setCode(Contants.RETURN_OBJECT_CODE_SUCCESS);
            }else {
                returnObject.setCode(Contants.RETURN_OBJECT_CODE_FAIL);
                returnObject.setMessage("系统忙,请稍后重试...");
            }
        }catch (Exception e){
            e.printStackTrace();
            returnObject.setCode(Contants.RETURN_OBJECT_CODE_FAIL);
            returnObject.setMessage("系统忙,请稍后重试...");
        }
    return returnObject;
    }

    @RequestMapping("/workbench/activity/queryActivityByConditionForPage.do")
    @ResponseBody
    public Object queryActivityByConditionForPage(String name,String owner,
                                                  String startDate,String endDate,
                                                  int pageNo,int pageSize){
        Map<String,Object> map = new HashMap<>();
        map.put("name",name);
        map.put("owner",owner);
        map.put("startDate",startDate);
        map.put("endDate",endDate);
        map.put("pageNo",(pageNo-1)*pageSize);
        map.put("pageSize",pageSize);
        List<Activity> activityList = activityService.queryActivityByConditionForPage(map);
        int totalRows = activityService.queryCountOfActivityByCondition(map);
        //根据查询的结果,把数据封装进map里,返回给前端
        Map<String,Object> result = new HashMap<>();
        result.put("activityList",activityList);
        result.put("totalRows",totalRows);
        return result;
    }

    @RequestMapping("/workbench/activity/deleteActivityIds.do")
    @ResponseBody
    public Object deleteActivityIds(String[] id){
        ReturnObject returnObject = new ReturnObject();
        try {
            int ret = activityService.deleteActivityByIds(id);
            if (ret > 0){
                returnObject.setCode(Contants.RETURN_OBJECT_CODE_SUCCESS);
            }else {
                returnObject.setCode(Contants.RETURN_OBJECT_CODE_FAIL);
                returnObject.setMessage("网络繁忙,请稍后重试...");
            }
        }catch (Exception e){
            e.printStackTrace();
            returnObject.setCode(Contants.RETURN_OBJECT_CODE_FAIL);
            returnObject.setMessage("网络繁忙,请稍后重试...");
        }
        return returnObject;
    }

    @RequestMapping("/workbench/activity/queryActivityId.do")
    @ResponseBody
    public Object queryActivityId(String id){
        Activity activity = activityService.queryActivityById(id);
        return activity;
    }

    @RequestMapping("/workbench/activity/saveEditActivity.do")
    @ResponseBody
    public Object saveEditActivity(HttpSession session, Activity activity){
        ReturnObject returnObject = new ReturnObject();
        User user = (User) session.getAttribute(Contants.SESSION_USER);

        String id = user.getId();
        String time = DateUtils.formatDateTime(new Date());
        activity.setEditBy(id);
        activity.setEditTime(time);
        try {
            int ret = activityService.saveEditActivity(activity);
            if (ret == 1){
                returnObject.setCode(Contants.RETURN_OBJECT_CODE_SUCCESS);
            }else {
                returnObject.setCode(Contants.RETURN_OBJECT_CODE_FAIL);
                returnObject.setMessage("网络繁忙,请稍后重试...");
            }
        }catch (Exception e){
            e.printStackTrace();
            returnObject.setCode(Contants.RETURN_OBJECT_CODE_FAIL);
            returnObject.setMessage("网络繁忙,请稍后重试...");
        }
        return returnObject;
    }

    //对应filedownloadtest.jsp 和 test包中的CreateExcelTest 测试页面,和主业务无关
    @RequestMapping("workbench/activity/fileDownload.do")
    public void fileDownload(HttpServletResponse response) throws IOException {
        //1.设置响应格式
        response.setContentType("application/octet-stream;charset=utf-8");
        //设置响应头信息
        response.setHeader("Content-Disposition","attachment;filename=aaa.xls");

        ServletOutputStream  out = response.getOutputStream();
        FileInputStream fi = new FileInputStream("F:\\1\\test\\aaa.xls");
           byte[] bytes = new byte[256];
           int len=0;
            while (((len=fi.read(bytes))!=-1)){
                out.write(bytes,0,len);
            }
            out.close();
            fi.close();
    }

    @RequestMapping("/workbench/activity/exportAllActivitys.do")
    public void exportAllActivitys(HttpServletResponse response) throws IOException {
        //获取请求数据
        //处理信息
        //查出所有的活动信息
        List<Activity> activities = activityService.queryAllActivitys();

        //封装成excel文件
        HSSFWorkbook wb = new HSSFWorkbook();
        HSSFSheet sheet = wb.createSheet("活动列表");
        //创建第一行表头
        HSSFRow row = sheet.createRow(0);
        HSSFCell cell = row.createCell(0);
        cell.setCellValue("ID");
        cell = row.createCell(1);
        cell.setCellValue("所有者");
        cell = row.createCell(2);
        cell.setCellValue("名称");
        cell = row.createCell(3);
        cell.setCellValue("开始日期");
        cell = row.createCell(4);
        cell.setCellValue("结束日期");
        cell = row.createCell(5);
        cell.setCellValue("成本");
        cell = row.createCell(6);
        cell.setCellValue("描述");
        cell = row.createCell(7);
        cell.setCellValue("创建时间");
        cell = row.createCell(8);
        cell.setCellValue("创建人");
        cell = row.createCell(9);
        cell.setCellValue("修改时间");
        cell = row.createCell(10);
        cell.setCellValue("修改人");
        //设置内容
        if (activities != null && activities.size()>0){
            //因为list是从0开始算第一个数据,所以这里使用i=0开始比较好
            Activity activity = null;
            for (int i =0;i<activities.size();i++){
                //获取第一个activity对象
                activity = activities.get(i);

                //创建第二行
                row = sheet.createRow(i+1);
                cell = row.createCell(0);
                cell.setCellValue(activity.getId());
                cell = row.createCell(1);
                cell.setCellValue(activity.getOwner());
                cell = row.createCell(2);
                cell.setCellValue(activity.getName());
                cell = row.createCell(3);
                cell.setCellValue(activity.getStartDate());
                cell = row.createCell(4);
                cell.setCellValue(activity.getEndDate());
                cell = row.createCell(5);
                cell.setCellValue(activity.getCost());
                cell = row.createCell(6);
                cell.setCellValue(activity.getDescription());
                cell = row.createCell(7);
                cell.setCellValue(activity.getCreateTime());
                cell = row.createCell(8);
                cell.setCellValue(activity.getCreateBy());
                cell = row.createCell(9);
                cell.setCellValue(activity.getEditTime());
                cell = row.createCell(10);
                cell.setCellValue(activity.getEditBy());
            }
        }
        /*//根据wb对象生成excel文件
        OutputStream out = new FileOutputStream("F:\\1\\test\\activitys.xls");
        wb.write(out);
        out.close();
        wb.close();*/

        //设置响应格式
        response.setContentType("application/octet-stream;charset=utf-8");
        //设置响应头信息
        response.setHeader("Content-Disposition","attachment;filename=activitys.xls");
        ServletOutputStream os = response.getOutputStream();
        /*//把生成的excel文件下载到客户端
        InputStream in = new FileInputStream("F:\\1\\test\\activitys.xls");
        byte[] bytes = new byte[256];
        int len = 0;
        while ((len=in.read(bytes))!=-1){
            os.write(bytes,0,len);
        }
        in.close();
       */

        wb.write(os);

        os.flush();
        wb.close();
    }

    //对应fileuploadtest.jsp 和 test包中的ParseExcelTest 测试页面\
    @RequestMapping("/workbench/activity/fileupload.do")
    public void fileupload(MultipartFile myfile) throws IOException {
        //接收请求文件,并在本地生成同样的文件
        String originalFilename = myfile.getOriginalFilename();
        File file = new File("F:\\1\\test\\fileupload",originalFilename);
        myfile.transferTo(file);
        System.out.println("接收成功...");
    }

    @RequestMapping("/workbench/activity/importActivity.do")
    @ResponseBody
    public Object importActivity(MultipartFile activityFile,String userName,HttpSession session){
        //在本地存放一个一模一样的文件
        /*String originalFilename = activityFile.getOriginalFilename();
        System.out.println(originalFilename);
        File file = new File("F:\\1\\test\\fileupload",originalFilename);*/
        ReturnObject returnObject = new ReturnObject();

        try {
            /*activityFile.transferTo(file);*/
            //开始读文件,并把文件的内容插入数据库中
            /*FileInputStream fi = new FileInputStream("F:\\1\\test\\fileupload\\activitys.xls");*/

            //这里不用上面 先写入磁盘再获取文件了,直接获取这个流,直接放进内存开始读
            InputStream fi = activityFile.getInputStream();

            HSSFWorkbook wb = new HSSFWorkbook(fi);
            HSSFSheet sheetAt = wb.getSheetAt(0);
            User user = (User) session.getAttribute(Contants.SESSION_USER);
            Activity activity = null;
            List<Activity> activityList = new ArrayList<>();

            for (int i = 0;i<=sheetAt.getLastRowNum();i++){  //获取最后一行的下标,使用<=
                activity = new Activity();
                activity.setId(UUIDUtils.getUUID());
                activity.setOwner(user.getId());
                activity.setCreateTime(DateUtils.formatDateTime(new Date()));
                activity.setCreateBy(user.getId());

                HSSFRow row = sheetAt.getRow(i);
                for (int j =0 ;j<row.getLastCellNum();j++){  //获取最后一列的下标+1,使用<
                    HSSFCell cell = row.getCell(j);
                    String value = HSSFUtils.getValue(cell);  //这个就是获取到的单个值
                    if (j==0){
                        activity.setName(value);
                    }else if (j==1){
                        activity.setStartDate(value);
                    }else if (j==2){
                        activity.setEndDate(value);
                    }else if (j==3){
                        activity.setCost(value);
                    }else if (j==4){
                        activity.setDescription(value);
                    }
                }
                activityList.add(activity);
            }
            //获取到所有的数据了,并且数据已经封装进了list中,调方法,插入数据
            int count = activityService.saveCreateActivityByList(activityList);
            returnObject.setCode(Contants.RETURN_OBJECT_CODE_SUCCESS);
            returnObject.setReturnData(count);
        } catch (IOException e) {
            e.printStackTrace();
            returnObject.setCode(Contants.RETURN_OBJECT_CODE_FAIL);
            returnObject.setMessage("网络忙,请稍后重试!");
        }
        return returnObject;
    }

    @RequestMapping("/workbench/activity/detailActivity.do")
    public String detailActivity(String id,HttpServletRequest request){
        System.out.println("市场活动的id======="+id);
        //后台接收到id后去查询数据库中的数据,然后封装进一个activity对象中,放进request域中
        Activity activity = activityService.queryActivityForDetail(id);
        List<ActivitiesRemark> activitiesRemarks = activitiesRemarkService.queryActivityRemarkForDetailByActivityId(id);
        request.setAttribute("activity",activity);
        request.setAttribute("activitiesRemarks",activitiesRemarks);

        return "workbench/activity/detail"; //这里有springmvc的视图解析器,所以不用加.jsp
    }

}
