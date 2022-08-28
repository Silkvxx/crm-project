<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<html>
<head>
	<% String basePath = request.getScheme() + "://" +
			request.getServerName() + ":" + request.getServerPort() +
			request.getContextPath() + "/";  %>
	<base href="<%=basePath%>">
<meta charset="UTF-8">
<link href="jquery/bootstrap_3.3.0/css/bootstrap.min.css" type="text/css" rel="stylesheet" />
<script type="text/javascript" src="jquery/jquery-1.11.1-min.js"></script>
<script type="text/javascript" src="jquery/bootstrap_3.3.0/js/bootstrap.min.js"></script>
	<script type="text/javascript">
		$(function (){
			$(window).keydown(function (e) {
				if (e.keyCode == 13){
					$("#loginBtn").click();
				}
			})
			$("#loginBtn").click(function (){
				var loginAct = $("#loginAct").val();
				var loginPwd = $("#loginPwd").val();
				var isRemPwd = $("#isRemPwd").prop("checked")
				//这里进行一个简单的表单验证
				if (loginAct == ""){          //这里的验证建立在点击按钮的基础之上的
					alert("用户名为空")
					return;
				}
				if (loginPwd == ""){
					alert("密码为空")
					return;
				}
				//可以在发送ajax之前加上一个友善的提醒
				//$("#msg").text("正在验证中...")
				$.ajax({
					url:'settings/qx/user/login.do',
					data:{
					loginAct:loginAct,
					loginPwd:loginPwd,
					isRemPwd:isRemPwd
					},
					type:'post',
					dataType:'json',
					success: function (data){
						if (data.code == "1"){  //说明用户合法,可以放行
							//这里跳转到workbench的index.jsp页面的controller
							window.location.href="workbench/index.do";
						}
						$("#msg").text(data.message)   //这里因为只有文字,所以可以直接使用text,如果有代码的话可以使用html
					},
					beforeSend:function (){
						$("#msg").text("正在验证中...")  //也可以在这里加个提醒,会在发送ajax请求之前执行
						return true;                   //返回true代表可以发送ajax请求,false则不发
					}
				})
			})
		})
	</script>
</head>
<body>
	<div style="position: absolute; top: 0px; left: 0px; width: 60%;">
		<img src="image/IMG_7114.JPG" style="width: 100%; height: 90%; position: relative; top: 50px;">
	</div>
	<div id="top" style="height: 50px; background-color: #3C3C3C; width: 100%;">
		<div style="position: absolute; top: 5px; left: 0px; font-size: 30px; font-weight: 400; color: white; font-family: 'times new roman'">CRM &nbsp;<span style="font-size: 12px;">&copy;2019&nbsp;动力节点</span></div>
	</div>
	
	<div style="position: absolute; top: 120px; right: 100px;width:450px;height:400px;border:1px solid #D5D5D5">
		<div style="position: absolute; top: 0px; right: 60px;">
			<div class="page-header">
				<h1>登录</h1>
			</div>
			<form action="workbench/index.html" class="form-horizontal" role="form">
				<div class="form-group form-group-lg">
					<div style="width: 350px;">
						<input class="form-control" type="text" id="loginAct" value="${cookie.loginAct.value}" placeholder="用户名">
					</div>
					<div style="width: 350px; position: relative;top: 20px;">
						<input class="form-control" type="password" id="loginPwd" value="${cookie.loginPwd.value}" placeholder="密码">
					</div>
					<div class="checkbox"style="position: relative;top: 30px; left: 10px;">
						<label>
							<c:if test="${not empty cookie.loginAct and not empty cookie.loginPwd}">
								<input type="checkbox"  id="isRemPwd" checked >
							</c:if>

							<c:if test="${empty cookie.loginAct or empty cookie.loginPwd}">
								<input type="checkbox"  id="isRemPwd" >
							</c:if>
							十天内免登录
						</label>
						&nbsp;&nbsp;
						<span id="msg" style="color: red"></span>
					</div>
					<button type="button" id="loginBtn" class="btn btn-primary btn-lg btn-block"  style="width: 350px; position: relative;top: 45px;">登录</button>
				</div>
			</form>
		</div>
	</div>
</body>
</html>