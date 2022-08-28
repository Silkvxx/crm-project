<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<html>
<head>
    <% String basePath = request.getScheme() + "://" +
            request.getServerName() + ":" + request.getServerPort() +
            request.getContextPath() + "/";  %>
    <base href="<%=basePath%>">
    <title>上传文件</title>
</head>
<body>
<%--上传文件--%>
<form action="workbench/activity/fileupload.do" method="post" enctype="multipart/form-data">
    <input type="file" name="myfile">
    <input type="text" name="userName">
    <input type="submit" value="提交">
</form>
</body>
</html>
