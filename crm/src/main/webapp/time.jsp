
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<% String basePath = request.getScheme() + "://" +
        request.getServerName() + ":" + request.getServerPort() +
        request.getContextPath() + "/";
%>
<html>
<head>
    <base href="<%=basePath%>">
    <title>Title</title>
    <%--引入jquery的js文件--%>
    <script type="text/javascript" src="jquery/jquery-1.11.1-min.js"></script>
    <%--引入bootstrap--%>
    <link rel="stylesheet" href="jquery/bootstrap_3.3.0/css/bootstrap.min.css">
    <script type="text/javascript" src="jquery/bootstrap_3.3.0/js/bootstrap.min.js"></script>
    <%--引入BOOTSTRAP_DATETIMEPICKER插件--%>
    <link rel="stylesheet" href="jquery/bootstrap-datetimepicker-master/css/bootstrap-datetimepicker.min.css">
    <script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/js/bootstrap-datetimepicker.js"></script>
    <script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/locale/bootstrap-datetimepicker.zh-CN.js"></script>

    <script type="text/javascript">
        $(function () {
            $("#myDate").datetimepicker({
                language:'zh-CN',     //语言 表示中文
                format:'yyyy-mm-dd',  //日期的格式
                minView:'month',//可以选择的最小视图
                initialDate:new Date(), //初始化显示的日期
                autoclose:true,  //设置选择完日期或者时间后,是否自动关闭日历
                todayBtn:true,   //设置是否显示"今天"按钮,默认是false
                clearBtn:true    //设置是否显示"清空"按钮,默认时false
            })
        })
    </script>
</head>
<body>
<input type="text" id="myDate">
</body>
</html>
