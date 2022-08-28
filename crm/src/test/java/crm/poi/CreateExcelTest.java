package crm.poi;

import org.apache.poi.hssf.usermodel.HSSFCell;
import org.apache.poi.hssf.usermodel.HSSFRow;
import org.apache.poi.hssf.usermodel.HSSFSheet;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;

import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;

public class CreateExcelTest {
    public static void main(String[] args) throws IOException {
        //创建一个workbook对象
        HSSFWorkbook wb = new HSSFWorkbook();
        //利用wb对象创建一页为"学生列表"
        HSSFSheet sheet = wb.createSheet("学生列表");
        //创建一行
        HSSFRow row = sheet.createRow(0);
        //创建多列
        HSSFCell cell = row.createCell(0);
        cell.setCellValue("id");
        cell = row.createCell(1);
        cell.setCellValue("name");
        cell = row.createCell(2);
        cell.setCellValue("age");

        for (int i = 1; i<10; i++){
            row = sheet.createRow(i);

            cell = row.createCell(0);
            cell.setCellValue("100"+i);
            cell = row.createCell(1);
            cell.setCellValue("lihua");
            cell = row.createCell(2);
            cell.setCellValue("11"+i);
        }


        FileOutputStream fo = new FileOutputStream("F:\\1\\test\\aaa.xls");
        wb.write(fo);

        fo.close();
        wb.close();
        System.out.println("加载成功.......");

    }
}
