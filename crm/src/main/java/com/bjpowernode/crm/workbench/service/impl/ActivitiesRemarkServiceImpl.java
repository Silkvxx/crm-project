package com.bjpowernode.crm.workbench.service.impl;

import com.bjpowernode.crm.workbench.domain.ActivitiesRemark;
import com.bjpowernode.crm.workbench.mapper.ActivitiesRemarkMapper;
import com.bjpowernode.crm.workbench.service.ActivitiesRemarkService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;

@Service("activitiesRemarkService")
public class ActivitiesRemarkServiceImpl implements ActivitiesRemarkService {

    @Autowired
    private ActivitiesRemarkMapper activitiesRemarkMapper;

    @Override
    public List<ActivitiesRemark> queryActivityRemarkForDetailByActivityId(String id) {
        return activitiesRemarkMapper.selectActivityRemarkForDetailByActivityId(id);
    }

    @Override
    public int saveCreateActivityRemark(ActivitiesRemark remark) {
        return activitiesRemarkMapper.insertActivityRemark(remark);
    }

    @Override
    public int deleteActivityRemarkById(String id) {
        return activitiesRemarkMapper.deleteActivityRemarkById(id);
    }

    @Override
    public int saveEditActivityRemark(ActivitiesRemark remark) {
        return activitiesRemarkMapper.updateActivityRemark(remark);
    }
}
