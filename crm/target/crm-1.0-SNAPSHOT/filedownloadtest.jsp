<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<html>
<head>
    <% String basePath = request.getScheme() + "://" +
            request.getServerName() + ":" + request.getServerPort() +
            request.getContextPath() + "/";  %>
    <base href="<%=basePath%>">
    <meta charset="UTF-8">
    <script type="text/javascript" src="jquery/jquery-1.11.1-min.js"></script>
    <script type="text/javascript" >
        $(function () {
            $("#downloadBtn").click(function (){
                //发送下载的请求
                alert("aaaa")
                window.location.href="workbench/activity/fileDownload.do";
            })
        })
    </script>
</head>
<body>
<input type="button" value="下载到本地" id="downloadBtn">
</body>
</html>
