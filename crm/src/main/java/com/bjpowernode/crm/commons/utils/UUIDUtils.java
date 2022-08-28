package com.bjpowernode.crm.commons.utils;

import java.util.UUID;

public class UUIDUtils {
    /**
     * 获取一个随机的UUID
     * @return 返回字符串的形式
     */
    public static String getUUID(){
        return UUID.randomUUID().toString().replaceAll("-","");
    }
}
