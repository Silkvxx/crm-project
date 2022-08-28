<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<html>
<head>
	<% String basePath = request.getScheme() + "://" +
	request.getServerName() + ":" + request.getServerPort() +
	request.getContextPath() + "/";  %>
	<base href="<%=basePath%>">
	<meta charset="UTF-8">

<link href="jquery/bootstrap_3.3.0/css/bootstrap.min.css" type="text/css" rel="stylesheet" /> <%--引入bootstrap的css文件--%>
<link href="jquery/bootstrap-datetimepicker-master/css/bootstrap-datetimepicker.min.css" type="text/css" rel="stylesheet" /><%--引入bootstrap的日期datetimepicker的css文件--%>
<link rel="stylesheet" href="jquery/bs_pagination-master/css/jquery.bs_pagination.min.css">

<script type="text/javascript" src="jquery/jquery-1.11.1-min.js"></script>   <%--引入jQuery的js文件--%>
<script type="text/javascript" src="jquery/bootstrap_3.3.0/js/bootstrap.min.js"></script><%--引入bootstrap的js文件--%>
<script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/js/bootstrap-datetimepicker.js"></script><%--引入bootstrap的日期的js文件--%>
<script type="text/javascript" src="jquery/bootstrap-datetimepicker-master/locale/bootstrap-datetimepicker.zh-CN.js"></script><%--引入bootstrap的日期的js文件local--%>
<script type="text/javascript" src="jquery/bs_pagination-master/js/jquery.bs_pagination.min.js"></script>
<script type="text/javascript" src="jquery/bs_pagination-master/localization/en.js"></script>

<script type="text/javascript">

	$(function(){
		$("#createActivityBtn").click(function (){
			//这里应该清空表单的内容,下次创建的时候不显示上次的内容.
			$("#createActivityForm").get(0).reset()

			$("#createActivityModal").modal("show")   //点击创建按钮之后弹出模态窗口
		});
		$("#saveCreateActivityBtn").click(function (){    //给保存按钮添加单击事件
			var owner = $("#create-marketActivityOwner").val();
			var name = $.trim($("#create-marketActivityName").val());
			var startDate = $("#create-startDate").val();
			var endDate = $("#create-endDate").val();
			var cost = $.trim($("#create-cost").val());
			var description = $.trim($("#create-description").val());
			//这里进行表单验证
			if (owner==""){
				alert("所有者不能为空")
				return;
			}
			if (name==""){
				alert("名称不能为空")
				return
			}
			if (startDate==""||endDate==""){
				alert("开始日期或者结日期不能为空")
				return;
			}else {
				if (endDate<startDate){
					alert("结束日期不能比开始日期小")
					return;
				}
			}
			//这里加个正则表达式来约束成本为非负整数
			var regExp=/^(([1-9]\d*)|0)$/;
			if (!regExp.test(cost)) {
				alert("成本必须为0或正整数");
				return;
			}
			$.ajax({
				url:'workbench/activity/saveCreateActivity.do',
				data:{
					owner:owner,
					name:name,
					startDate:startDate,
					endDate:endDate,
					cost:cost,
					description:description
				},
				type:'post',
				dataType:'json',
				success:function (e){
					if (e.code == "1"){
						$("#createActivityModal").modal("hide")
						//刷新市场活动列表,保持当前显示的市场条数不变
						queryActivityByConditionForPage(1,$("#demo_pag1").bs_pagination('getOption','rowsPerPage'));
					}else{
						alert(e.message)
						$("#createActivityModal").modal("show")//继续展示模态窗口
					}
				}
			});
		});

		//页面加载完毕之后加载日期
		$(".mydate").datetimepicker({
			language:'zh-CN',     //语言 表示中文
			format:'yyyy-mm-dd',  //日期的格式
			minView:'month',//可以选择的最小视图
			initialDate:new Date(), //初始化显示的日期
			autoclose:true,  //设置选择完日期或者时间后,是否自动关闭日历
			todayBtn:true,   //设置是否显示"今天"按钮,默认是false
			clearBtn:true    //设置是否显示"清空"按钮,默认时false
		});

		//页面加载完毕之后自动发送请求查询数据
		queryActivityByConditionForPage(1,10);

		//给查询按钮绑定事件
		$("#queryActivityBtn").click(function () {
			queryActivityByConditionForPage(1,$("#demo_pag1").bs_pagination('getOption','rowsPerPage'));
		})

		//上面全选复选框的单击事件,固定元素,使用普通单击函数
		$("#checkAll").click(function () {
			$("#tBody input[type='checkbox']").prop('checked', this.checked);
		})

		//下面小复选框的单击事件,动态元素,使用on函数
		$("#tBody").on("click","input[type='checkbox']",function () {
			if ($("#tBody input[type='checkbox']").size() == $("#tBody input[type='checkbox']:checked").size()){
				$("#checkAll").prop('checked',true);
			}else {
				$("#checkAll").prop('checked',false);
			}
		});

		//删除市场活动
		$("#deleteActivityBtn").click(function (){
			var checkedIds = $("#tBody input[type='checkbox']:checked")
			if (checkedIds.size() == 0){
				alert("请选择要删除的市场活动")
				return
			}
			//到这里说明选择了
			if (window.confirm("确定删除吗?")){
				var ids = "";
				$.each(checkedIds,function () {
					ids+="id="+this.value+"&"; //id=3&id=5&id=8&...id=9&
				})
				ids = ids.substr(0,ids.length-1); //id=3&id=5&id=8&...id=9  把后面的&拆掉

				$.ajax({
					url:'workbench/activity/deleteActivityIds.do',
					data:ids,
					dataType:'json',
					success:function (data) {
						if (data.code == 1){
							queryActivityByConditionForPage(1,$("#demo_pag1").bs_pagination('getOption','rowsPerPage'));
						}else {
							alert(data.message)
						}
					}
				})
			}
		})
		
		//这里获取"修改"的按钮的事件
		$("#editActivityBtn").click(function () {
			var checkedId = $("#tBody input[type='checkbox']:checked")
			//alert("选择的长度:"+checkedId.size())
			if (checkedId.size() != 1){
				alert("请每次最少或最多选择修改一条数据!!!")
				return
			}
			var id = checkedId.val()
			//这里发送请求把数据放进模态窗口中,只是检索数据就行,不做更改
			$.ajax({
				url:'workbench/activity/queryActivityId.do',
				data:{
					id:id
				},
				dataType:'json',
				success:function (data){
					$("#edit-id").val(data.id);
					$("#edit-marketActivityOwner").val(data.owner);
					$("#edit-marketActivityName").val(data.name);
					$("#edit-startTime").val(data.startDate);
					$("#edit-endTime").val(data.endDate);
					$("#edit-cost").val(data.cost);
					$("#edit-describe").val(data.description);
					//显示模态窗口
					$("#editActivityModal").modal("show");
				}
			})
		})
		//给修改模态窗口的"更新"按钮添加单击事件
		$("#saveEditActivityBtn").click(function () {
			var id = $("#edit-id").val();
			var owner = $("#edit-marketActivityOwner").val();
			var name = $("#edit-marketActivityName").val();
			var startDate = $("#edit-startTime").val();
			var endDate = $("#edit-endTime").val();
			var cost = $("#edit-cost").val();
			var description = $("#edit-describe").val();
			$.ajax({
				url:'workbench/activity/saveEditActivity.do',
				data:{
					id:id,
					owner:owner,
					name:name,
					startDate:startDate,
					endDate:endDate,
					cost:cost,
					description:description
				},
				dataType:'json',
				success:function (data){
					if (data.code == "1"){
						//关闭模态窗口
						$("#editActivityModal").modal("hide");
						//刷新列表,保持页号和每页显示条数不变
						queryActivityByConditionForPage($("#demo_pag1").bs_pagination('getOption','currentPage'),$("#demo_pag1").bs_pagination('getOption','rowsPerPage'));
					}else {
						//弹出提示信息,模态窗口不关闭
						alert(data.message)
						$("#editActivityModal").modal("show");
					}
				}
			})
		})
		//获取批量导出单击事件
		$("#exportActivityAllBtn").click(function () {
			window.location.href="workbench/activity/exportAllActivitys.do";
		})

		//获取导入按钮的单击事件
		$("#importActivityBtn").click(function () {
			//判断文件是否是excel文件
			var activityFileName = $("#activityFile").val();
			var text=activityFileName.substr(activityFileName.lastIndexOf(".")+1).toLowerCase()
			if (text!="xls" && text!="xlsx"){
				alert("文件只能是xls或者xlsx结尾的.")
				return
			}
			//判断上传文件的大小是否超过5M;
			var activityFile = $("#activityFile")[0].files[0];
			if (activityFile.size>1024*1024*5){
				alert("文件大小不能超过5M")
				return;
			}
			//上传数据这里使用FormData
			var formData = new FormData();
			formData.append("activityFile",activityFile);
			formData.append("userName","张三");
			$.ajax({
				url:'workbench/activity/importActivity.do',
				data:formData,
				type:'post',
				dataType:'json',
				processData:false,//设置ajax向后台发送请求是否把参数统一转换成字符串的形式,默认true,
				contentType:false,//设置ajax向后台发送请求是否把所有参数统一按urlencoded编码,默认true,
				success:function (data) {
					if (data.code == 1){
						alert("成功插入"+data.returnData+"条数据");
						queryActivityByConditionForPage(1,$("#demo_pag1").bs_pagination('getOption','rowsPerPage'));
						$("#importActivityModal").modal("hide")
					}else {
						alert(data.message)
						//模态窗口不关闭
						$("#importActivityModal").modal("show")
					}
				}
			})

		})

	});

	//查询市场活动,并拼成字符串显示进下面的列表中
	function queryActivityByConditionForPage(pageNo,pageSize) {
		var name = $("#query-name").val();
		var owner = $("#query-owner").val();
		var startDate = $("#query-startDate").val();
		var endDate = $("#query-endDate").val();

		$.ajax({
			url:'workbench/activity/queryActivityByConditionForPage.do',
			data:{
				name:name,
				owner:owner,
				startDate:startDate,
				endDate:endDate,
				pageNo:pageNo,
				pageSize:pageSize
			},
			type:'post',
			dataType:'json',
			success:function (data){  //这里的data就是获取的result,是个map集合
				//$("#totalRowsB").text(data.totalRows);
				var list = "";
				$.each(data.activityList,function(index,obj){
					list +="<tr class=\"active\">"
					list +="<td><input type=\"checkbox\" value=\""+obj.id+"\"  /></td>"
					list +="<td><a style=\"text-decoration: none; cursor: pointer;\" onclick=\"window.location.href='workbench/activity/detailActivity.do?id="+obj.id+"'\">"+obj.name+"</a></td>"
					list +="<td>"+obj.owner+"</td>"
					list +="<td>"+obj.startDate+"</td>"
					list +="<td>"+obj.endDate+"</td>"
					list +="</tr>"
				})
				//一定是最后字符串拼接完之后使用html放进去
				$("#tBody").html(list)

				//取消全选按钮的代码
				$("#checkAll").prop('checked',false);

				//分页查询
				var totalPages=1;
				if(data.totalRows%pageSize==0){
					totalPages=data.totalRows/pageSize;
				}else{
					totalPages=parseInt(data.totalRows/pageSize)+1;
				}
				$("#demo_pag1").bs_pagination({
					currentPage:pageNo,//当前页号,相当于pageNo

					rowsPerPage:pageSize,//每页显示条数,相当于pageSize
					totalRows:data.totalRows, //总条数,数据库查出来的,
					totalPages:totalPages, //总页数,必填参数.通过计算得出来的

					visiblePageLinks: 5,//最多可以显示的

					showGoToPage: true,//是否显示"跳转到"部分,默认true--显示
					showRowsPerPage: true,//是否显示"每页显示条数"部分。默认true--显示
					showRowsInfo: true, //是否显示记录的信息，默认true--显示

					onChangePage:function (event,pageObj) {  //当点击了其他页号或者改变了显示的页数的时候,会触发这个函数
						//这里的pageObj.currentPage  就是改变后的页号
						//     pageObj.rowsPerPage  改变后的显示条数
						queryActivityByConditionForPage(pageObj.currentPage,pageObj.rowsPerPage)

					}
				})
			}

		})
	}
	
</script>
</head>
<body>

	<!-- 创建市场活动的模态窗口 -->
	<div class="modal fade" id="createActivityModal" role="dialog">
		<div class="modal-dialog" role="document" style="width: 85%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title" id="myModalLabel1">创建市场活动</h4>
				</div>
				<div class="modal-body">
				
					<form class="form-horizontal" role="form" id="createActivityForm">
					
						<div class="form-group">
							<label for="create-marketActivityOwner" class="col-sm-2 control-label">所有者<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="create-marketActivityOwner">
								  <%--这里的值从request域中利用jstl循环取出来--%>
									<c:forEach items="${userList}" var="u">
										<option value="${u.id}" >${u.name}</option>
									</c:forEach>
								</select>
							</div>
                            <label for="create-marketActivityName" class="col-sm-2 control-label">名称<span style="font-size: 15px; color: red;">*</span></label>
                            <div class="col-sm-10" style="width: 300px;">
                                <input type="text" class="form-control" id="create-marketActivityName">
                            </div>
						</div>
						
						<div class="form-group">
							<label for="create-startDate" class="col-sm-2 control-label" >开始日期</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control mydate" id="create-startDate" readonly>
							</div>
							<label for="create-endDate" class="col-sm-2 control-label">结束日期</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control mydate" id="create-endDate" readonly>
							</div>
						</div>
                        <div class="form-group">

                            <label for="create-cost" class="col-sm-2 control-label">成本</label>
                            <div class="col-sm-10" style="width: 300px;">
                                <input type="text" class="form-control" id="create-cost">
                            </div>
                        </div>
						<div class="form-group">
							<label for="create-description" class="col-sm-2 control-label">描述</label>
							<div class="col-sm-10" style="width: 81%;">
								<textarea class="form-control" rows="3" id="create-description"></textarea>
							</div>
						</div>
						
					</form>
					
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
					<button type="button" class="btn btn-primary" id="saveCreateActivityBtn">保存</button>
				</div>
			</div>
		</div>
	</div>
	
	<!-- 修改市场活动的模态窗口 -->
	<div class="modal fade" id="editActivityModal" role="dialog">
		<div class="modal-dialog" role="document" style="width: 85%;">
			<div class="modal-content">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal">
						<span aria-hidden="true">×</span>
					</button>
					<h4 class="modal-title" id="myModalLabel2">修改市场活动</h4>
				</div>
				<div class="modal-body">
				
					<form class="form-horizontal" role="form">
					<input type="hidden" id="edit-id">
						<div class="form-group">
							<label for="edit-marketActivityOwner" class="col-sm-2 control-label">所有者<span style="font-size: 15px; color: red;">*</span></label>
							<div class="col-sm-10" style="width: 300px;">
								<select class="form-control" id="edit-marketActivityOwner">
									<%--这里的值从request域中利用jstl循环取出来--%>
									<c:forEach items="${userList}" var="u">
										<option value="${u.id}" >${u.name}</option>
									</c:forEach>
								</select>
							</div>
                            <label for="edit-marketActivityName" class="col-sm-2 control-label">名称<span style="font-size: 15px; color: red;">*</span></label>
                            <div class="col-sm-10" style="width: 300px;">
                                <input type="text" class="form-control" id="edit-marketActivityName" value="发传单">
                            </div>
						</div>

						<div class="form-group">
							<label for="edit-startTime" class="col-sm-2 control-label">开始日期</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control mydate" id="edit-startTime" readonly>
							</div>
							<label for="edit-endTime" class="col-sm-2 control-label">结束日期</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control mydate" id="edit-endTime" readonly>
							</div>
						</div>
						
						<div class="form-group">
							<label for="edit-cost" class="col-sm-2 control-label">成本</label>
							<div class="col-sm-10" style="width: 300px;">
								<input type="text" class="form-control" id="edit-cost">
							</div>
						</div>
						
						<div class="form-group">
							<label for="edit-describe" class="col-sm-2 control-label">描述</label>
							<div class="col-sm-10" style="width: 81%;">
								<textarea class="form-control" rows="3" id="edit-describe">市场活动Marketing，是指品牌主办或参与的展览会议与公关市场活动，包括自行主办的各类研讨会、客户交流会、演示会、新产品发布会、体验会、答谢会、年会和出席参加并布展或演讲的展览会、研讨会、行业交流会、颁奖典礼等</textarea>
							</div>
						</div>
						
					</form>
					
				</div>
				<div class="modal-footer">
					<button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
					<button type="button" class="btn btn-primary" data-dismiss="modal" id="saveEditActivityBtn">更新</button>
				</div>
			</div>
		</div>
	</div>
	
	<!-- 导入市场活动的模态窗口 -->
    <div class="modal fade" id="importActivityModal" role="dialog">
        <div class="modal-dialog" role="document" style="width: 85%;">
            <div class="modal-content">
                <div class="modal-header">
                    <button type="button" class="close" data-dismiss="modal">
                        <span aria-hidden="true">×</span>
                    </button>
                    <h4 class="modal-title" id="myModalLabel">导入市场活动</h4>
                </div>
                <div class="modal-body" style="height: 350px;">
                    <div style="position: relative;top: 20px; left: 50px;">
                        请选择要上传的文件：<small style="color: gray;">[仅支持.xls]</small>
                    </div>
                    <div style="position: relative;top: 40px; left: 50px;">
                        <input type="file" id="activityFile">
                    </div>
                    <div style="position: relative; width: 400px; height: 320px; left: 45% ; top: -40px;" >
                        <h3>重要提示</h3>
                        <ul>
                            <li>操作仅针对Excel，仅支持后缀名为XLS的文件。</li>
                            <li>给定文件的第一行将视为字段名。</li>
                            <li>请确认您的文件大小不超过5MB。</li>
                            <li>日期值以文本形式保存，必须符合yyyy-MM-dd格式。</li>
                            <li>日期时间以文本形式保存，必须符合yyyy-MM-dd HH:mm:ss的格式。</li>
                            <li>默认情况下，字符编码是UTF-8 (统一码)，请确保您导入的文件使用的是正确的字符编码方式。</li>
                            <li>建议您在导入真实数据之前用测试文件测试文件导入功能。</li>
                        </ul>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-default" data-dismiss="modal">关闭</button>
                    <button id="importActivityBtn" type="button" class="btn btn-primary">导入</button>
                </div>
            </div>
        </div>
    </div>
	
	
	<div>
		<div style="position: relative; left: 10px; top: -10px;">
			<div class="page-header">
				<h3>市场活动列表</h3>
			</div>
		</div>
	</div>
	<div style="position: relative; top: -20px; left: 0px; width: 100%; height: 100%;">
		<div style="width: 100%; position: absolute;top: 5px; left: 10px;">
		
			<div class="btn-toolbar" role="toolbar" style="height: 80px;">
				<form class="form-inline" role="form" style="position: relative;top: 8%; left: 5px;">
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">名称</div>
				      <input class="form-control" type="text" id="query-name">
				    </div>
				  </div>
				  
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">所有者</div>
				      <input class="form-control" type="text" id="query-owner">
				    </div>
				  </div>


				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">开始日期</div>
					  <input class="form-control mydate" type="text" id="query-startDate" />
				    </div>
				  </div>
				  <div class="form-group">
				    <div class="input-group">
				      <div class="input-group-addon">结束日期</div>
					  <input class="form-control mydate" type="text" id="query-endDate">
				    </div>
				  </div>
				  
				  <button type="button" class="btn btn-default" id="queryActivityBtn">查询</button>
				  
				</form>
			</div>
			<div class="btn-toolbar" role="toolbar" style="background-color: #F7F7F7; height: 50px; position: relative;top: 5px;">
				<div class="btn-group" style="position: relative; top: 18%;">
				  <button type="button" class="btn btn-primary" id="createActivityBtn"><span class="glyphicon glyphicon-plus"></span> 创建</button>
				  <button type="button" class="btn btn-default" id="editActivityBtn"  ><span class="glyphicon glyphicon-pencil"></span> 修改</button>
				  <button type="button" class="btn btn-danger"  id="deleteActivityBtn"><span class="glyphicon glyphicon-minus"></span> 删除</button>
				</div>
				<div class="btn-group" style="position: relative; top: 18%;">
                    <button type="button" class="btn btn-default" data-toggle="modal" data-target="#importActivityModal" ><span class="glyphicon glyphicon-import"></span> 上传列表数据（导入）</button>
                    <button id="exportActivityAllBtn" type="button" class="btn btn-default"><span class="glyphicon glyphicon-export"></span> 下载列表数据（批量导出）</button>
                    <button id="exportActivityXzBtn" type="button" class="btn btn-default"><span class="glyphicon glyphicon-export"></span> 下载列表数据（选择导出）</button>
                </div>
			</div>
			<div style="position: relative;top: 10px;">
				<table class="table table-hover">
					<thead>
						<tr style="color: #B3B3B3;">
							<td><input type="checkbox" id="checkAll"/></td>
							<td>名称</td>
                            <td>所有者</td>
							<td>开始日期</td>
							<td>结束日期</td>
						</tr>
					</thead>
					<tbody id="tBody">
						<%--<tr class="active">
							<td><input type="checkbox" /></td>
							<td><a style="text-decoration: none; cursor: pointer;" onclick="window.location.href='detail.jsp';">发传单</a></td>
                            <td>zhangsan</td>
							<td>2020-10-10</td>
							<td>2020-10-20</td>
						</tr>
                        <tr class="active">
                            <td><input type="checkbox" /></td>
                            <td><a style="text-decoration: none; cursor: pointer;" onclick="window.location.href='detail.jsp';">发传单</a></td>
                            <td>zhangsan</td>
                            <td>2020-10-10</td>
                            <td>2020-10-20</td>
                        </tr>--%>
					</tbody>
				</table>
				<div id="demo_pag1"></div>
			</div>
			
			<%--<div style="height: 50px; position: relative;top: 30px;">
				<div>
					<button type="button" class="btn btn-default" style="cursor: default;">共<b id="totalRowsB">50</b>条记录</button>
				</div>
				<div class="btn-group" style="position: relative;top: -34px; left: 110px;">
					<button type="button" class="btn btn-default" style="cursor: default;">显示</button>
					<div class="btn-group">
						<button type="button" class="btn btn-default dropdown-toggle" data-toggle="dropdown">
							10
							<span class="caret"></span>
						</button>
						<ul class="dropdown-menu" role="menu">
							<li><a href="#">20</a></li>
							<li><a href="#">30</a></li>
						</ul>
					</div>
					<button type="button" class="btn btn-default" style="cursor: default;">条/页</button>
				</div>
				<div style="position: relative;top: -88px; left: 285px;" id="demo_pag1">
					<nav>
						<ul class="pagination">
							<li class="disabled"><a href="#">首页</a></li>
							<li class="disabled"><a href="#">上一页</a></li>
							<li class="active"><a href="#">1</a></li>
							<li><a href="#">2</a></li>
							<li><a href="#">3</a></li>
							<li><a href="#">4</a></li>
							<li><a href="#">5</a></li>
							<li><a href="#">下一页</a></li>
							<li class="disabled"><a href="#">末页</a></li>
						</ul>
					</nav>
				</div>
			</div>--%>
			
		</div>
		
	</div>
</body>
</html>