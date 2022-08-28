package com.bjpowernode.crm.commons.utils;

import org.apache.poi.hssf.usermodel.HSSFCell;

public class HSSFUtils {
    public static String getValue(HSSFCell cell){
        String ret="";
        //在这里判断获取的cell的类型
        if (cell.getCellType() == HSSFCell.CELL_TYPE_STRING){
            ret = cell.getStringCellValue();
        }else if (cell.getCellType() == HSSFCell.CELL_TYPE_BOOLEAN){
            ret = cell.getBooleanCellValue()+"";
        }else if (cell.getCellType() == HSSFCell.CELL_TYPE_NUMERIC){
            ret = cell.getNumericCellValue()+"";
        }else if (cell.getCellType() == HSSFCell.CELL_TYPE_FORMULA) {
            ret = cell.getCellFormula();
        }else {
            ret="";
        }
        return ret;
    }
}
