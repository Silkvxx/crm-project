package com.bjpowernode.crm.workbench.service;


import com.bjpowernode.crm.workbench.domain.ActivitiesRemark;

import java.util.List;

public interface ActivitiesRemarkService {

    List<ActivitiesRemark> queryActivityRemarkForDetailByActivityId(String id);

    int saveCreateActivityRemark(ActivitiesRemark remark);

    int deleteActivityRemarkById(String id);

    int saveEditActivityRemark(ActivitiesRemark remark);
}
